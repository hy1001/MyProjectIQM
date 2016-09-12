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
IQMinitializeCompliance('SCRIPT_04_PKmodel_BOOTSTRAP');

%% Help text bootstrap functions
help IQMbootstrap

%% Generate Bootstrap
projectPath = '../Models/MODEL_NONMEM';
% If example for script 02 completed, then uncomment folloqing column to
% use that model (otherwise '../Models/MODEL_NONMEM' is used):
% projectPath         = '../Models/MODEL_GEN/MODEL_06';   % Model to bootstrap
options             = [];
options.path        = '../Models/Bootstrap_Example';    % Path to store the models and the output
options.NSAMPLES    = 24;       % For the example a low number of samples
options.GROUP       = 'SEX';    % Stratify by SEX ... keep male/female numbers the same
IQMbootstrap(projectPath,options)
