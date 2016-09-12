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
IQMinitializeCompliance('SCRIPT_07_PKmodel_Simulation');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQMtrialGroupSimulation
% High level simulation funtion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

help IQMtrialGroupSimulation

%% Run a simulation 
% Define the underlying structural model 
model           = 'Resources/modelPK.txt';
% Define a dosing regimen with 6 doses, spaced by 24 hours
dosing          = IQMcreateDOSING('BOLUS',800,[0:24:5*24],[]);
% Define the NLME model to use for sampling of parameters
NLMEproject     = '../Models/MODEL_NONMEM';
% Define an hourly observation schedule for 9 days
OBSTIME         = [0:1:8*24];
% Run the simulation
output          = IQMtrialGroupSimulation(model,dosing,NLMEproject,OBSTIME)

%% Plot results
figure(1); clf;
plot(output.time,output.quantilesData_uncertainty{2}(:,2)); hold on
IQMplotfill(output.time,output.quantilesData_uncertainty{1}(:,2),output.quantilesData_uncertainty{3}(:,2),[0 0 1],0.1);
grid on;
set(gca,'FontSize',12);
xlabel('Time [Hours]','FontSize',14);
ylabel('Simulated Concentrations [ug/ml]','FontSize',14);
legend('Population Median','90% Variability')

%% Many options can be set in IQMtrialGroupSimulation
% Please read the documentation:

doc IQMtrialGroupSimulation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQMsampleNLMEfitParam
% Sampling parameters from an NLME project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

doc IQMsampleNLMEfitParam

%% Sample individual parameters, taking into account the uncertainty distribution
NLMEproject     = '../Models/MODEL_NONMEM';
FLAG_SAMPLE     = 1;    % Sample population parameters from the uncertainty distribution
Nsamples        = 100;  % Sample 100 individual subject parameter sets from the sampled population parameters
IQMsampleNLMEfitParam(NLMEproject,FLAG_SAMPLE,Nsamples)

%% The IQMsampleNLMEfitParam function can take into account continuous and categorical covariates when 
% sampling parameters. Please read the help text of this function - it is straight forward!

doc IQMsampleNLMEfitParam
