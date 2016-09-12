%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - PopPKPD Example
%
% SCRIPT_06_Model_PK_Final
% ------------------------
% The purpose of this script is to identify the correlations between the
% random effects and to determine the final PK model.
%
% IMPORTANT: This template assumes a standard popPK analysis with a single
% compound and a single concentration measurement. General popPK models can
% be handled with IQM Tools as well - but in this template these are not in
% scope.
%
% For more information, please contact: 
% 	Henning Schmidt
%   henning.schmidt@intiquan.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Installation of IQM Tools
% This block should always be on the top of every analysis script with IQM
% Tools. It might only be ommitted in the case that a central installation
% of IQM Tools is present on the computer system and the IQM Tools are
% automatically loaded during the startup of MATLAB.
clc;                        % Clear command window
clear all;                  % Clear workspace from all defined variables
close all;                  % Close all figures
fclose all;                 % Close all open files
restoredefaultpath();       % Clear all user installed toolboxes

% In the next line, please enter the path to your IQM Tools folder. It can
% be a relative or an absolute path.
PATH_IQM            = 'C:\PROJECTS\iqmtools\01 IQM Tools Suite'; 
oldpath             = pwd(); cd(PATH_IQM); installIQMtools; cd(oldpath);

%% "Initialize the compliance mode". 
% The input argument to the "IQMinitializeCompliance" function needs to be
% the name of the script file.
IQMinitializeCompliance('SCRIPT_06_Model_PK_Final');

%% Define general settings 

% Define the path to the popPK NLME dataset
path_modelingDataset    = '../Data/dataNLME_popPK.csv';

% Define the names of the time independent candidate covariates that you
% would like to explore in your popPK modeling

% Continuous covariates
covNames                = {'AGE0'    'WT0'};

% Categorical covariates
catNames                = {'SEX'     'STUDYN'    'TRT'     'IND'};

% Determine the data type header
% This header is needed for both NONMEM and MONOLIX model generation.
% Just execute this part - no need to change anything.
data                                        = IQMloadCSVdataset(path_modelingDataset);
dataheaderNLME                              = IQMgetNLMEdataHeader(data,covNames,catNames);

%% Define algorithm settings for the NLME parameter estimation tools 
% Default options for the NLME tools NONMEM and MONOLIX are set here in
% this section. They can be changed later (if needed). There are more
% general settings and tool specific settings.

optionsNLME                                 = [];                      

% General settings
optionsNLME.parameterEstimationTool         = 'MONOLIX';        % Default parameter estimation tool 
optionsNLME.N_PROCESSORS_PAR                = 8;                % Set number of max models to be run in parallel (requires the parallel toolbox from MATLAB)
optionsNLME.N_PROCESSORS_SINGLE             = 1;                % Set number of processors for parallelization of a single run

optionsNLME.algorithm.SEED                  = 123456;           % Set the seed (for SAEM in both NONMEM and MONOLIX)               
optionsNLME.algorithm.K1                    = 500;              % Set number of burn in iterations (for SAEM in both NONMEM and MONOLIX)
optionsNLME.algorithm.K2                    = 200;              % Set number of final iterations (for SAEM in both NONMEM and MONOLIX)
optionsNLME.algorithm.NRCHAINS              = 1;                % Set number of chains (for SAEM in both NONMEM and MONOLIX)

% Set NONMEM specific options
optionsNLME.algorithm.METHOD                = 'SAEM';           % Aöterntive: 'FO', 'FOCE', 'FOCEI'
optionsNLME.algorithm.ITS                   = 1;                % =1: Perform an iterative two-stage estimation prior to the desired METHOD, =0: do not
optionsNLME.algorithm.ITS_ITERATIONS        = 10;               % Number of ITS iterations to perform
optionsNLME.algorithm.IMPORTANCESAMPLING    = 1;                % =1: Perform importance sampling after the desired estimation method (makes sense only when using SAEM as method)
optionsNLME.algorithm.IMP_ITERATIONS        = 10;               % Number of importance sampling iterations
optionsNLME.algorithm.M4                    = 0;                % If dataset is prepared accordingly, M4=1 will use the M4 method for BLOQ. =0 will use the M3 method.
                                                                % If dataset not prepared, then M1,5,6,or 7 method is used. For more information please have a look
                                                                % at IQMhandleBLOQdata.
% Set MONOLIX specific options
optionsNLME.algorithm.LLsetting             = 'linearization';  % Alternative: 'importantsampling'

%% Initial discussion of random effect correlations
% - The selected covariate model is '..\Output\04-PKmodels\MODEL_PK_02_FINAL_COVARIATEMODEL'
% - The ETA correlation plot suggests some correlation of the random effect
%   parameters.
% - We assess several combinations of interest ... with and without VMAX and KM

