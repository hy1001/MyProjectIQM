%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - PopPK Example
%
% SCRIPT_01_popPK
% ---------------
% The purpose of this script is to go through a complete popPK analysis.
%
% The data that is used in this popPK example has been simulated from an
% underlying popPK model that has no link to any specific clinical project,
% but it is quite realistic. The simulated dataset is intentionally kept
% small to allow for acceptable runtimes for demonstration and training
% purposes.    
% 
% * The simulated dataset contains 2 studies
%   - A single ascending dose study (placebo + 8 active dose groups, 6
%     subjects (male only) per group) 
%   - Multiple ascending dose study (placebo + 4 active dose groups, 10
%     subjects (male and female) per group) 
% * Some inclusion criteria
%   - Healthy males between 18 and 40 years of age
%   - Healthy women between 40 and 60 years of age
% * Information about the compound
%   - Small molecule
%   - Lipophilic
%   - Metabolized in the liver by an enzyme with age and gender dependent
%     expression level 
% * Additional simulation assumptions
%   - Different age, weight and height distributions for male and female
%     subjects 
%   - Correlation of weight and height
%   - Correlation of random effects (ETAs)
% * Outliers, data quality issues
%   - Some outliers and typos have been introduced manually into the
%     dataset (after simulation) in order to demonstrate the data cleaning
%     steps of the workflow 
%
% A documentation of the general dataset format can be viewed by typing
%   >> help IQMcheckGeneralDataFormat
%
% For more information, please contact: 
% 	Henning Schmidt
%   henning.schmidt@intiquan.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP
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

% "Initialize the compliance mode". 
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loading data and conversion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load the general dataset and check consistency
dataGeneral = IQMloadCSVdataset('../Data/data_general_HS02.csv');
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
DOSENAMES = {'Dose HS02'};

% Define the NAMEs of the observations that you want to analyze:
OBSNAMES = {'Plasma concentration HS02'};

% Define the baseline candidate covariates by their NAME in the general
% dataset and by the name of the covariate column for the modeling. It is
% not allowed to use underscores "_" in covariate column names!
covariateInfoTimeIndependent = {
    % NAME                BASELINE COVARIATE COLUMN NAME      
     'Age'               'AGE0'
     'Gender'            'SEX'
     'BMI'               'BMI0'
     'Bodyweight'        'WT0'
     'Height'            'HT0'
};

% Convert the general dataset format to the task specific one
dataTask = IQMconvertGeneral2TaskDataset(dataGeneral,DOSENAMES,OBSNAMES,covariateInfoTimeIndependent);

% Check the task specific dataset format
IQMcheckTaskDataset(dataTask);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data exploration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define covariate names present in the task specific dataset
% Continuous covariates
covNames = {'AGE0' 'BMI0' 'WT0' 'HT0' 'DOSE'};
% Categorical covariates
catNames = {'SEX' 'STUDYN' 'TRT'};

% These definitions need to be made to be used in the graphical exploration
% below. 'DOSE', 'STUDYN' and 'TRT' covariates have been added to the task
% specific dataset automatically.

%% Standard PK data exploration
% Several functions are available for the analysis of the data. Both
% graphical and statistical. For the purpose of PK analysis, some of these
% functions have been grouped into a PK exploration wrapper to more easily
% allow to generate a range of plots of interest. 
options = [];
options.outputPath = '../Output/01-DataExploration';
IQMexplorePKdataWrapper(dataTask,DOSENAMES,OBSNAMES,covNames,catNames,options)

%% Discussion of graphical analysis results
% An important benefit of using a workflow and workflow tools in a
% scripting environment is that analyses and interpretation of the results
% can be combined in a single script, allowing to easily follow the
% analysis and the reasoning of the user.    

