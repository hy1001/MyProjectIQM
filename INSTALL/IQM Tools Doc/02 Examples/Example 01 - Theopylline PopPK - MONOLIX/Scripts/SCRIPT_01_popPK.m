%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - Theophylline PopPK Example (MONOLIX Version)
%
% SCRIPT_01_popPK
% ---------------
% The purpose of this script is to go through a complete popPK analysis
% based on theophylline data.
%
% The theophylline dataset is available in the IQM Tools general dataset
% format in the ../Data folder (Theophylline_data_generalFormat.csv).
% It is independent of a specific modeling tool or a software.
%
% For the purpose of this example, the typical theophyline data have been 
% augmented by a second dose group (800mg).
%
% A documentation of the general dataset format can be viewed by typing
%   >> help IQMcheckGeneralDataFormat
%
% For more information, please contact: 
% 	Henning Schmidt
%   henning.schmidt@intiquan.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Installation of IQM Tools
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
% IQM Tools allows to automatically generate logfiles for all output that
% is generated using the functions "IQMprintFigure" and
% "IQMwriteText2File". These logfiles contain the username, the name of the
% generated file (including the path), and the scripts and functions that
% have been called to generate the output file. In order to ensure this is
% working correctly, the only thing that needs to be done is to execute the
% following command at the start of each analysis script. 

% The input argument to the "IQMinitializeCompliance" function needs to be
% the name of the script file.
IQMinitializeCompliance('SCRIPT_01_popPK');

%% Load the general dataset and check consistency
dataGeneral = IQMloadCSVdataset('../Data/Theophylline_data_generalFormat.csv');
IQMcheckGeneralDataFormat(dataGeneral);

%% Convert general dataset to task specific dataset format
% In this example we want to conduct a popPK. The general
% dataset might contain information or readouts that are not needed for
% your analysis. And it does not contain all the columns that are needed
% for running NLME estimations. In this section the general dataset is
% converted to a task specific dataset format. 

% Columns that the user added to the general data format will remain in the
% task specific data format and can be used in the graphical analysis and
% modeling later on.

% Define the NAMEs of the event in the dataset that corresponds to the DOSE
% that you want to consider. If your data contains doses of multiple
% compounds, multiple names for the doses can be provided.
DOSENAMES = {'Theophylline Dose'};

% Define the NAMEs of the observations that you want to analyze:
OBSNAMES = {'Theophylline Concentration'};

% Define the baseline candidate covariates by their NAME in the general
% dataset and by the name of the covariate column for the modeling. It is
% not allowed to use underscores "_" in covariate column names!
covariateInfoTimeIndependent = {
    % NAME                BASELINE COVARIATE COLUMN NAME      
     'Gender'            'SEX'
     'Weight'            'WT0'
};

% Convert the general dataset format to the task specific one
dataTask = IQMconvertGeneral2TaskDataset(dataGeneral,DOSENAMES,OBSNAMES,covariateInfoTimeIndependent);

% Check the task specific dataset format
IQMcheckTaskDataset(dataTask);

%% Define covariate names
% Continuous covariates
covNames = {'WT0'};
% Categorical covariates
catNames = {'SEX','TRT'};

%% Standard PK data exploration
% Several functions are available for the analysis of the data. Both
% graphical and statistical. For the purpose of PK analysis, some of these
% functions have been grouped into a PK exploration wrapper to more easily
% allow to generate a range of plots of interest. 
options = [];
options.outputPath = '../Output/01-DataExploration';
IQMexplorePKdataWrapper(dataTask,DOSENAMES,OBSNAMES,covNames,catNames,options)

%% General Data Cleaning 
removeREC       = {
 %  IX in data          Reason
 232                    'TEST Reason'
 38                     'TEST Reason 2'
};

removeSUBJECT   = {
%   USUBJID             Reason    
 'Theo_2'                  'TEST Reason 3'
};

outputPath      = '../Output/02-DataCleaning';

