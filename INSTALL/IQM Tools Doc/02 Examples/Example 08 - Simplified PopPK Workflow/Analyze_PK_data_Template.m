%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template script, allowing to run the simplified popPK workflow.
% Requirements: a dataset in the IQM general dataset needs to be available
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 0: Installation of IQM Tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;                        % Clear command window
clear all;                  % Clear workspace from all defined variables
close all;                  % Close all figures
fclose all;                 % Close all open files
restoredefaultpath();       % Clear all user installed toolboxes

% Below please provide the path to the IQM Tools installation folder
PATH_IQM            = 'c:\PROJECTS\iqmtools\01 IQM Tools Suite'; 
oldpath             = pwd(); cd(PATH_IQM); installIQMtools; cd(oldpath);

% If you change the name of this script, please enter below the same name.
% It is needed if the IQM Tools Compliance Mode is switched on.
IQMinitializeCompliance('Analyze_PK_data_Template.m');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 1: Define information needed for the simplified popPK workflow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In the following line please provide a name for the folder in which you 
% want to generate the analysis results
outputPath                      = 'Example 3';
% outputPath                      = 'Example 1';

% Initialize an empty structure for this information
simplifiedPopPKInfo             = [];

% In the following line please provide the path to the general dataset that 
% you wish to use for the analysis
simplifiedPopPKInfo.dataPath    = 'OriginalData/EX3_simanimal.csv';
% simplifiedPopPKInfo.dataPath    = 'OriginalData/EX1_theop.csv';

% Please provide the NAME of the dosing event in the dataset that you want 
% to analyze. The "NAME" is the text that is located in the "NAME" column
% for a dose record in the dataset ... only one name can be provided. So if
% you have doses of multiple compounds in the dataset you will need to
% choose one 
simplifiedPopPKInfo.nameDose    = 'ABCD12 Dose';
% simplifiedPopPKInfo.nameDose    = 'Theophylline Dose';

% Please provide the NAME of the concentration (PK) readout in the dataset.
% It should be the concentration that matches to the dose that you
% specified above. Again, the NAME is the text that is located in the NAME
% column of a PK concentration record of interest 
simplifiedPopPKInfo.namePK      = 'ABCD12 Concentration';
% simplifiedPopPKInfo.namePK      = 'Theophylline Concentration';

% In the general dataset format covariates are stored in rows as
% "observation records". Here you can select continuous and categorical
% covariates that you would like to consider for your modeling. 
% This does not mean that these covariates are added to the model
% automatically - it only means these covariates will be present in the
% NLME modeling dataset and considered in the graphical output (plots of
% individual parameters vs. covariates). Adding them to the model can be
% done in a later stage in the simplified popPK workflow.
% 
% The format of how covariates are specified is explained by an example
% below. {} parentheses have to be put around. Inside these there are
% 'NAME, covariateName' elements separated by commata. "NAME" is the entry
% in the NAME column in the dataset for this covariate. "covariateName" is
% a shorter name that is going to be used as column name in the NLME
% modeling dataset.    

% OPTIONAL DEFINITIONS
% ====================
% Example for continuous covariates
simplifiedPopPKInfo.selectCOVS  = {}; % (optional)

% Additionally to the user defined covariates, additional continuous
% covariates will be added automatically: DOSE (dose given)

% Example for categorical covariates
simplifiedPopPKInfo.selectCATS  = {}; % (optional)

% Additionally to the user defined covariates, additional categorical
% covariates will be added automatically: STUDYN (study number) and TRT
% (treatment group number).

% RUN A FUNCTION
% ==============
% Run the following function to initialize the "simplifiedPopPKInfo"
% variable. This variable is returned as output but it is optional, since
% the information is also stored in a mat file in the outputPath folder by
% the other functions.
simplifiedPopPKInfo = IQMsimplifiedPopPKinit( outputPath, simplifiedPopPKInfo );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 2: Sanity check if general data format is correct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % This function is always the same ... just run it after having executed
% % all above. It will check consistency of the dataset. Please look at the
% % output in the MATLAB command window. It will notify you about potential
% % issues in the dataset, which would need to be fixed prior to continuation
% % of the analysis. 
% simplifiedPopPKInfo = IQMsimplifiedPopPKcheckData(outputPath, simplifiedPopPKInfo)