% In this case, the results of the graphical analysis, generated in the
% '../Output/01-DataExploration' folder, can be summarized as follows: 
% 
% * File 00_Data_Contents.txt shows an overview of the data contents.
% * Consideration of file 02_Individual_Summary_Log.pdf suggests
%   accumulation of the compounds plasma concentration over the first
%   200-400 hours.  
% * Individual profiles in 03_Individual_Single_Linear.pdf and
%   04_Individual_Single_Log.pdf suggest 
%       - No lag time
%       - 2 or 3 distribution compartments, but not 1
% * Regarding outliers and data quality issues, the content of
%   04_individual_PK_data_SINGLE_logY.pdf
%   also suggests the following:
%   - The PK of subject X3401_0100_0018 seems to differ strongly in
%     comparison to the other subjects. 
%    - Likely outliers:
% 			Record:    82     
% 			Record:    124                 
% 			Record:    197            
% 			Record:    233              
% 			Record:    344                
% 			Record:    376                
% * Dose normalized plot over TIME and TAD suggests dose proportional
%   concentration values (see 06_Dose_Normalized_TIME.pdf)
% * Summary statistics are shown in 08_Summary_Statistics.txt
%   showing that some subjects are missing some covariate information. The
%   number of subjects with missing information is reasonably low to allow
%   for imputation of the missing information. 
% * Results in file 09_Covariates.pdf show that the candidate covariates
%   AGE0, HT0, WT0 are correlated and WT0 with BMI0. Furthermore, it shows 
%   that women are older and shorter than men in the study, which is not
%   surprising given the inclusion criteria, defined above for the
%   simulated studies.  
% * The covariate analysis plots
%   (10_Continuous_Covariates_Stratified_Dose_Normalized_TAD.pdf
%   and 11_Categorical_Covariates_Stratified_Dose_Normalized_TAD.pdf)
%   suggest a potential covariate effect of AGE0 and SEX - which again is
%   not surprising do to the knowledge about the compound that it is
%   metabolized by an enzyme with age and gender dependent expression
%   levels. However, due to correlation of age and gender in the dataset
%   there might be confounding. Additionally,  there might be an effect of
%   HT0 and WT0 on the PK. 
% * File 12_BLLOQ_Information.txt shows that a relatively lowe number of
%   BLOQ samples are present. Especially when considering that in the 87
%   subjects a pre-first dose PK sample has been taken.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data cleaning and NLME dataset creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% General Data Cleaning 

% The outliers (records), discussed above, are removed and the reason for
% removal is provided for each of them. The record number is the number of
% the row in the dataset (-1 due to the header). This record number is also
% shown in the individual plots generated above 
removeREC       = {
 %  IX in data          Reason
     82                 'Identified outlier'
    124                 'Identified outlier'
    197                 'Identified outlier'
    233                 'Identified outlier'
    344                 'Identified outlier'
    376                 'Identified outlier'
};

% The subject "X3401_0100_0037" is removed from the dataset since the PK
% profile suggests some inconsistencies as compared to the rest of the data.
% Several subjects can be removed by adding several rows. The reason for
% removal needs to be specified for each removed subject.
removeSUBJECT   = {
%   USUBJID             Reason    
    'X3401_0100_0018'  'Strange PK - excluded from analysis'
};

% Define imputation values for potentially missing categorical covariates
% This needs to be a vector of same length as catNames. The same order is
% assumed.
%                      SEX   STUDYN   TRT
catImputationValues = [1     99       99];

outputPath      = '../Output/02-DataCleaning';

dataClean       = IQMcleanPopPKdataWrapper(dataTask,DOSENAMES,OBSNAMES,covNames,catNames,removeSUBJECT,removeREC,outputPath,catImputationValues);

%% Handling of observations below the lower limit of quantification
% IQM Tools support all typical NONMEM-type of handling of observations
% below the lower limit of quantification: 
%
% METHOD_LLOQ   METHOD      DATA TRANSFORMATIONS
%     0         M1          All BLOQ data set to MDV=1
%     1         M3/M4       All BLOQ data obtains CENS=1 and DV=BLOQ
%     2         M5          All BLOQ data obtains DV=LLOQ/2
%     3         M6          All BLOQ data obtains DV=LLOQ/2 and the first
%                           occurence in a sequence MDV=0 (unchanged) and
%                           the following in sequence: MDV=1 
%     4         M7          All BLOQ data obtains DV=0
%
% Which methods makes sense to you is up to you. IQM Tools however suggests
% the following methods:
% 
% When using NONMEM:    METHOD_LLOQ=0,3
% When using MONOLIX:   METHOD_LLOQ=0,1
%
% With respect to NONMEM M3 and M4, this function only prepares the
% dataset. During the NONMEM model generation it can be specified if M3 or
% M4 method should be used. Default: M3.

