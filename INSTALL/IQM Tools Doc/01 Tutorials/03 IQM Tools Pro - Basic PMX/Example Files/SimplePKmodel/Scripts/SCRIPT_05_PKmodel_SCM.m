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
IQMinitializeCompliance('SCRIPT_05_PKmodel_SCM');

%% Help text bootstrap functions
help IQMscm

%% Perform SCM
% For this Theophylline example this is a little bit an overkill - but it
% is a simple example. For complex ones it works just the same way

% Define candidate covariates in the dataset
covNames                    = {'WT0'};  % Continuous covariates
catNames                    = {'SEX'};  % Categorical covariates

% Define general model settings for NLME conversion
model                       = 'Resources/modelPK.txt';
dosing                      = 'Resources/dosingPK.dos';
data                        = [];
data.dataRelPathFromProject = '../../Data';
data.dataFileName           = 'dataNLME1.csv';
data.dataHeaderIdent        = IQMgetNLMEdataHeader('../Data/dataNLME1.csv',covNames,catNames);

% Define options for NLME model conversion
options                     = [];
options.errorModels         = 'comb1';

% Define SCM options
optionsSCM                  = [];
optionsSCM.covariateTests   = {
                                {'CL','WT0','SEX'} % Test WT0 and SEX on CL
                                {'Vc','WT0','SEX'} % Test WT0 and SEX on Vc
                                {'ka','WT0','SEX'} % Test WT0 and SEX on ka
                              };

% Define the path where to store all the models for the stepwise covariate search
projectPathSCM              = '../Models/SCM_Example';

options.algorithm.METHOD = 'FO';

% Run the stepwise covariate search
IQMscm('NONMEM',projectPathSCM,optionsSCM,model,dosing,data,options)

