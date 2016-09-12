%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - Advanced Clinical Trial Example
%
% In this example an advanced clinical trial simulation is performed.
% Further information about the trial simulation in in script
% SCRIPT_02_Trial_Simulation.m 
%
% SCRIPT_01_ReRun_Models
% ----------------------
% The purpose of this script is to rerun the PK and the PKPD model - which
% have been developed in the previous IQM Tools example. In the subsequent
% script these models are used for the clinical trial simulation.
%
% For more information, please contact: 
% 	Henning Schmidt
%   henning.schmidt@intiquan.com
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

%% "Initialize the compliance mode". 
IQMinitializeCompliance('SCRIPT_01_ReRun_Models');

%% Run both the PK and the PKPD model
% Both models are located in the ../Models folder. Here we use the function
% that allows to run all NLME models wihtin the same root folder. If the
% parallel toolbox is installed both models will be run in parallel.
IQMrunNLMEprojectFolder('../Models');

%% Ready, please continue with script SCRIPT_02_Trial_Simulation