% Assess total number of BLOQ data points
IQMexploreBLLOQdata(dataClean(dataClean.TIME>=0,:));

% In this case there are only 119 BLOQ values post first dose => we use
% METHOD_LLOQ = 0 (set all BLOQ data to MDV=1).

METHOD_LLOQ     = 0;

% Set filename for report of BLOQ setting
filename        = '../Output/03-DataCleaning_BLOQ';
dataCleanBLOQ   = IQMhandleBLOQdata(dataClean,METHOD_LLOQ,filename);

%% Generate summary statistics
% As last step before the generation of the NLME dataset the previously
% prepared and cleaned popPK dataset is analyzed and some summary level
% information is generated.

% Create a table with information about studies, treatment groups, number
% of active doses and number of PK observations for the cleaned dataset.
filename = '../Output/04-SummaryStatistics_PK_modeling_Data/01-DataContents';
IQMexploreDataContents(dataCleanBLOQ,DOSENAMES,OBSNAMES,filename)

% Generate a table with summary statistics for the cleaned dataset.
filename = '../Output/04-SummaryStatistics_PK_modeling_Data/02-SummaryStatistics';
IQMexploreSummaryStats(dataCleanBLOQ,covNames,catNames,filename);

%% Convert to NLME dataset for popPK modeling to be used in NONMEM and MONOLIX
regressionNames         = {};

% Provide a path and name for your popPK NLME modeling dataset:
path_modelingDataset    = '../Data/dataNLME_popPK.csv';

% Convert and export the NLME dataset
IQMconvertTask2NLMEdataset(dataCleanBLOQ,DOSENAMES,OBSNAMES,covNames,catNames,regressionNames,path_modelingDataset);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Until here the data is explored and the modeling dataset is prepared.
% If analysis is done in several steps and computer switched off inbetween
% it is enough to install IQM Tools and run the IQMinitializeCompliance
% above and then one can continue here.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Provide a path and name for your popPK NLME modeling dataset:
path_modelingDataset    = '../Data/dataNLME_popPK.csv';

% Define candidate covariates to be assessed during modeling
covNames = {'AGE0' 'BMI0' 'WT0' 'HT0'};     % Continuous covariates
catNames = {'SEX' 'STUDYN' 'TRT'};          % Categorical covariates

% Determine the NLME data header information
data                    = IQMloadCSVdataset(path_modelingDataset);
dataheaderNLME          = IQMgetNLMEdataHeader(data,covNames,catNames);

% Define algorithm settings for the NLME parameter estimation tools 
% Default options for the NLME tools NONMEM and MONOLIX are set here in
% this section. They can be changed later (if needed). There are more
% general settings and tool specific settings.
optionsNLME                                 = [];                      

% General settings
optionsNLME.parameterEstimationTool         = 'MONOLIX';         % Default parameter estimation tool 
optionsNLME.N_PROCESSORS_PAR                = 8;                % Set number of max models to be run in parallel (requires the parallel toolbox from MATLAB)
optionsNLME.N_PROCESSORS_SINGLE             = 1;                % Set number of processors for parallelization of a single run

optionsNLME.algorithm.SEED                  = 123456;           % Set the seed (for SAEM in both NONMEM and MONOLIX)               
optionsNLME.algorithm.K1                    = 500;              % Set number of burn in iterations (for SAEM in both NONMEM and MONOLIX)
optionsNLME.algorithm.K2                    = 200;              % Set number of final iterations (for SAEM in both NONMEM and MONOLIX)
% Due to the low number of subjects in the dataset we increase the number
% of chains from 1 to 5.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODEL BUILDING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initial parameter guesses and other settings
% - Create single "buest guess" Monolix project and start Monolix GUI to 
%   "Check initial guesses"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Before starting with the base model building, reasonable starting guesses
% for the PK parameters should be obtained. Also, it would be useful to
% assess adequate values for the K1 and K2 parameters.  
% 
% Possible scenarios for choosing initial guesses:
% 
% Prior knowledge: Using the values from the literature, prior knowledge
% about the compound or from previously developed models. Example
% recommendations in case of non-complete prior knowledge:  
%    a) if there is no information about Q2 and Vp2, use the same values as
%       for Q1 and Vp1;
%    b) if there is no information on VMAX and KM and previously developed
%       model is linear, set these to any values
%    c) Tlag can be set to a small fraction of the dosing interval;
%    d) ka could be set according to the dose interval.
%
% Simulation: This approach is detailed below and limited in its presented
% form to MONOLIX. A simulation based approach might be slow for large
% datasets. On the other hand, in case of a very large dataset (e.g., Phase
% III popPK), there should probably be some prior knowledge (e.g., popPK
% from Phase I-II) and therefore the previous scenario could be used.     
% Recommendation for choosing appropriate values for K1 and K2:
% 
% Start with one of the above approaches and perform a first estimation
% assessing the convergence profiles (see below). 
% In this example, it is assumed that the studies are first-in-human,
% therefore no prior information on the PK parameters is available and the
% "Simulation" approach will be used. Another option would be to use
% non-compartmental analysis to obtain starting values for CL and volumes.   

