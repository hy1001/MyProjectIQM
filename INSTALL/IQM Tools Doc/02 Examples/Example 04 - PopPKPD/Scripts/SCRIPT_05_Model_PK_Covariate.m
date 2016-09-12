%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - PopPKPD Example
%
% SCRIPT_05_Model_PK_Covariate
% ----------------------------
% The purpose of this script is to identify covariates of importance
% (explaining parts of the variability)
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
IQMinitializeCompliance('SCRIPT_05_Model_PK_Covariate');

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

%% Initial discussion of covariates based on previous analyses
% - The selected base model is '..\Output\04-PKmodels\MODEL_PK_01_FINAL_BASEMODEL'
% - Low variability (<27%CV) - except for KM (high shrinkage)
% - Low shrinkage on CL, Vc, Vp1. High for Q1, KM, VMAX
% - WT0 on CL and Vc based on plots. AGE0 on VMAX possible - but high shrinkage
% - INIDICATION might have an impact as well ... but we decide not to
%   consider indication in this example
% - SEX on CL and Vc most likely driven by WT0/SEX correlation
%
% We will perform the covariate search in several different ways:
% 1) Manual search by including one candidate covariate after each other
%    based on model result analysis.
% 2) Step-wise covariate search.

%% Manual covariate search
% The same function (IQMbuildPopPKModelSpace) can be used to explore
% different covariate settings. We copy the model generation code from the
% base model and add covariates as done below:

modeltest                           = [];                             
modeltest.numberCompartments        = [2];            
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

% Define the covariate models of interest. This is done in a cell-array and
% for each entry one model is generated. We start by defining a model
% without covariates ('') and a model with only WT0 on CL, Vc, Vp1 and also add Q1.
% Subsequently we add more elements and rerun the whole section here. This
% will rerun all models but since it is done in parallel it does not take
% more time. 
modeltest.covariateModels           = {''                                                                   % Line added in first round                                  
                                       '{CL,WT0},           {Vc,WT0}, {Vp1,WT0}, {Q1,WT0}'                  % Line added in first round
                                      };

IQMbuildPopPKModelSpace('MODEL_PK__03_COVARIATE_MANUAL', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME);
 
%% Discussion of Results of previous analysis
% - '{CL,WT0}, {Vc,WT0}, {Vp1,WT0}, {Q1,WT0}'
%       - No weight dependency anymore on any parameter. 
%       - WT0 on Q1 not significant (remove in next step)
%       - WT0 on Vp1 borderline
%       - AGE0 and SEX might be important on CL
%       - AGE0 on VMAX potentially as well
%
% At this point one could add additional covariate combinations into the
% modeltest.covariateModels above and rerun the whole part. Iterating
% towards a reasonable covariate model. Here in the example due to long run
% times (for an example) decide to continue with a stepwise covariate
% search.

%% Using stepwise covariate search 
% Just to show that IQM Tools can work with NONMEM as easily as with
% MONOLIX we will conduct the stepwise covariate search wih NONMEM.
% Important here is to use a gradient based method. Numerics in NONMEM are
% just not so stable that the SAEM will make you happy.
%
% We will include WT0 on CL, Vc, Vp1 by default and only assess AGE0 and
% SEX on these three parameters and AGE0/VMAX by the stepwise covariate search.
%
% Same idea as with IQMbuildPopPKModelSpace:
%
% Since we run in NONMEM, we need to switch off the random effects on VMAX and KM ...
% it crashes otherwise

modeltest                           = [];                             
modeltest.numberCompartments        = [2];            
modeltest.errorModels               = {'prop'};        
modeltest.errorParam0               = {0.12};
modeltest.saturableClearance        = [1];           
modeltest.absorptionModel           = [1];
modeltest.lagTime                   = [0]; 
modeltest.FACTOR_UNITS              = 1;
%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 0.07  0.7   0.13  1.3    0.1   1      1      1        1     0.5        1       1     0.5        0.5     2      2];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5    0.5];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      1        1     1          0       1     1          1       1       1];
modeltest.IIVestimate               = [ 1     1     0     1      1     1      0      1        1     1          0       1     1          1       0       0];

% Main difference is that no covariate model needs to be defined. It is
% however possible to define one, which then will not be subject to the
% stepwise covariate search. Here we use this feature by defining the WT0
% should always be on CL, Vc, and Vp1.
modeltest.covariateModels           = '{CL,WT0},{Vc,WT0},{Vp1,WT0}';

% For the stepwise covariate search function the optionsSCM input argument
% needs to be provided additionally to define which covariates to test and
% other possible settings (see the help text to the IQMscmPopPK function).
%
% We decide to test AGE0 and SEX on CL, Vc, and Vp1
optionsSCM                          = [];
optionsSCM.covariateTests           = {
                                        {'CL'   'AGE0'	'SEX'}
                                        {'Vc'   'AGE0'	'SEX'}
                                        {'Vp1'  'AGE0'	'SEX'}
                                        {'VMAX' 'AGE0'}
                                      };