dataClean       = IQMcleanPopPKdataWrapper(dataTask,DOSENAMES,OBSNAMES,covNames,catNames,removeSUBJECT,removeREC,outputPath);

%% Convert to NLME dataset for popPK modeling to be used in NONMEM and MONOLIX
regressionNames         = {};

% Provide a path and name for your popPK NLME modeling dataset:
path_modelingDataset    = '../Data/dataNLME_popPK.csv';

% Convert and export the NLME dataset
IQMconvertTask2NLMEdataset(dataClean,DOSENAMES,OBSNAMES,covNames,catNames,regressionNames,path_modelingDataset);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Until here the data is explored and the modeling dataset is prepared.
% If analysis is done in several steps and computer switched off inbetween
% it is enough to install IQM Tools and run the IQMinitializeCompliance
% above and then one can continue here.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define candidate covariates to be assessed during modeling
covNames                = {'WT0'}; % Continuous covariates
catNames                = {'SEX'}; % Categorical covariates

% Determine the NLME data header information
data                    = IQMloadCSVdataset(path_modelingDataset);
dataheaderNLME          = IQMgetNLMEdataHeader(data,covNames,catNames);

% Define algorithm settings for the NLME parameter estimation tools 
% Default options for the NLME tools NONMEM and MONOLIX are set here in
% this section. They can be changed later (if needed). There are more
% general settings and tool specific settings.
optionsNLME                                 = [];                      

% General settings
optionsNLME.parameterEstimationTool         = 'MONOLIX';        % Default parameter estimation tool 
optionsNLME.N_PROCESSORS_PAR                = 4;                % Set number of max models to be run in parallel (requires the parallel toolbox from MATLAB)
optionsNLME.N_PROCESSORS_SINGLE             = 1;                % Set number of processors for parallelization of a single run

optionsNLME.algorithm.SEED                  = 234567;           % Set the seed (for SAEM in both NONMEM and MONOLIX)               
optionsNLME.algorithm.K1                    = 500;              % Set number of burn in iterations (for SAEM in both NONMEM and MONOLIX)
optionsNLME.algorithm.K2                    = 200;              % Set number of final iterations (for SAEM in both NONMEM and MONOLIX)
% Due to the low number of subjects in the dataset we increase the number
% of chains from 1 to 5.
optionsNLME.algorithm.NRCHAINS              = 4;                % Set number of chains (for SAEM in both NONMEM and MONOLIX)

% Set NONMEM specific options
optionsNLME.algorithm.METHOD                = 'SAEM';           % Alterntive: 'FO', 'FOCE', 'FOCEI'
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
% Explore 1 and 2 compartments, linear elimination from central
% compartment, add, prop, addprop error models, no lag and with lag time on
% first order absorption.

modeltest                           = [];                             
modeltest.numberCompartments        = [1 2];                          
modeltest.errorModels               = {'const' 'prop' 'comb1'};        
modeltest.saturableClearance        = [0];   % Only linear elimination                 
modeltest.absorptionModel           = [1];   % First order absorption
modeltest.lagTime                   = [0 1]; % No lag time and lag time
modeltest.FACTOR_UNITS              = 1;
%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 5     60    10    500    10    500    1      1        1     0.5        1       1     0.5        0.5     1e-10   10];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5     0.5];

% Run these models with default NLME options (MONOLIX SAEM)
IQMbuildPopPKModelSpace('MODEL_01_BASEMODEL', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME);

%% Results of previous analyis.
% - Lag time clearly important
% - One comparment model sufficient
% - Propotional error model better than addpro. additive part has large RSE
% - Best model: FITMODEL_01_BASEMODEL_006
%       - Additive part estimated to almost 0
%         It is sometimes seen in MONOLIX that the proportional error model leads to 
%         numerical problems (here the same model with prop error model FITMODEL_01_BASEMODEL_004
%         has not converged properly). But if you now start to complain about that - wait until you
%         have seen the NONMEM results in Example 2 ...
%       - Convergence trajectories look very well
%       - RSEs look acceptable (except for additive part of error model)
%       - GoF plots look very well
%
% Selected model to take forward:
% - 1 compartment, lag time, random effect on all, prop error model (even if convergence before not "ideal")

