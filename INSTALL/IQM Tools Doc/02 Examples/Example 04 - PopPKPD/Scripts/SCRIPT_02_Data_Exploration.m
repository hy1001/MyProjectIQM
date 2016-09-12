%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - PopPKPD Example
%
% SCRIPT_02_Data_Exploration
% --------------------------
% The purpose of this script is to perform some initial data explorations.
% Since the goal is a popPK and popPD, both the dose/concentration
% relationship and the dose/concentration/response relationship is
% considered.
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
% IQM Tools allows to automatically generate logfiles for all output that
% is generated using the functions "IQMprintFigure" and
% "IQMwriteText2File". These logfiles contain the username, the name of the
% generated file (including the path), and the scripts and functions that
% have been called to generate the output file. In order to ensure this is
% working correctly, the only thing that needs to be done is to execute the
% following command at the start of each analysis script. 

% The input argument to the "IQMinitializeCompliance" function needs to be
% the name of the script file.
IQMinitializeCompliance('SCRIPT_02_Data_Exploration');

%% Load the task specific dataset format
dataTask = IQMloadCSVdataset('../Data/dataTask_Example.csv');

%% Define task specific information

% Define the NAMEs of the event in the dataset that corresponds to the DOSE
% that you want to consider
DOSENAMES   = {'Dose Z'};

% Define the NAMEs of the observations that you want to analyze:
OBSNAMES    = {'Plasma concentration Z','Efficacy marker'};

% Define the names of the time independent candidate covariates that you
% would like to explore

% Continuous covariates
covNames    = {'AGE0'    'WT0'};

% Categorical covariates
catNames    = {'SEX'     'STUDYN'    'TRT'     'IND'};
% The categorical covariates STUDYN, TRT, and IND have been
% automatically added to the task dataset during its creation, based on the
% columns STUDY, TRTNAME, and INDNAME.

%% Exploration of dataset contents
% It is always of interest to see a summary of the dataset contents. In
% this section tables are generated that contain study number, study
% description, treatment groups, number of subjects, number of active
% doses, number of observations and the nominal observation time points.
% The function "IQMexploreDataContents" is used. For each combination of
% the elements in DOSENAMES and OBSNAMES a table is produced.

IQMexploreDataContents(dataTask,DOSENAMES,OBSNAMES);

% If a 4th input argument with a file name is provided, the table is
% exported to this location in a format that is suitable for reporting
% purposes later on. 

IQMexploreDataContents(dataTask,DOSENAMES,OBSNAMES,'../Output/01-DataExploration/01-DataContents');

%% Graphical exploration: comparing different datasets contents
% The goal is to perform a popPKPD modeling. We might be interested to hae
% a look at the concentration and effect data in one plot. In other cases
% we might want to compare concentration readouts for parent and
% metabolites with QT data. The function IQMexploreIndivDataRelation allows
% to plot this easily. Different readouts will be plotted in panels on top
% of each other. Plots can be generated one per subject or grouped by a
% defined GROUP column name in the dataset.

% Here we want to plot concentration on top and below the relative change
% from baseline for the effect readout. Grouping is done by TRT_NAME.
% Concentration is plotted in absolute values and the effect in relative.
% The result is stored at the provided location in the ../Output folder.
options             = [];
options.relative    = [0 1];
options.filename    = '../Output/01-DataExploration/02-PKPDdataByTreatmentGroup';
GROUP               = 'TRTNAME';
IQMexploreIndivDataRelation(dataTask,OBSNAMES,GROUP,options)

%% Repeat the comparison of PK and PD, but plot each subject 
options             = [];
options.relative    = [0 1];
options.filename    = '../Output/01-DataExploration/03-PKPDdataIndividual';
GROUP               = 'USUBJID';
IQMexploreIndivDataRelation(dataTask,OBSNAMES,GROUP,options)

%% Standard PK data exploration
% Several functions are available for the analysis of the data. Both
% graphical and statistical. For the purpose of PK analysis, some of these
% functions have been grouped into a PK exploration wrapper to more easily
% allow to generate a range of plots of interest. Here we apply it to 
% 'Plasma concentration Z'.
options = [];
options.outputPath = '../Output/01-DataExploration/04-PKwrapper';
IQMexplorePKdataWrapper(dataTask,DOSENAMES,'Plasma concentration Z',covNames,catNames,options)

%% Standard PD data exploration
% Several functions are available for the analysis of the data. Both
% graphical and statistical. For the purpose of PD data analysis, some of
% these functions have been grouped into a PD exploration wrapper to more
% easily allow to generate a range of plots of interest. The same wrapper
% can be applied to both continuous and categorical (0 and 1) readouts.
% Here we apply it to the continuous PD readout 'Efficacy marker'.
options = [];
options.outputPath = '../Output/01-DataExploration/05-PDwrapper';
IQMexplorePDdataWrapper(dataTask,DOSENAMES,'Efficacy marker','continuous',112,covNames,catNames,options)

%% Other examples for data explorations

% The function IQMdataInfoValues shows the match between columns with
% textual description and their numeric identifiers:
%   INDICATION_NAME         INDICATION
%   STUDY                   STUDYN
%   TRT_NAME                TRT
%   TRT_NAME_RANDOMIZED     TRT_RANDOMIZED
% Additionally it shows the match between VALUE and VALUE_TEXT information,
% but only for the general dataset format. In the task specific dataset
% format these information might not be present anymore.
IQMdataInfoValues(dataTask);

% The function IQMexploreBLLOQdata shows information about values below the
% LLOQ.
IQMexploreBLLOQdata(dataTask);

% Additional data analysis functions are shown below. There are more
% included in IQM Tools. All these functions fo have options and can export
% results to a file. Please have a look at the help text for these
% functions.
IQMexploreCovariateCorrelations(dataTask,covNames,catNames);
IQMexploreDataMedian(dataTask,'Efficacy marker','continuous','TRTNAME');
IQMexploreDataMedianCovariates(dataTask,'Efficacy marker','continuous',[covNames catNames],'TRTNAME');
IQMexploreDataVariability(dataTask,'Efficacy marker','TRTNAME');

%% The help text for a function is displayed in the following way:

help IQMexploreDataMedianCovariates

% Or alternatively by

doc IQMexploreDataMedianCovariates

% An overview of all IQM Tools Lite functions is obtained by:
help IQMlite
% or
doc IQMlite

% An overview of all IQM Tools Pro functions is obtained by:
help IQMpro
% or
doc IQMpro

%% Special data analysis possibilities:
% Any data analysis function in IQM tools that is provided with a dataset
% for ploting or statistical analysis can be applied to a user defined
% subset of the dataset. In this way specific parts of the data can be
% analyzed. Example: The data in your dataset extend over 2 years but you
% are interested in plotting only the profiles during day 1. Then you can
% subset your data by: data(data.TIME<=24,:) and provide this dataset as
% input to the desired plotting functions.
