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
IQMinitializeCompliance('SCRIPT_06_PKmodel_Model_Comparison');

%% Help text bootstrap functions
help IQMcompareModels

%% Perform Model Comparison
% Define the NLME models to compare
projectFolders  = {'../Models/MODEL_NONMEM','../Models/MODEL_MONOLIX'};
% Define the underlying structural model 
models          = 'Resources/modelPK.txt';
% Define the output of the model to compare
output          = 'Cc';

% Define a dosing regimen with 6 doses, spaced by 24 hours
dosing          = IQMcreateDOSING('BOLUS',800,[0:24:5*24],[]);

% Define an hourly observation schedule for 9 days
obsTimes        = [0:1:8*24];

% Run the model comparison
IQMcompareModels(projectFolders,models,output,dosing,obsTimes)