%% Base model building - Absorption model
% - 1 compartment, lag time, random effect on all, prop error model
% - Testing 0th, 1st, and mixed (parallel) absorption
% - Update of fixed effect initial guesses to values from FITMODEL_01_BASEMODEL_006
% - Also add robustness ... run each model 4 times from different initial guesses ...

modeltest                           = [];                             
modeltest.numberCompartments        = [1];                          
modeltest.errorModels               = {'prop'};        
modeltest.saturableClearance        = [0];       % Only linear elimination                 
modeltest.absorptionModel           = [0 1 2];   % Test 3 different absorption models
modeltest.lagTime                   = [1];       % No lag time and lag time
modeltest.FACTOR_UNITS              = 1;
%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 3.41  41.7  10    500    10    500    1      1        2.48  0.133      1       1     0.5        0.5     1e-10   10];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5     0.5];

% Run model 4 times from different initial guesses
optionsModelSpace                   = [];
optionsModelSpace.Ntests            = 4;
optionsModelSpace.std_noise_setting = 0.5;

% Run these models with default NLME options (NONMEM and SAEM)
IQMbuildPopPKModelSpace('MODEL_02_BASEMODEL_ABSORPTION', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME, optionsModelSpace);

%% Results of previous analyis
% - Reasonably robust results
% - By BIC the mixed absorption model is best but there is some considerable 
%   uncertainty in the estimation of the lag times and their random effect.
%   For the purpose of this example we decide that we are happy with the 1st
%   order absorption model, which leads to perfectly robust results with very low
%   uncertainty in the estimates.
% Select base model as: FITMODEL_02_BASEMODEL_ABSORPTION_008

%% Selection of final BASE model and duplicate it to output
modelSource         = '../Models/MODEL_02_BASEMODEL_ABSORPTION/FITMODEL_02_BASEMODEL_ABSORPTION_008';
modelDestination    = '../Output/03-PKmodels/MODEL_PK_01_FINAL_BASEMODEL';

% Need to define the folder in which the modeling dataset is located in
% relation to the modelDestination folder.
relPathData         = '../../../Data';

% Duplicate it
IQMduplicateNLMEmodel(modelSource,modelDestination,relPathData)

%% Prepare a VPC for the final BASE model
NLMEproject     = '../Output/03-PKmodels/MODEL_PK_01_FINAL_BASEMODEL';

% For the popPK model VPC the FACTOR_UNITS value needs to be defined
FACTOR_UNITS    = 1;

% Define the path to the output PDF with the VPC information
% Save
filename        = '../Output/03-PKmodels/VPC__MODEL_PK_01_FINAL_BASEMODEL';

% Run the VPC function
vpcresult = IQMcreatePopPKstratifiedVPC(NLMEproject,FACTOR_UNITS,filename);

%% Covariate model building
% First use full covariate modeling
% We only consider CL and Vc as parameters. It might be also of interest to
% look at ka, given the previous best models diagnostics plots. This is
% only an example ...
modeltest                           = [];                             
modeltest.numberCompartments        = [1];                          
modeltest.errorModels               = {'prop'};        
modeltest.saturableClearance        = [0];       % Only linear elimination                 
modeltest.absorptionModel           = [1];       % First order absorption only
modeltest.lagTime                   = [1];       % No lag time and lag time
modeltest.FACTOR_UNITS              = 1;
%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 3.41  41.7  10    500    10    500    1      1        2.48  0.133      1       1     0.5        0.5     1e-10   10];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5     0.5];

modeltest.covariateModels           = {''
                                       '{CL,WT0}, {Vc,WT0}'
                                       '{CL,SEX}, {Vc,SEX}'
                                       '{CL,SEX,WT0}, {Vc,SEX,WT0}'
                                      };