modeltest                           = [];                             
modeltest.numberCompartments        = 2;                         
modeltest.errorModels               = 'comb1';        
modeltest.saturableClearance        = 0;                   
modeltest.absorptionModel           = [1];
modeltest.lagTime                   = 0; 
% Dose in ug and concentration in ng/ml => FACTOR_UNITS=1
modeltest.FACTOR_UNITS              = 1;
%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 5     50    10    500    10    500    1      1        1     0.5        1       1     0.5        0.5     1e-10   10];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5     0.5];

optionsModelSpace                   = [];
optionsModelSpace.buildModelsOnly   = 1;

% optionsNLME.parameterEstimationTool = 'NONMEM';

IQMbuildPopPKModelSpace('MODEL_00_InitialGuessTest', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME, optionsModelSpace);

% How to determine suitable initial guesses (this step can only be
% performed with MONOLIX) 
% 
% The simulation based approach to determine initial guesses is the only
% step in the modeling workflow that is parameter estimation tool
% dependent. The MONOLIX GUI allows to simulate the model, change
% parameters and compare to the data by eye inspection. For NONMEM nothing
% equivalent does exist but even if a modeler prefers to use NONMEM for the
% fitting, MONOLIX could be used for determination of initial guesses.
% 
% The next steps will be manual and are the following:
% 
% * Start the MONOLIX GUI
% * Load the project FITMODEL_00_InitialGuessTest_001
% * Click on the button "Check initial fixed effects"
% * Change the number of TIME points to simulate from 100 to 1000
% * Assess the influence of changes in certain parameters until the initial
%   guesses lead to approximately adequate model vs. data match.
%   Alternatively use non-compartmental analysis (NCA) to get an idea about
%   reasonable initial guesses.   
% * Once the initial values for parameters are chosen, they should be used
%   in the following steps. 
% * Run an estimation
% * Determine values for K1 and K2 by assessing the convergence plot.
% * First estimation results could also be used as initial guesses for
%   subsequent steps. 
% * Note that the "Check initial fixed effects" assessment can be very slow
%   if the dataset is large. 
% 
% Non-compartmental approaches could also be very useful to get insights
% about parameter values for central compartment volume, clearance, etc. 
%
% Results:
% - K1=500 and K2=200 are enough
% - Reasonable initial guesses determined and used in the following
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Base model building
% - Random effects on all parameters
% - Diagonal random effect correlation matrix
% - Test 1, 2, and 3 compartments
% - Test lag time and no lag time
% - Test only addprop error model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

modeltest                           = [];                             
modeltest.numberCompartments        = [1 2 3];                          
modeltest.errorModels               = {'comb1'};        
modeltest.saturableClearance        = [0];                   
modeltest.absorptionModel           = [1];
modeltest.lagTime                   = [0 1]; 

% Dose in ug and concentration in ng/ml => FACTOR_UNITS=1
modeltest.FACTOR_UNITS              = 1;

%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 15    150   15    1000   15    1000   1      1        1     0.5        1       1     0.5        0.5     1e-10   10];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5     0.5];

optionsModelSpace                   = [];
optionsModelSpace.buildModelsOnly   = 0;

IQMbuildPopPKModelSpace('MODEL_01_BASE', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME, optionsModelSpace);

