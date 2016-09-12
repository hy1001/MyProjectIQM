%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - PopPKPD Example
%
% SCRIPT_03_Data_PK_Conversion
% ----------------------------
% The purpose of this script is to clean the PK data and to export the dose 
% and PK data to a NLME dataset that is going to be used for PopPK model
% building in NONMEM and/or MONOLIX.
%
% Additionally, summary level information is generated for the final
% cleaned popPK dataset. 
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
IQMinitializeCompliance('SCRIPT_03_Data_PK_Conversion');

%% Load the task specific dataset format
dataTask = IQMloadCSVdataset('../Data/dataTask_Example.csv');

%% Define task specific information

% Define the NAME of the event in the dataset that corresponds to the DOSE
% that you want to consider in the popPK
DOSENAME    = 'Dose Z';

% Define the NAMEs of the observations that you want to use as
% concentration measurement in the popPK analysis
OBSNAME     = 'Plasma concentration Z';

% Define the names of the time independent candidate covariates that you
% would like to explore

% Continuous covariates
covNames    = {'AGE0'    'WT0'};

% Categorical covariates
catNames    = {'SEX'     'STUDYN'    'TRT'     'IND'};
% The categorical covariates STUDYN, TRT, and IND have been
% automatically added to the task dataset during its creation, based on the
% columns STUDY, TRTNAME, and INDNAME.

%% General Data Cleaning 
% The general data cleaning performs several steps that are typically
% always required:
% 1) IQMcleanRemoveRecordsSUBJECTs - removes manually selected records and subjects
% 2) IQMselectDataEvents - keeps only selected dose and observation
% 3) IQMcleanRemoveIGNOREDrecords - removes ignored records by IGNORE column
% 4) IQMcleanRemovePlaceboSubjects - removes placebo subjects
% 5) IQMcleanRemoveSubjectsNoObservations - removes subjects without PK observations
% 6) IQMcleanRemoveZeroDoses - removes doses with 0 amount
% 7) IQMcleanImputeCovariates - imputes covariates - continuous to the median, categorical to 99999 
% 8) Removes all observation records that are set to MDV=1

% Please provide the indices of the PK records that you wish to remove from
% the analysis and the reason why. These indices correspond to the of the
% row in the dataset (-1 due to the header). These indices are also
% displayed as IX# in the individual plots when using the
% IQMexplorePKdataWrapper function. If nothing is to be removed then set to
% removeREC = {};

removeREC       = {
 %  IX in data          Reason
    412                  'Pre-dose non zero PK'
    442                  'Pre-dose non zero PK'
    467                  'Pre-dose non zero PK'
    1562                 'Pre-dose non zero PK'
    
    621                  'Outlier'
    826                 'Outlier'
    853                 'Outlier'
    919                 'Outlier'
    984                 'Outlier'
    1084                'Outlier'
};

% Please provide the USUBJIDs of the subjects that you wish to remove from
% the analysis and the reason why. If nothing is to be removed then set to
% removeSUBJECT = {};

removeSUBJECT   = {
    'ZY300707018'       'Single observation only'
    'ZY300707062'       'Single observation only'
};

% Please provide the path of the output folder where you wish the cleaning
% log files for each sub function to be created.
outputPath      = '../Output/02-DataCleaning';

% Run the data cleaning
dataClean       = IQMcleanPopPKdataWrapper(dataTask,DOSENAME,OBSNAME,covNames,catNames,removeSUBJECT,removeREC,outputPath);

%% Manual cleaning
% Obviously, at all stages you can perform some additional manual data
% cleaning, but you will need to take care of logging what you did
% yourself. Also, please, if using the removeREC feature above, consider
% that the number of the records displayed by the IQMexplorePKdataWrapper
% function only make sense if you do not do manual cleaning between the
% call to this function and the call to IQMcleanPopPKdataWrapper.

% Here in this case, since it is about PK modeling and we took care of the
% pre-firs-dose non-zero PK observations in the data cleaning above, we are
% going to remove all 0 PK observations pre-first dose
dataClean(dataClean.TIME<=0 & dataClean.EVID==0,:) = [];

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
IQMexploreBLLOQdata(dataClean);

% In this case there are only 39 BLOQ values post first dose => we use
% METHOD_LLOQ = 0 (set all BLOQ data to MDV=1).

METHOD_LLOQ     = 0;

% Set filename for report of BLOQ setting
filename        = '../Output/02-DataCleaning/BLOQ_handling';
dataCleanBLOQ   = IQMhandleBLOQdata(dataClean,METHOD_LLOQ,filename);

%% Generate summary statistics
% As last step before the generation of the NLME dataset the previously
% prepared and cleaned popPK dataset is analyzed and some summary level
% information is generated.

% Create a table with information about studies, treatment groups, number
% of active doses and number of PK observations for the cleaned dataset.
filename = '../Output/03-SummaryStatistics_PK_modeling_Data/01-DataContents';
IQMexploreDataContents(dataCleanBLOQ,DOSENAME,OBSNAME,filename);

% Generate a table with summary statistics for thre cleaned dataset.
filename = '../Output/03-SummaryStatistics_PK_modeling_Data/02-SummaryStatistics';
IQMexploreSummaryStats(dataCleanBLOQ,covNames,catNames,filename);

%% Convert to NLME dataset for popPK modeling to be used in NONMEM and MONOLIX
% The cleaned dataset is now exported to a format that is suitable for
% NONMEM and MONOLIX to be used as input dataset.

% Define regression parameters that are in the dataset and that you would
% like to pass to the model. Typically, for the simple popPK modeling this
% is kept empty ({}). 
regressionNames = {};

% Provide a path and name for your popPK NLME modeling dataset:
filename = '../Data/dataNLME_popPK.csv';

% Convert and export the NLME dataset
IQMconvertTask2NLMEdataset(dataCleanBLOQ,DOSENAME,OBSNAME,covNames,catNames,regressionNames,filename);

% Please have a look into the command window. It provided information about
% the mapping of NAME for DOSE and Observation to ADM and YTYPE numbers.
% ADM and YTYPE are MONOLIX ideas but in IQM Tools they are used for NONMEM
% as well (instead of CMT). It is easier, it makes more sense, and it is
% possible.

% Copying out the information from the command window:
%
% NLME dataset generation: Mapping between ADM and ROUTE for the doses:
%       NAME      ROUTE    ADM
%     ________    _____    ___
% 
%     'Dose Z'    'iv'     2  
% 
% NLME dataset generation: Mapping between OBSNAMES and YTYPE:
%               NAME              YTYPE
%     ________________________    _____
% 
%     'Plasma concentration Z'    1    

% In order to use the IQM Tools popPK workflow for model building, it is
% important that the concentration has YTYPE=1. And that the link between
% the dose, route and ADM is such that IV bolus and infusion
% administrations obtain ADM=2 and administrations that should be modeled
% with first order absorption should get ADM=1.
%
% Other absorptions are currently not handled automatically, but are
% possible to realize as well with IQM Tools - just not with the popPK
% workflow tools (for now).