% Run these models with default NLME options (NONMEM and SAEM)
IQMbuildPopPKModelSpace('MODEL_03_COVARIATE_FCM', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME);

%% Results of previous analyis
% - '{CL,WT0}, {Vc,WT0}' is the best model. Only WT0 on Vc is significant.
% - FITMODEL_03_COVARIATE_FCM_002 is best model

%% Assessing "clinical relevance" of identified covariates
% Also the results of a stepwise covariate search should be assessed for
% clnical relevance.
FIT_PATH    = '../Models/MODEL_03_COVARIATE_FCM/FITMODEL_03_COVARIATE_FCM_002';
filename    = '../Models/MODEL_03_COVARIATE_FCM/Covariate_Assessment__FITMODEL_03_COVARIATE_FCM_002';
IQMcovariateAssessmentUncertainty(FIT_PATH, filename)

%% Results of previous analyis
% - We decide to not keep WT0 as covariate on CL and Vc. With additional
% data that might be of interest. But given the low number of subjects and
% the limited variability we conclude it not to be important - for now.

%% Test covariance model
modeltest                           = [];                             
modeltest.numberCompartments        = [1];                          
modeltest.errorModels               = {'prop'};        
modeltest.saturableClearance        = [0];       % Only linear elimination                 
modeltest.absorptionModel           = [1];       % First order absorption only
modeltest.lagTime                   = [1];       % No lag time and lag time
modeltest.FACTOR_UNITS              = 1;
%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 3.41  41.7  10    500    10    500    1      1        2.48  0.133      1       1     0.5        0.5     1e-10   10];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5     0.5];

modeltest.covariateModels           = '';

modeltest.covarianceModels          = {
                                        ''
                                        '{CL,Vc}'
                                        '{CL,Vc,ka}'
                                        '{CL,Vc},{ka,Tlaginput1}'
                                        '{CL,Vc,ka,Tlaginput1}'
                                      };

% Run these models with default NLME options (NONMEM and SAEM)
IQMbuildPopPKModelSpace('MODEL_04_COVARIANCE', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME);

%% Results of previous analyis
% - Best model with correlation of CL and Vc only (by BIC)
% - However, it seems that even the model with '{CL,Vc,ka}' is
%   identifiable when looking at the identified correlation coefficients in
%   comparison with all other models. We choose it as the final model
%   (FITMODEL_04_COVARIANCE_003). 

%% Selection of FINAL model and duplicate it to output
modelSource         = '../Models/MODEL_04_COVARIANCE/FITMODEL_04_COVARIANCE_003';
modelDestination    = '../Output/03-PKmodels/MODEL_PK_02_FINALMODEL';

% Need to define the folder in which the modeling dataset is located in
% relation to the modelDestination folder.
relPathData         = '../../../Data';

% Duplicate it
IQMduplicateNLMEmodel(modelSource,modelDestination,relPathData)

%% Prepare a VPC for the final model
NLMEproject     = '../Output/03-PKmodels/MODEL_PK_02_FINALMODEL';

% For the popPK model VPC the FACTOR_UNITS value needs to be defined
FACTOR_UNITS    = 1;

% Define the path to the output PDF with the VPC information
% Save
filename        = '../Output/03-PKmodels/VPC__MODEL_PK_02_FINALMODEL';

% Run the VPC function
vpcresult = IQMcreatePopPKstratifiedVPC(NLMEproject,FACTOR_UNITS,filename);

%% Discussion of results of previous analysis
% - VPC looks reasonable 
% - Model describing the data adequately

%% Create model comparison table for the final models (base model, final model)
% Table with all models
projectPaths =  {
                    '../Output/03-PKmodels/MODEL_PK_01_FINAL_BASEMODEL'
                    '../Output/03-PKmodels/MODEL_PK_02_FINALMODEL'
                };
IQMfitsummaryTable(projectPaths,'../Output/03-PKmodels/TABLE_ALL_MODEL_Comparison');