%% Discussion of results of previous analysis
% - A 2 compartment model is able to describe the data well
%   (FITMODEL_01_BASE_003)
% - No lag time can be identified 
% - RSEs for model FITMODEL_01_BASE_003 very small
%   - No large shrinkage
%   - Very good GoF assssment
%   - AGE, SEX, WT0, HTO as important covariates on CL
% - Selected BASE model: FITMODEL_01_BASE_003

%% Selection of final base model: Duplication of selected final base model to Output
% This is not really needed nut it is nice to be able to "label" certain
% models with a useful name. In this case we would like to name the best 2
% compartment model from the robustness assessment as final base model.

modelSource         = '../Models/MODEL_01_BASE/FITMODEL_01_BASE_003';
modelDestination    = '../Output/05-PKmodels/MODEL_PK_01_FINAL_BASEMODEL';

% Need to define the folder in which the modeling dataset is located in
% relation to the modelDestination folder.
relPathData         = '../../../Data';

% Duplicate it
IQMduplicateNLMEmodel(modelSource,modelDestination,relPathData)

%% Prepare a VPC for the selected final base model
% Define the path to the project that the VPC should be generated for
NLMEproject     = '../Output/05-PKmodels/MODEL_PK_01_FINAL_BASEMODEL';
% For the popPK model VPC the FACTOR_UNITS value needs to be defined
FACTOR_UNITS    = 1;
% Define the path to the output PDF with the VPC information
% Save
filename        = '../Output/05-PKmodels/VPC__MODEL_PK_01_FINAL_BASEMODEL';
% Set options
options         = [];
options.NTRIALS = 50;

% Run the VPC function
IQMcreatePopPKstratifiedVPC(NLMEproject,FACTOR_UNITS,filename,options);

%% Repeat the VPC but dose normalized and grouped by STUDY
% Define the path to the project that the VPC should be generated for
NLMEproject     = '../Output/05-PKmodels/MODEL_PK_01_FINAL_BASEMODEL';
% For the popPK model VPC the FACTOR_UNITS value needs to be defined
FACTOR_UNITS    = 1;
% Define the path to the output PDF with the VPC information
% Save
filename        = '../Output/05-PKmodels/VPC__MODEL_PK_01_FINAL_BASEMODEL_dose_normalized';
% Set options
options                 = [];
options.NTRIALS         = 50;
options.doseNormalized  = 1;
options.GROUP           = 'STUDY';

% Run the VPC function
IQMcreatePopPKstratifiedVPC(NLMEproject,FACTOR_UNITS,filename,options);

%% Results:
% Both VPCs show that the model describes the data reasonably.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Covariate model building
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From the compound background we know that AGE0 and SEX might play a role
% as covariates in the elimination. WT0 might be of interest as well. HT0
% and BMI0 are highly correlated with WT0 and might lead to confounding.
%
% We make two different approaches at covariate search:
% 1) Stepwise covariate search, testing all covariates on CL and WT0 on all
%    parameters.
% 2) Manual full covariate modeling

%% Stepwise covariate search
% Define the properties of the selected base model, including initial
% guesses for the fixed effects close to the results from the base model.
modeltest                           = [];                             
modeltest.numberCompartments        = [2];                          
modeltest.errorModels               = {'comb1'};        
modeltest.saturableClearance        = [0];                   
modeltest.absorptionModel           = [1];
modeltest.lagTime                   = [0]; 

% Dose in ug and concentration in ng/ml => FACTOR_UNITS=1
modeltest.FACTOR_UNITS              = 1;

%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 32    240   23    2280   15    1000   1      1        2     0.5        1       1     0.5        0.5     1e-10   10];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5     0.5];

optionsSCM                          = [];
optionsSCM.covariateTests           = {
                                        {'CL'   'AGE0' 'SEX' 'WT0' 'HT0' 'BMI0'}
                                        {'Vc'   'WT0'}
                                        {'Q1'   'WT0'}
                                        {'Vp1'  'WT0'}
                                        {'ka'   'WT0'}
                                      };

% Set NONMEM and FO to be used - FOCE is to slow for this example ...
% The reason for using NONMEM here is that a gradient based method might
% have some advantage for SCM and decisions based on Objective Function
% Value. If you do not have NONMEM on your computer, just remove the next 4
% lines and it will use MONOLIX instead. Never use SAEM in NONMEM for
% stepwise covariate search ... for me it always gets very unstable in real
% applications.
optionsNLME.parameterEstimationTool         = 'NONMEM';
optionsNLME.algorithm.METHOD                = 'FO';
optionsNLME.algorithm.ITS                   = 0;             
optionsNLME.algorithm.IMPORTANCESAMPLING    = 0;                

