%% PK modeling example for the IQM Tools Tutorial

%% Installation of IQM Tools
clc;                        % Clear command window
clear all;                  % Clear workspace from all defined variables
close all;                  % Close all figures
fclose all;                 % Close all open files
restoredefaultpath();       % Clear all user installed toolboxes

% In the next line, please enter the path to your IQM Tools folder. It can
% be a relative or an absolute path.
PATH_IQM            = 'c:\PROJECTS\iqmtools\01 IQM Tools Suite'; 
oldpath             = pwd(); cd(PATH_IQM); installIQMtools; cd(oldpath);

%% Initialize the compliance mode
IQMinitializeCompliance('SCRIPT_01_PKmodel');

%% Define minimally needed information for NLME model generation
model                       = 'Resources/modelPK.txt';
dosing                      = 'Resources/dosingPK.dos';
data                        = [];
data.dataRelPathFromProject = '../../Data';
data.dataFileName           = 'dataNLME1.csv';
data.dataHeaderIdent        = IQMgetNLMEdataHeader('../Data/dataNLME1.csv');

%% Generate a MONOLIX model
projectPath                 = '../Models/MODEL_MONOLIX';
IQMcreateNLMEproject('MONOLIX',model,dosing,data,projectPath)

%% Generate a NONMEM model
projectPath                 = '../Models/MODEL_NONMEM';
IQMcreateNLMEproject('NONMEM',model,dosing,data,projectPath)

%% Run MONOLIX and NONMEM model one after the other
IQMrunNLMEproject('../Models/MODEL_MONOLIX')
IQMrunNLMEproject('../Models/MODEL_NONMEM')

%% Alternatively, run all models in the same folder in parallel
IQMrunNLMEprojectFolder('../Models')   


%% Create a table with model results for both models
IQMfitsummaryTable({'../Models/MODEL_MONOLIX' '../Models/MODEL_NONMEM'},'../Output/Model_Result_Table')