% Set NONMEM and FO to be used - FOCE is to slow for this example when given in a workshop setting ...
optionsNLME.parameterEstimationTool = 'NONMEM';
optionsNLME.algorithm.METHOD        = 'FO';

% Run the stepwise covariate search
IQMscmPopPK('MODEL_PK__04_COVARIATES_SCM', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME, optionsSCM)

%% Discussion of results of previous analysis:
% - NONMEM is numerically not as robust as MONOLIX and thus only gradient
%   based methods should be used when aiming at covariate modeling by
%   considering differences in the objective function.
% - FOCE was VERY slow. Switched to FO for this examle
% - It is NONMEM, so do not always expect the $COV step to work
% - Still the parameters for the BASE model are reasonably close to the
%   MONOLIX values - close enough for me (one could argue about VMAX and KM ...
%   but for the use of NONMEM we better removed the random effects on those parameters)
% - Final SCM covariate model is: {CL,SEX},{Vc,SEX}
%   Model: ../Models/MODEL_PK__04_COVARIATES_SCM/BW_LEVEL_2/MODEL_07
%
% The idea with using FO is also that: if a covariate is so important that it might
% be clinically relevant, one should also see it with FO. Assuming numerics are working ...
% which obviously is a thing of "believing (or not)" in NONMEM.

%% We better re-implement the best SCM model in MONOLIX for more accuracy ... before testing "clinical relevance"
modeltest                           = [];                             
modeltest.numberCompartments        = [2];            
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

modeltest.covariateModels           = {                             
                                       '{CL,WT0},           {Vc,WT0},     {Vp1,WT0}'                            % Based on manual search
                                       '{CL,WT0,SEX},       {Vc,WT0,SEX}, {Vp1,WT0}'                            % Based on final SCM model
                                      };

optionsNLME.parameterEstimationTool = 'MONOLIX';
IQMbuildPopPKModelSpace('MODEL_PK__05_COVARIATE_CHECK', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME);
 
%% Assessing "clinical relevance" of identified covariates
% Also the results of a stepwise covariate search should be assessed for
% clnical relevance.
FIT_PATH    = '../Models/MODEL_PK__05_COVARIATE_CHECK/FITMODEL_PK__05_COVARIATE_CHECK_001';
filename    = '../Models/MODEL_PK__05_COVARIATE_CHECK/COV__FITMODEL_PK__05_COVARIATE_CHECK_001';
IQMcovariateAssessmentUncertainty(FIT_PATH, filename)

FIT_PATH    = '../Models/MODEL_PK__05_COVARIATE_CHECK/FITMODEL_PK__05_COVARIATE_CHECK_002';
filename    = '../Models/MODEL_PK__05_COVARIATE_CHECK/COV__FITMODEL_PK__05_COVARIATE_CHECK_002';
IQMcovariateAssessmentUncertainty(FIT_PATH, filename)

%% Select final covariate model ...
% Relevance can be argued. Here we keep WT0 even on Vp1 even if not significant anymore
% Indication might be interesting to test as well.
% It is just an example and real relevance is not related to significance ... more to 
% important changes in PK properties for covariate combinations of interest and thus
% better addressed by simulation ... 
% Best model: FITMODEL_PK__05_COVARIATE_CHECK_002
% Select it as final covariate model

%% Duplication of selected final covariate model to Output
modelSource         = '../Models/MODEL_PK__05_COVARIATE_CHECK/FITMODEL_PK__05_COVARIATE_CHECK_002';
modelDestination    = '../Output/04-PKmodels/MODEL_PK_02_FINAL_COVARIATEMODEL';

% Need to define the folder in which the modeling dataset is located in
% relation to the modelDestination folder.
relPathData         = '../../../Data';

% Duplicate it
IQMduplicateNLMEmodel(modelSource,modelDestination,relPathData)
 
%% Prepare a VPC for the final covariate model
% Define the path to the project that the VPC should be generated for
NLMEproject     = '../Output/04-PKmodels/MODEL_PK_02_FINAL_COVARIATEMODEL';

% For the popPK model VPC the FACTOR_UNITS value needs to be defined
FACTOR_UNITS    = 1;

% Define the path to the output PDF with the VPC information
% Save
filename        = '../Output/04-PKmodels/VPC__MODEL_PK_02_FINAL_COVARIATEMODEL';

% Run the VPC function
IQMcreatePopPKstratifiedVPC(NLMEproject,FACTOR_UNITS,filename);

%% Discussion of results of previous analysis
% - VPC looks reasonable. 
% - Variability lower than in BASE model
% Next step: covariance model