% Run the stepwise covariate search
IQMscmPopPK('MODEL_02_COVARIATES_SCM', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME, optionsSCM)

%% Results of SCM
% Stepwise covariate search with NONMEM FO identified: '{CL,SEX,AGE0,HT0,WT0},{Vc,WT0}'
% as the covariate model. AGE0 ans SEX on CL makes sense from what we know about the
% compound. WT0 and or HT0 might be of interest as well on CL but they are highly 
% correlated and the fact that both seem important is most likely due to numerical issues.

%% Full covariate modeling
% We try the following models:
% - No covariates
% - The SCM model
% - Additional things
%
% We decide against testing HT0 and BMI0 due to the high correlation with WT0. 
%
% We will run this with MONOLIX.
%
% After running it we will potentially add additional models to the run,
% based on the results.

modeltest                           = [];                             
modeltest.numberCompartments        = [2];                          
modeltest.errorModels               = {'comb1'};        
modeltest.saturableClearance        = [0];                   
modeltest.absorptionModel           = [1];
modeltest.lagTime                   = [0]; 

% Dose in ug and concentration in ng/ml => FACTOR_UNITS=1
modeltest.FACTOR_UNITS              = 1;

%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 32    240   23    2280   15    1000   1      1        2     0.5        1       1     0.5        0.5     1e-10   10];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5     0.5];

modeltest.covariateModels           = {
                                        ''                                              % added in first round
                                        '{CL,SEX,AGE0,HT0,WT0},{Vc,WT0}'                % added in first round
                                        '{CL,SEX,AGE0,WT0},{Vc,WT0},{Q1,WT0},{Vp1,WT0}' % added in first round
                                        '{CL,SEX,AGE0},{Vc,WT0}'                        % added in second round
                                        '{CL,SEX,AGE0,WT0},{Vc,WT0}'                    % added in second round
                                      };

optionsModelSpace                   = [];

% Return to MONOLIX
optionsNLME.parameterEstimationTool = 'MONOLIX';

IQMbuildPopPKModelSpace('MODEL_03_COVARIATES_FCM', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME, optionsModelSpace);

% Discussion of results:
% - First round: SCM result and third model almost identical in BIC. In SCM
%   model HT0 and WT0 on CL not significant - clearly due to uncertainty due
%   to the high correlation of HT0 and WT0. Neither WT0 on Q1. In third model WT0
%   on Q1 and Vp1 not significant.
%   We add two additional model with the non significant combinations
%   removed.
% - Second round: Model 5 better than model 4 based on BIC. In model 5 WT0
%   borderline significant on CL. We select the model 5 with WT0 on CL and
%   Vc.
% Selected model: FITMODEL_03_COVARIATES_FCM_005

%% Assessing "clinical relevance" of identified covariates
FIT_PATH    = '../Models/MODEL_03_COVARIATES_FCM/FITMODEL_03_COVARIATES_FCM_005';
filename    = '../Models/MODEL_03_COVARIATES_FCM/Covariate_Assessment__FITMODEL_03_COVARIATES_FCM_005';
IQMcovariateAssessmentUncertainty(FIT_PATH, filename)

% AGE0 and SEX clearly important on CL. WT0 on CL and Vc might not be
% really relevant. We still keep it.

%% Covariance modeling
% We try the following models:
% - CL, Vc
% - CL, Vc, Q1, Vp1 (based on ETA correlation plot)
%
% We run each model 4 times from different initial guesses to assess identifiability 

modeltest                           = [];                             
modeltest.numberCompartments        = [2];                          
modeltest.errorModels               = {'comb1'};        
modeltest.saturableClearance        = [0];                   
modeltest.absorptionModel           = [1];
modeltest.lagTime                   = [0]; 

% Dose in ug and concentration in ng/ml => FACTOR_UNITS=1
modeltest.FACTOR_UNITS              = 1;

