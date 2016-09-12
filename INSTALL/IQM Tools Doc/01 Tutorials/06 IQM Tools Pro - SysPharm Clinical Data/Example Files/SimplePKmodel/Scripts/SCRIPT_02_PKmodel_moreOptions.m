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
IQMinitializeCompliance('SCRIPT_02_PKmodel_moreOptions');

%% Generate code to generate an NLME model with most of the options 
% available to IQMcreateNLMEproject
modelPath   = 'Resources/modelPK.txt';
dosingPath  = 'Resources/dosingPK.dos';
dataPath    = '../Data/dataNLME1.csv';
projectPath = '../Models/MODEL_GEN';
IQMcreateNLMEmodelGENcode(modelPath,dosingPath,dataPath,projectPath)

