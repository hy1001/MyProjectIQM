%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - PopPKPD Example
%
% SCRIPT_04_Model_PK_Base
% -----------------------
% The purpose of this script is to build a popPK base model, based on the
% given dataset.
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
IQMinitializeCompliance('SCRIPT_04_Model_PK_Base');

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
optionsNLME.algorithm.METHOD                = 'SAEM';           % Alternative: 'FO', 'FOCE', 'FOCEI'
optionsNLME.algorithm.ITS                   = 1;                % =1: Perform an iterative two-stage estimation prior to the desired METHOD, =0: do not
optionsNLME.algorithm.ITS_ITERATIONS        = 10;               % Number of ITS iterations to perform
optionsNLME.algorithm.IMPORTANCESAMPLING    = 1;                % =1: Perform importance sampling after the desired estimation method (makes sense only when using SAEM as method)
optionsNLME.algorithm.IMP_ITERATIONS        = 10;               % Number of importance sampling iterations
optionsNLME.algorithm.M4                    = 0;                % If dataset is prepared accordingly, M4=1 will use the M4 method for BLOQ. =0 will use the M3 method.
                                                                % If dataset not prepared, then M1,5,6,or 7 method is used. For more information please have a look
                                                                % at IQMhandleBLOQdata.
% Set MONOLIX specific options
optionsNLME.algorithm.LLsetting             = 'linearization';  % Alternative: 'importantsampling'

%% Base model building
% For model building purposes in this workflow approach models can be
% generated based on the description of the model space of interest.
% Below a documented version of code that generates 2 and 3 compartmental
% distribution models with additive proportional error model and with and
% without saturable elimination from the central compartment.

% Initialize the "modeltest" variable
modeltest                           = [];                             

% Select the number of compartments that should be tested. Here in this
% example we want to try 2 and 3 compartments. Valied entries are 1, 2, or
% 3.
modeltest.numberCompartments        = [2 3];            

% Define the error model to be used for the concentration output.
% Here we use proportional and additive proportional error models. Valid entries are
% 'const': additive error model, 'prop': proportional error model, 'comb1':
% additive proportional error model. When you would like to use other error
% models, the DV data in the dataset might need to be transformed.
modeltest.errorModels               = {'prop','comb1'};        

% Define the initial guesses for the error parameters (not really needed
% for MONOLIX but NONMEM has often issues with the additive part, so it is
% good to initialize is closer to the truth (LLOQ a good guess)). For the
% additive proportional error model the first element is the guess for the
% additive error and the second for the proportional error:
%                                       b    a   b
modeltest.errorParam0               = {0.3 [0.8 0.3]};

% The following entry can contain values of 0 and 1. 0 means linear
% elimination only. 1 means additional saturable (michaelis menten type of)
% elimination.
modeltest.saturableClearance        = [0 1];           

% The following entry can contain values of 0, 1, and 2. 0 means 0th order
% absorption, 1 means first order absortpion, and 2 means mixed 0th/1st order
% absorption (parallel). Here we only test 1st order absorption
modeltest.absorptionModel           = [1];

% The following entry can contain values of 0 and 1. 0 means no lag time
% estimated on first order absorption doses. 1 means it is estimated.
modeltest.lagTime                   = [1];  % Use only 1st order absorption

% FACTOR_UNITS needs to be set to 1 if dose unit in mg and concentration in
% ug/ml. Or to 1000 if dose in mg and concentratin in ng/ml. Etc.
% Essentially, FACTOR_UNITS needs to be defined such that
% Dose*FACTOR_UNITS/Liter has the same unit as the concentration
% measurement.
modeltest.FACTOR_UNITS              = 1;

% In the following the initial guesses for the fixed and random effect
% parameters are defined. All PK model parameters are assumed to be
% log-normnally distributed. Therefor a good starting guess for the random
% effects (IIVvalues0) is 0.5. For the fixed effects (POPvalues0) the user
% can set guesses as desired, known or thought. There is a simple approach
% at finding useful guesses but thats out of scope for this example.

%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 0.2   5     1     5      1     5      1      1        1     0.5        1       1     0.5        0.5     10     10];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5    0.5];

% Define which fixed effects should be estimated and which should be kept
% fixed on initial guesses. A 1 in POPestimate indicates that this fixed
% effect should be estimated. A 0 indicates that this fixed effect should
% be kept on its initial guess.
% Some of the parameters below are handled differently than others.
% 1) CL, Vc, Q1, Vp1, Q2, Vp2, Tlaginput1, Tlagintput3, VMAX, KM: 
%    These parameters might not always be present in a created model (e.g.
%    in a 1 compartment model Q1, Vp1, Q2, Vp2 will not be present. Or in a
%    model without saturable elimination and lag time Tlaginput1/3, VMAX, and
%    KM are not present). This means that when setting POPestimate to 1 for
%    these parameters then these are estimated if they are present in the
%    model. Setting POPestimate for these to 0 will keep them fixed on the
%    initial guesses (if present in the model).
%    If 1st order with lag time is chosen, Tlaginput3 (lag for 0th order absorption)
%    is not present. Also, if only a single type of absorption is chosen, the
%    relative contribution of the absorptions (Frel) is not estimated.
% 2) ka and Tk0input3 are only estimated if absorption data is present in the 
%    dataset and the relevant absorption type has been chosen.
% 3) Fiv, Fabs1, Fabs0: For these parameters the user here needs to take care to set
%    POPestimate according to his/her needs. 

%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      1        1     1          0       1     1          1       1       1];