%% Run covariance model with different covariance settings
% Run each model 4 times to assess robustness of the estimates ... and the
% identifiability of the correlations coefficients.

modeltest                           = [];                             
modeltest.numberCompartments        = [2];            
modeltest.errorModels               = {'prop'};        
modeltest.errorParam0               = [0.15];
modeltest.saturableClearance        = [1];           
modeltest.absorptionModel           = [1];
modeltest.lagTime                   = [0]; 
modeltest.FACTOR_UNITS              = 1;

%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 0.07  0.7   0.1   1.3    0.1   1      1      1        1     0.5        1       1     0.5        0.5     2      2];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5    0.5];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      1        1     1          0       1     1          1       1       1];
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      1        1     1          0       1     1          1       1       1];

modeltest.covariateModels           =  '{CL,WT0,SEX}, {Vc,WT0,SEX}, {Vp1,WT0}';

modeltest.covarianceModels          = {
                                       'diagonal'
                                       '{CL,Vc}'
                                       '{CL,Vc,Vp1}'
                                       '{CL,Vc,Q1,Vp1}'
                                       '{CL,Vc},{VMAX,KM}'
                                       '{CL,Vc,Vp1},{VMAX,KM}'
                                       '{CL,Vc,Q1,Vp1},{VMAX,KM}'
                                       '{CL,Vc,Q1,Vp1,VMAX,KM}'
                                      };
                                   
optionsModelSpace                   = [];
optionsModelSpace.Ntests            = 4;
optionsModelSpace.std_noise_setting = 0.5;

% Run it - do not forget to update the first input argument with the name
% of the folder where to store the covariate models
IQMbuildPopPKModelSpace('MODEL_PK__06_COVARIANCE', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME, optionsModelSpace);
 
% Discussion of results
% - Full covariance matrix not identifiable - Q1 main issue, as well as VMAX/KM (to little information)
% - CL, Vc, Vp correlations well identifiable and robust and leading to best BIC.
% Decision: Final model FITMODEL_PK__06_COVARIANCE_010 ('{CL,Vc,Vp1}')

%% Duplication of selected final coariance model to Output
modelSource         = '../Models/MODEL_PK__06_COVARIANCE/FITMODEL_PK__06_COVARIANCE_010';
modelDestination    = '../Output/04-PKmodels/MODEL_PK_03_FINALMODEL';

% Need to define the folder in which the modeling dataset is located in
% relation to the modelDestination folder.
relPathData         = '../../../Data';

% Duplicate it
IQMduplicateNLMEmodel(modelSource,modelDestination,relPathData)

%% Prepare a VPC for the final model
% Define the path to the project that the VPC should be generated for
NLMEproject     = '../Output/04-PKmodels/MODEL_PK_03_FINALMODEL';

% For the popPK model VPC the FACTOR_UNITS value needs to be defined
FACTOR_UNITS    = 1;

% Define the path to the output PDF with the VPC information
% Save
filename        = '../Output/04-PKmodels/VPC__MODEL_PK_03_FINALMODEL';

% Run the VPC function
vpcresult = IQMcreatePopPKstratifiedVPC(NLMEproject,FACTOR_UNITS,filename);

%% Replot the VPC with other output setting (withot regenerating VPC)
filename                    = '../Output/04-PKmodels/VPC__MODEL_PK_03_FINALMODEL_withDataQuantiles';
options                     = [];
options.showDataQuantiles   = 1;
options.logY                = 1;
IQMcreateVPCplot(vpcresult,filename,options)

%% Discussion of results of previous analysis
% - VPC looks reasonable although no big difference to no correlation
% - Model describing the data adequately

%% Create model comparison table for the three final models (base model, covariate model, final model)
% Table with all models
projectPaths =  {
                    '../Output/04-PKmodels/MODEL_PK_01_FINAL_BASEMODEL'
                    '../Output/04-PKmodels/MODEL_PK_02_FINAL_COVARIATEMODEL'
                    '../Output/04-PKmodels/MODEL_PK_03_FINALMODEL'
                };
IQMfitsummaryTable(projectPaths,'../Output/04-PKmodels/TABLE_ALL_MODEL_Comparison');

% Table with base and final model only
projectPaths =  {
                    '../Output/04-PKmodels/MODEL_PK_01_FINAL_BASEMODEL'
                    '../Output/04-PKmodels/MODEL_PK_03_FINALMODEL'
                };
IQMfitsummaryTable(projectPaths,'../Output/04-PKmodels/TABLE_BASE_AND_FINAL_MODEL_Comparison');




