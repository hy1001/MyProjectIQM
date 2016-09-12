%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - PopPKPD Example
%
% SCRIPT_07_Simulation_PK
% -----------------------
% The purpose of this script is to perform some simulations with the final
% popPK model.
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
IQMinitializeCompliance('SCRIPT_07_Simulation_PK');

%% The goal here is to perform some few simulations of the final popPK model

%% First simulation: Different IV regimen 1 and 3 mg/kg in male subjects only

% Define from which NLME project to get the parameters for simulation
NLMEproject       0      = '../Output/04-PKmodels/MODEL_PK_03_FINALMODEL';

% Define FACTOR_UNITS (as used for model building)
FACTOR_UNITS            = 1;

% No first order absorption - set to empty.
dosing_abs1             = [];

% Define IV regimen of interest
dosing_iv.TIME          = [0    28    56    84];
dosing_iv.DOSE          = [1     1     3     3];
dosing_iv.TINF          = [1/24];
dosing_iv.SCALING       = 'WT0';
% The SCALING argument allows to implement weight based dosing. It requires
% to provide the input argument COVARIATE_DATA which at least includes the
% 'WT0' column.

% Define the observation times for the simulation
OBSTIME                 = [0:1:120];

% Define covariate data to simulate - here make it simple, just simulate
% only male subjects with a weight of 80kg.
COVARIATE_DATA          = table();
COVARIATE_DATA.WT0      = [80]';
COVARIATE_DATA.SEX      = [1]';

% Define options
options                 = [];
options.NSUBJECTS       = 20;
options.NTRIALS         = 50;

% Export results to a figure
options.filename        = '../Output/05-PKmodel_simulation/Simulation_01';

% Do the simulation
IQMsimulatePopPKmodel(NLMEproject,FACTOR_UNITS,dosing_abs1,dosing_iv,OBSTIME,COVARIATE_DATA,options);

%% Second simulation - use the same settings as above but take the covariates
% from the modeling dataset

COVARIATE_DATA          = '../Data/dataNLME_popPK.csv';

% Export results to a figure
options.filename        = '../Output/05-PKmodel_simulation/Simulation_02';

% Do the simulation
IQMsimulatePopPKmodel(NLMEproject,FACTOR_UNITS,dosing_abs1,dosing_iv,OBSTIME,COVARIATE_DATA,options);