% Define which random effects should be estimated and which should be kept
% fixed on initial guesses. A 1 in IIVestimate indicates that this random
% effect should be estimated. A 0 indicates that this IIVestimate effect
% should not be estimated and not even be present in the model (setting it
% to 0, idenpendently of the value in IIVvalues0). A 2 indicates that this
% random effect should be present in the model but be fixed to the value
% defined in IIVvalues0. 
% Otherwise the same consideration as for POPestimate apply for IIVestimate
% as well.

%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      1        1     1          0       1     1          1       1       1];

% The call to the following function will generate all models that are
% defined above. In this case, 2 and 3 compartments will be combined with
% saturable elimination and no saturable elimination, and proportional and
% addprop error models in total leading to 8 candidate models. These models
% will be generated in the "../Models/MODEL_01_BASE" folder.
% 'MODEL_01_BASE' is the first input argument to the function below. The
% pre-fix for the path '../Models' is added automatically.
% The function will not only generate these 8 models, but also run them in
% the tool of choice (defined in optionsNLME). After running the models,
% the function will generate tables for model comparison and store them in
% "../Models/MODEL_01_BASE". Goodness of fit plots, etc. are located in
% each model folder within "../Models/MODEL_01_BASE".
IQMbuildPopPKModelSpace('MODEL_PK__01_BASE', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME);

%% Discussion of results of previous run
% - Saturable elimination clearly important
% - 3 compartments better by BIC than 2 compartments 
% - High RSE on additive part

%% Comparison of popPK models
% For demonstration purposes we want to compare the best 2 with the best 3
% compartmental model. This is done by providing the two project folders
% for the models to compare, a dosing and an observation schedule of
% clinical interest.  

projectFolders          = {'../Models/MODEL_PK__01_BASE/FITMODEL_PK__01_BASE_002','../Models/MODEL_PK__01_BASE/FITMODEL_PK__01_BASE_006'};
dosing                  = IQMcreateDOSING({'BOLUS','INFUSION','ABSORPTION0'},{0 100 0},{0 0:28:5*28 0},{[] 0.083 1});
obsTimes                = [0:1:200];
options                 = [];
options.minY            = 0.8; % Define LLOQ as minimum Y axis value
options.Nsim            = 500; % Number of subjects per simulation
options.filename        = '../Models/MODEL_PK__01_BASE/Model_comparison_002_with_006';
FACTOR_UNITS            = 1;
IQMcomparePopPKmodels(projectFolders,FACTOR_UNITS,dosing,obsTimes,options);

%% Discussion of results of previous analysis
% - Not exactly the same - not that different that it would be clinically relevant ...
%   However, consider now both models and do some robustness analysis to assess
%   identifiability

%% Refinement of BASE PK model
% 2+3 compartments, saturable+linear elimination, proportional error model
% Robustness x4

modeltest                           = [];                             
modeltest.numberCompartments        = [2 3];            
modeltest.errorModels               = {'prop'};        
modeltest.errorParam0               = {0.12};
modeltest.saturableClearance        = [1];           
modeltest.absorptionModel           = [1];
modeltest.lagTime                   = [0]; 
modeltest.FACTOR_UNITS              = 1;
%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 0.07  0.7   0.1   1.3    0.1   1      1      1        1     0.5        1       1     0.5        0.5     2      2];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5    0.5];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      1        1     1          0       1     1          1       1       1];
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      1        1     1          0       1     1          1       1       1];

optionsModelSpace                   = [];
optionsModelSpace.Ntests            = 4;
optionsModelSpace.std_noise_setting = 0.5;

IQMbuildPopPKModelSpace('MODEL_PK__02_BASE_ROBUSTNESS', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME,optionsModelSpace);

%% Discussion of results of previous analysis
% - Based on BIC one could argue for a 3cpt model - estimates reasonably robust
% - Based on GOF plots a 2 cpt model is sufficient
% Select FITMODEL_PK__02_BASE_ROBUSTNESS_001 as final base model

%% Duplication of selected final base model to Output
% This is not really needed nut it is nice to be able to "label" certain
% models with a useful name. In this case we would like to name the best 2
% compartment model from the robustness assessment as final base model.

modelSource         = '../Models/MODEL_PK__02_BASE_ROBUSTNESS/FITMODEL_PK__02_BASE_ROBUSTNESS_001';
modelDestination    = '../Output/04-PKmodels/MODEL_PK_01_FINAL_BASEMODEL';

% Need to define the folder in which the modeling dataset is located in
% relation to the modelDestination folder.
relPathData         = '../../../Data';

% Duplicate it
IQMduplicateNLMEmodel(modelSource,modelDestination,relPathData)

%% Prepare a VPC for the best 2 compartment model
% Define the path to the project that the VPC should be generated for
NLMEproject     = '../Output/04-PKmodels/MODEL_PK_01_FINAL_BASEMODEL';

% For the popPK model VPC the FACTOR_UNITS value needs to be defined
FACTOR_UNITS    = 1;

% Define the path to the output PDF with the VPC information
% Save
filename        = '../Output/04-PKmodels/VPC__MODEL_PK_01_FINAL_BASEMODEL';

% Run the VPC function
IQMcreatePopPKstratifiedVPC(NLMEproject,FACTOR_UNITS,filename);

%% Generation of VPC for 3cpt model ... for comparison
% - No improvement over selected final base model

% %% Prepare a VPC for the best 3 compartment model
% NLMEproject     = '../Models/MODEL_PK__02_BASE_ROBUSTNESS/FITMODEL_PK__02_BASE_ROBUSTNESS_006';
% FACTOR_UNITS    = 1;
% filename        = '../Output/04-PKmodels/VPC__MODEL_PK_3cpt_BASE';
% IQMcreatePopPKstratifiedVPC(NLMEproject,FACTOR_UNITS,filename);