%                                       CL    Vc    Q1    Vp1    Q2    Vp2    Fiv    Fabs1    ka    TlagAbs1   Fabs0   Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0                = [ 25    246   23    2290   15    1000   1      1        2     0.5        1       1     0.5        0.5     1e-10   10];
modeltest.POPestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVestimate               = [ 1     1     1     1      1     1      0      0        1     1          0       1     1          1       0       0];
modeltest.IIVvalues0                = [ 0.5   0.5   0.5   0.5    0.5   0.5    0.5    0.5      0.5   0.5        0.5     0.5   0.5        0.5     0.5     0.5];

modeltest.covariateModels           = '{CL,SEX,AGE0,WT0},{Vc,WT0}';

modeltest.covarianceModels          = {
                                        '{CL,Vc}'    
                                        '{CL,Vc,Q1,Vp1}'
                                        '{CL,Vc,Q1,Vp1,ka}'
                                      };
                                  
optionsModelSpace                   = [];
optionsModelSpace.Ntests            = 4;
optionsModelSpace.std_noise_setting = 0.5;

% Return to MONOLIX
optionsNLME.parameterEstimationTool = 'MONOLIX';

IQMbuildPopPKModelSpace('MODEL_04_COVARIANCE', modeltest, path_modelingDataset, dataheaderNLME, optionsNLME, optionsModelSpace);

% Result of previous analysis:
% - The '{CL,Vc,Q1,Vp1}' covariance matrix is identifiable. Few elements
%   around zero but others with important correlations.
% - Best model by BIC: FITMODEL_04_COVARIANCE_008 to be retaind as final
%   model.

%% Selection of final model: Duplication of selected final model to Output
modelSource         = '../Models/MODEL_04_COVARIANCE/FITMODEL_04_COVARIANCE_008';
modelDestination    = '../Output/05-PKmodels/MODEL_PK_02_FINALMODEL';

% Need to define the folder in which the modeling dataset is located in
% relation to the modelDestination folder.
relPathData         = '../../../Data';

% Duplicate it
IQMduplicateNLMEmodel(modelSource,modelDestination,relPathData)

%% Repeat the VPC but dose normalized and grouped by STUDY
% Define the path to the project that the VPC should be generated for
NLMEproject     = '../Output/05-PKmodels/MODEL_PK_02_FINALMODEL';
% For the popPK model VPC the FACTOR_UNITS value needs to be defined
FACTOR_UNITS    = 1;
% Define the path to the output PDF with the VPC information
% Save
filename        = '../Output/05-PKmodels/VPC__MODEL_PK_02_FINALMODEL_dose_normalized';
% Set options
options                 = [];
options.NTRIALS         = 50;
options.doseNormalized  = 1;
options.GROUP           = 'STUDY';

% Run the VPC function
IQMcreatePopPKstratifiedVPC(NLMEproject,FACTOR_UNITS,filename,options);

%% Assessing "clinical relevance" of identified covariates for final model
FIT_PATH    = '../Output/05-PKmodels/MODEL_PK_02_FINALMODEL';
filename    = '../Output/05-PKmodels/Covariate_Assessment__MODEL_PK_02_FINALMODEL';
IQMcovariateAssessmentUncertainty(FIT_PATH, filename)

% Result: WT0 on CL and Vc slighlty more important than without the
% covariance setting. Still WT0 is borderline important. For simulation
% purposes this is fine ...

%% Create a table comparing base and final model and reporting the parameter estimates, etc.
projectPaths =  {
                    '../Output/05-PKmodels/MODEL_PK_01_FINAL_BASEMODEL'
                    '../Output/05-PKmodels/MODEL_PK_02_FINALMODEL'
                };
IQMfitsummaryTable(projectPaths,'../Output/05-PKmodels/TABLE_BASE_AND_FINAL_MODEL_Comparison');

%% Ok, as final step a bootstrap - if you think this is needed ...
projectPath         = '../Output/05-PKmodels/MODEL_PK_02_FINALMODEL';
options             = [];
options.path        = '../Models/FINAL_MODEL_BOOTSTRAP';
options.NSAMPLES    = 100;         % You might want to take more samples ... but it takes longer then ...
options.GROUP       = 'TRTNAME';   % Stratify by treatment groups
IQMbootstrap(projectPath,options)

% As expected, pretty close to what the final model already has determined
% ...

%% The example is finished ... at some places decisions could have been different, but
% the point was not to explain how to do a popPK ... but how it can be done
% efficiently with IQM Tools.


