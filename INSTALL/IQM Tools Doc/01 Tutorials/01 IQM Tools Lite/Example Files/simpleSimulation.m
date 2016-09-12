%% This is a first cell that clears workspace and memory
% Press Ctrl+enter to evaluate it
clear all; clc;

%% Load the CellCycle.txt model
model = IQMmodel('CellCycle.txt')

%% Simulate using the SBsimulate command of the SBTOOLBOX2
%SBsimulate(model,400)
%SBsimulate(model,[0:1:400])
IQMsimulate( model )
IQMsimulate(model,'ode45',[0:2:400])             % simulate and plot
output = IQMsimulate(model,'ode45',[0:2:400])    % simulate and return values

%% Learn more about the SBsimulate calling syntax:
help IQMsimulate

%% Create a MATLAB ODE m-file from the SBmodel
IQMcreateODEfile(model,'odefile')

%% Simulate the ODE file (no conversion overhead due to creation of ODE file)
tic;
[t,x] = ode15s('odefile',[0:1:400],odefile);
TIMEODE15S = toc
plot(t,x)

%% Simulate model with different initial conditions
initialConditions = ones(1,13);
IQMsimulate(model,'ode45',[0:2:400],initialConditions)

%% Get parameters
parameterNames = IQMparameters(model) 

%% Same function to change parameters in a model
modelnew = IQMparameters(model,{'k1','V25p'},[0.1  0.3]) % List the parameters that are in the model

%% Simulate model with changed parameters
IQMsimulate(modelnew,'ode45',[0:1:50])