% Alternative call to function is without the simplifiedPopPKInfo input
% argument. Output argument is optional as well. If input argument not
% provided the information will be read from the mat file in the outputPath
% folder. Example:

IQMsimplifiedPopPKcheckData(outputPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 3: Standard graphical exploration of the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % This function will produce graphical exploration plots etc. In the Output folder 
% % within the "outputPath" that you selected above. Please have a look at all the output
% % to get familiar with the data and take next decisions in STEP 4.
% simplifiedPopPKInfo = IQMsimplifiedPopPKexploreData(outputPath, simplifiedPopPKInfo)

% Alternative call to function is without the simplifiedPopPKInfo input
% argument. Output argument is optional as well. If input argument not
% provided the information will be read from the mat file in the outputPath
% folder. Example:

IQMsimplifiedPopPKexploreData(outputPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 4: Data cleaning and NLME data generation step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% OPTIONAL DEFINITIONS
% ====================
% All the following definitions are optional and could not be made, falling
% back to reasonable defaults (M1 method for BLOQ data and no removal of
% neither records nor subjects)

% Define the method for BLOQ data
% METHOD_BLOQ   METHOD      DATA TRANSFORMATIONS
%     0         M1          All BLOQ data set to MDV=1 (default)
%     1         M3/M4       All BLOQ data obtains CENS=1 and DV=BLOQ
%     2         M5          All BLOQ data obtains DV=LLOQ/2
%     3         M6          All BLOQ data obtains DV=LLOQ/2 and the first
%                           occurence in a sequence MDV=0 (unchanged) and
%                           the following 
%                           in sequence: MDV=1 
%     4         M7          All BLOQ data obtains DV=0

simplifiedPopPKInfo.BLOQmethod = 0; % (optional - default: 0)

% Define records to remove:
simplifiedPopPKInfo.removeSUBJECT = {       % (optional - default: {})
%   USUBJID             REASON FOR REMOVAL
};

% Define subjects to remove:
simplifiedPopPKInfo.removeRECORD = {        % (optional - default: {})
%   INDEX (IXGDF)       REASON FOR REMOVAL    
};

% RUN A FUNCTION
% ==============
% % Run this function to clean the data, handle potential BLOQ data, and
% % generate an NLME dataset 
% simplifiedPopPKInfo = IQMsimplifiedPopPKgetNLMEdata(outputPath, simplifiedPopPKInfo);

% Alternative call to function is without the simplifiedPopPKInfo input
% argument. Output argument is optional as well. If input argument not
% provided the information will be read from the mat file in the outputPath
% folder. Example:

IQMsimplifiedPopPKgetNLMEdata(outputPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 5: Do some simple popPK base model assessment
%
% This function takes some optional input arguments, defined below.
% Essentially, the function will explore 1,2,3 compartment models (1 and 2 only for antibodies)
% It will try to obtain reasonable starting guesses for non-antibodies and use default starting 
% guesses for antibodies.
%
% After the analysis has run through, a table with parameter results for all models will be shown,
% allowing you to get information on which model might be the most reasonable as a potential base model.
%
% Currently the functionality is limited to this. In the future this could be extended to cover more things ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% options.NTESTS 		= 1;            => options

% results = IQMsimplifiedPopPKmodel(outputPath)

% nameSpace = 'MODEL_02';
% results = IQMsimplifiedPopPKmodel(outputPath, nameSpace)

options.parameterEstimationTool = 'NONMEM';
nameSpace                       = 'MODEL_01_NONMEM';
modeltest                       = [];
modeltest.numberCompartments    = [1 2];
modeltest.saturableClearance    = [0];
modeltest.lagTime               = [0 1];
modeltest.errorModels           = {'const','comb1','prop'};
results                         = IQMsimplifiedPopPKmodel(outputPath, nameSpace, modeltest, options)




  
 
 