%% This is a first cell that clears workspace and memory
% Press Ctrl+enter to evaluate it
clear all; clc;

%% Load the CellCycle.txt model
model = IQMmodel('CellCycle.txt')

%% Simulate using the IQMsimulate command of the IQM Tools
% IQMsimulate(model,400)
% IQMsimulate(model,[0:1:400])
IQMsimulate(model,'ode45',[0:2:400])             % simulate and plot
output = IQMsimulate(model,'ode45',[0:2:400])    % simulate and return values

%% Learn more about the IQMsimulate calling syntax:
help IQMsimulate

%% Create a MATLAB ODE m-file from the IQMmodel
IQMcreateODEfile(model,'odefile')

%% Simulate the ODE file (no conversion overhead due to creation of ODE file)
tic;
[t,x] = ode15s('odefile',[0:1:400],odefile);
TIMEODE15S = toc
plot(t,x)

%% Using IQMPsimulate for simulation (IQMmodel=>MEXmodel=>Simulation)
IQMPsimulate(model,[0:1:400])

%% Create MEX simulation function
IQMmakeMEXmodel(model,'mexmodel')

%% Simulate the ODE file (no conversion overhead due to compilation of MEX files)
tic;
output = mexmodel([0:1:400]);
TIMEMEX = toc
plot(output.time,output.statevalues)

%% Calculate speed up MEX vs. ODE15S
MEX_is_timesfaster = TIMEODE15S/TIMEMEX

%% Simulate model with different initial conditions
initialConditions = ones(1,13);

% Simulate with MATLAB integrators
IQMsimulate(model,'ode45',[0:2:400],initialConditions)

% Convert to C and compile on the fly then simulate with MEX simulation function
IQMPsimulate(model,[0:2:400],initialConditions)

% Simulate already compiled MEX model
IQMPsimulate('mexmodel',[0:2:400],initialConditions)

%% Simulate model with different parameter settings
parameterNames = IQMparameters(model) % List the parameters that are in the model
parameterNamesChange  = {'k1','V25p'};
parameterValuesChange = [0.1  0.3];
initialConditions     = []; % Use default initial conditions as stored in the model
IQMPsimulate('mexmodel',[0:2:400],initialConditions,parameterNamesChange,parameterValuesChange)

%% Conclusion:
% When repeated simulations are necessary (sensitivity analysis, parameter
% estimation, etc.) it is good to first create MEX simulation functions and
% subsequently to use these to do the simulations, avoiding the
% conversion and compilation overhead. Parameters and initial conditions
% can be changed by giving these information as input arguments to MEX
% simulation functions. More information can be found here:

help IQMmakeMEXmodel

help IQMPsimulate

