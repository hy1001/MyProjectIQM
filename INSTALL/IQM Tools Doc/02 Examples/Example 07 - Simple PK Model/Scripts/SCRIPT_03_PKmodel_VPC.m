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
IQMinitializeCompliance('SCRIPT_03_PKmodel_VPC');

%% Help text for VPC functions
help IQMcreateVPC
help IQMcreateVPCstratified
help IQMcreateVPCplot

%% Generate VPC for Theophylline Model
NLMEproject = '../Models/MODEL_MONOLIX';
% If example for script 02 completed, then uncomment folloqing column to
% use that model (otherwise '../Models/MODEL_MONOLIX' is used):
% NLMEproject = '../Models/MODEL_GEN/MODEL_06';
model       = 'Resources/modelPK.txt';
data        = '../Data/dataNLME1.csv';
IQMcreateVPC(NLMEproject,model,data)