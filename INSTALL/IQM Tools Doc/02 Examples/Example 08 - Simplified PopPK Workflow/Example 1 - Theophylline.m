%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simplified PopPK Workflow - Theophylline Example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 0: Installation of IQM Tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;                        % Clear command window
clear all;                  % Clear workspace from all defined variables
close all;                  % Close all figures
fclose all;                 % Close all open files
restoredefaultpath();       % Clear all user installed toolboxes
PATH_IQM            = 'c:\PROJECTS\iqmtools\01 IQM Tools Suite'; 
oldpath             = pwd(); cd(PATH_IQM); installIQMtools; cd(oldpath);
IQMinitializeCompliance('Example 1 - Theophylline.m');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 1: Define information needed for the simplified popPK workflow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputPath                      = 'Example 1';

simplifiedPopPKInfo             = [];
simplifiedPopPKInfo.dataPath    = 'OriginalData/EX1_theop.csv';
simplifiedPopPKInfo.nameDose    = 'Theophylline Dose';
simplifiedPopPKInfo.namePK      = 'Theophylline Concentration';
simplifiedPopPKInfo.selectCOVS  = {'Weight,WT0'}; 
simplifiedPopPKInfo.selectCATS  = {'Gender,SEX'}; 

simplifiedPopPKInfo = IQMsimplifiedPopPKinit( outputPath, simplifiedPopPKInfo );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 2: Sanity check if general data format is correct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IQMsimplifiedPopPKcheckData(outputPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 3: Standard graphical exploration of the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IQMsimplifiedPopPKexploreData(outputPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 4: Data cleaning and NLME data generation step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IQMsimplifiedPopPKgetNLMEdata(outputPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 5: Do some simple popPK base model assessment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options                         = [];
options.parameterEstimationTool = 'NONMEM';
nameSpace                       = 'MODEL_01_BASE';
modeltest                       = [];
modeltest.numberCompartments    = [1 2];
modeltest.lagTime               = [0 1];
modeltest.absorptionModel       = [1];
modeltest.errorModels           = {'prop','comb1'};
IQMsimplifiedPopPKmodel(outputPath, nameSpace, modeltest, options)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Following steps: refine the model based on previous results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Compare 1st with 0th and mixed order absorption on best model from previous step
options                         = [];
options.parameterEstimationTool = 'MONOLIX';
nameSpace                       = 'MODEL_02_BASE';
modeltest                       = [];
modeltest.numberCompartments    = [1];
modeltest.lagTime               = [1];
modeltest.absorptionModel       = [0 1 2];
modeltest.errorModels           = {'comb1'};
IQMsimplifiedPopPKmodel(outputPath, nameSpace, modeltest, options)

%% Stick with 1st order absorption and add WT0 on CL and Vc
options                         = [];
options.parameterEstimationTool = 'MONOLIX';
nameSpace                       = 'MODEL_03_COV';
modeltest                       = [];
modeltest.numberCompartments    = [1];
modeltest.lagTime               = [1];
modeltest.absorptionModel       = [1];
modeltest.errorModels           = {'comb1'};
modeltest.covariateModels       = {'','{CL,WT0},{Vc,WT0}'};
IQMsimplifiedPopPKmodel(outputPath, nameSpace, modeltest, options)

%% Stick with 1st order absorption, no covariates and add CL/Vc correlation
options                         = [];
options.parameterEstimationTool = 'MONOLIX';
nameSpace                       = 'MODEL_04_COR';
modeltest                       = [];
modeltest.numberCompartments    = [1];
modeltest.lagTime               = [1];
modeltest.absorptionModel       = [1];
modeltest.errorModels           = {'comb1'};
modeltest.covarianceModels      = {'','{CL,Vc}'};
IQMsimplifiedPopPKmodel(outputPath, nameSpace, modeltest, options)

 
 