function [] = IQMcomparePopPKmodels(projectFolders,FACTOR_UNITS,dosing,obsTimes,options,covNames,catNames,data)
% This function allows to compare different popPK models created with the
% popPK workflow in IQM Tools. Useful for model selection when GOF
% plots and other assessments suggest models are behaving very similar.
%
% Covariates can be taken into account. For that the relevant information
% need to be provided. Sampling is done from the covariates in the modeling
% dataset. The user has to make sure that a reasonable number of
% simulations (options.Nsim) is done.
%
% [SYNTAX]
% [] = IQMcomparePopPKmodels(projectFolders,FACTOR_UNITS,dosing,obsTimes)
% [] = IQMcomparePopPKmodels(projectFolders,FACTOR_UNITS,dosing,obsTimes,options)
% [] = IQMcomparePopPKmodels(projectFolders,FACTOR_UNITS,dosing,obsTimes,options,covNames,catNames,data)
%
% [INPUT]
% projectFolders:   Cell-array with the names of the Monolix project
%                   folders for which to compare the models. The elements
%                   need to include the full/relative path to the models
% FACTOR_UNITS:     The FACTOR_UNITS value used for popPK model fitting.
% dosing:           Dosing scheme to simulate the model for. The dosing scheme 
%                   needs to contain 3 inputs in the following order:
%                   'BOLUS', 'INFUSION', and 'ABSORPTION0'. Not all need to have
%                   doses different from 0. First order absorption is handled by the 
%                   first input (BOLUS). Zero order absorption by the third. Mixed 
%                   absorption is handled by using first and third input with the same doses.
%                   IV bolus or infusion by the second input. 
% obsTimes:         Observation times to compare the models at
% covNames:         Cell-array with continous covariate names to take into
%                   account (only done if the modelfit uses these)
% catNames:         Cell-array with categorical covariate names to take into
%                   account (only done if the modelfit uses these)
% data:             MATLAB dataset which was used for model fitting. Standard
%                   IQM Tools dataset is assumed. The columns with the
%                   specified covariate names have to exist
%                   Alternatively, the path to the datafile can be
%                   specified
% options:          Matlab structure with optional information
%       options.filename            Filename (with path) for export of resulting figure as PNG. If undefined or empty then not exported (default: '')
%       options.N_PROCESSORS:       Number of processors for parallel computation (default: as specified in SETUP_PATHS_TOOLS_IQMPRO)
%       options.Nsim                Number of samples from IIV distributions (default: 100)
%       options.quantiles           Vector with quantiles to compute for comparison (does only make sense if Nsim reasonably large) (default: [0.05 0.95])
%       options.logY                =1: log Y axis, =0: linear Y axis
%       options.minY                Lower limit for Y-axis, e.g. LLOQ for PK
%       options.plotData            =0 no (by default); =1 yes
%       options.optionsIntegrator   options for the integration. By default: abstol=1e-6, reltol=1e-6
%
% [OUTPUT]
% The figure with the comparison is stored in the filename file (PNG) or if not
% defined, then just shown

% <<<COPYRIGHTSTATEMENT - IQM TOOLS PRO>>>

% Handle variable input arguments
if nargin<5,
    options = [];
end
if nargin<6,
    covNames = {};
end
if nargin<7,
    catNames = {};
end
if nargin<8,
    data = table();
end

% Handle optional input arguments
try filename        = options.filename;         catch, filename     = '';   end
try Nsim            = options.Nsim;             catch, Nsim         = 100;  end
try N_PROCESSORS    = options.N_PROCESSORS;     catch, N_PROCESSORS = getN_PROCESSORS_PARIQM(); end
try logY            = options.logY;             catch, logY         = 1;    end
try minY            = options.minY;             catch, minY         = [];   end
try plotData        = options.plotData;         catch, plotData     = 0;    end

% Handle data
if ischar(data),
    % If not provided as dataset, then load it
    data = IQMloadCSVdataset(data);
end

% Handle interface to IQMcompareModels
model                           = IQMmodel('template_popPK_model.txt');
output                          = 'OUTPUT1';
optionsComparison               = [];
optionsComparison.Nsim          = Nsim;
optionsComparison.N_PROCESSORS  = N_PROCESSORS;
optionsComparison.logY          = logY;
optionsComparison.minY          = minY;
optionsComparison.plotData      = plotData;

% Update model with needed parameter settings
model                           = IQMparameters(model,'FACTOR_UNITS',FACTOR_UNITS);
% Ensure VMAX and other param are 0 and only changed by the fit
model                           = IQMparameters(model,{'CL','Q1','Q2','VMAX','ka'},[0 0 0 0 0]);

% Check dosing definition
ds                              = struct(dosing);
inputtypes                      = {ds.inputs.type};
if length(inputtypes) ~= 3,
    error('Dosing definition needs to contain 3 inputs of types (in this order): BOLUS, INFUSION, ABSORPTION0.');
end
if ~strcmp(inputtypes{1},'BOLUS') || ~strcmp(inputtypes{2},'INFUSION') || ~strcmp(inputtypes{3},'ABSORPTION0'),
    error('Dosing definition needs to contain 3 inputs of types (in this order): BOLUS, INFUSION, ABSORPTION0.');
end
% Check if dosing contains Tlag on INPUT1
if isempty(ds.inputs(1).Tlag),
    ds.inputs(1).Tlag           = 0;
end
% Check if dosing contains Tlag on INPUT3
if isempty(ds.inputs(3).Tlag),
    ds.inputs(3).Tlag           = 0;
end
% Check if Tinf on INPUT2 is 0 then exchange against small value
if ds.inputs(2).parameters.value==0,
    ds.inputs(2).parameters.value = 0.0001;
end
% Check if Tk0 on INPUT3 is 0 then exchange against small value
if ds.inputs(3).parameters.value==0,
    ds.inputs(3).parameters.value = 0.0001;
end
% Create updated dosing
dosing                          = IQMdosing(ds);

% Run compare models
IQMcompareModels(projectFolders,model,output,dosing,obsTimes,optionsComparison,covNames,catNames,data)

% Export figure
IQMprintFigure(gcf,filename,'png');

