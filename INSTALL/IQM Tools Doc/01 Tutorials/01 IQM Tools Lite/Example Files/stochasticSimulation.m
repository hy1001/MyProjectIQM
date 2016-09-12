%% This is a first cell that clears workspace and memory
% Press Ctrl+enter to evaluate it
clear all; clc;

%% Load the stochexample.txtbc model
% This loads a model that is based on the model published in: 
% Unified phototransduction model from Hamer et al., Visual 
% Neuroscience 22, 417-436. The model has been modified considerably 
% to test the rhodopsin shut-off kinetics.
model = IQMmodel('stochexample.txtbc')

%% Have a look at the model
edit stochexample.txtbc

% Model editing can be done directly in the MATLAB editor.
% The cell-mode allows to reload the model easily by just executing the
% previous cell again. No re-typing of "model = SBmodel('stochexample.txtbc')" 
% is required.

%% Setting simulation options
time = 20;    % max. simulation time
volume = [];  % species given in number => volume does not need to be defined 
              % this is different if species given in concentration. Then 
              % the kinetic rate constants have to be converted
units = [];   % order of magnitude of concentration units (not used since here we use molecule numbers
runs = 3;     % perform 3 runs
Nsample = 1;  % each reaction event is reported (can be quite memory consuming. 
              % set higher if computer starts to swap to disk)

%% Run the simulation (with plotting of the average results)
% Used method: Gillespie SSA
IQMstochsim(model,time,volume,units,runs,Nsample)

%% Run the simulation (returning the values from the "runs" realizations and the average value)
output = IQMstochsim(model,time,volume,units,runs,Nsample)

%% More information can be obtained by typing (also about the required
% format of the model.
help IQMstochsim
