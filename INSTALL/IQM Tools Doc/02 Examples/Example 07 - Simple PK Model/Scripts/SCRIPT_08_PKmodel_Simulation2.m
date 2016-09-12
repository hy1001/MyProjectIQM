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
IQMinitializeCompliance('SCRIPT_08_PKmodel_Simulation2');

%% This is an example for a (very simple) clinical trial simulation
% In principle, IQM Tools supports clinical trial simulations of all
% complexities, but it requires the user to write a couple of lines of
% MATLAB code.
%
% IQM Tools provides functionality for :
%  - Sampling of population and individual parameters from Monolix
%    estimation results, also taking covariates into account
%  - Definition of structural models
%  - Definition of desired dosing schemes to simulate
%  - Simulation of models, dosing schemes with selected parameters
%
% Bookkeeping needs to be done manually - and it is intentionally kept this
% way, since the user should know what (s)he is doing. To many point and
% click tools out there ...
%
% Reminder: The example in the following is very very simple and just a
% teaser, allowing to show the idea.
        
%% Load the model 
% Here it is the PK model, for which parameters have been fitted
% And the results are available in ../Models/MODEL_NONMEM
model       = IQMmodel('Resources/modelPK.txt');
dosing      = IQMdosing('Resources/dosingPK.dos');

% The dosing scheme is not defining the exact doses and dosing times for
% the simulation - it is just needed to define what type of administrations
% are going to be used. Dose levels and dosing times can be changed later.

%% Define the NLME project from which to sample the parameters
NLMEproject = '../Models/MODEL_MONOLIX';

%% Definition of trial settings
% Reminder: very simple here
% We want to simulate a study with 50 subjects
Nsubjects   = 50;
% Compound given by oral bolus 12 times, once every 24 hours
DOSEtimes   = [0:1:12]*24;
% We assume we give everyone the same dose of 600mg
DOSE        = 600;
% We assume we want to calculate concentrations over 15weeks and "measure" concentrations on an hourly basis   
SIMTIME     = [0:1:15*24];
% We want to repeat the simulation 100 times to assess the impact of the
% uncertainty in the estimated PK parameters - small numbers for speed -
% remember: simple example
Ntrials     = 100;

%% This is an important step for trial simulation. You want speed for the
% simulation, therfore, we prepare the merged model with the dosing scheme
% and generate the MEX simulation model
moddos      = mergemoddosIQM(model,dosing);
IQMmakeMEXmodel(moddos,'mexModel');

%% Define the dosing scheme for simulation (it needs to have the number and types
% of inputs as the dosing scheme that was used to prepare the MEX model above)
dosing_sim  = IQMcreateDOSING('BOLUS',DOSE,DOSEtimes,[]);

%% If parallel toolbox is available then the simulation can be accelerated
% Please exchange the "8" to the number of processors that you have
% available for MATLAB
startParallelIQM(8);

%% Do the trial simulation ... its just two nested "for" loops
% Simulate Ntrials number of trials
ALL_PK_ugml = cell(1,Ntrials);
parfor ktrial=1:Ntrials,
    ktrial

    % Get individual parameters for current trial
    FLAG_SAMPLE = 1; % Sample from uncertainty and individual distributions
    output = IQMsampleNLMEfitParam(NLMEproject, FLAG_SAMPLE, Nsubjects);
    
    % Simulate current trial and collect simulated PK profiles
    for ksubject=1:Nsubjects,
        % Do the simulation ... have a look how the individual parameters
        % are passed directly to the IQMsimdosing function
        simres = IQMsimdosing('mexModel',dosing_sim,SIMTIME,[],output.parameterNames,output.parameterValuesIndividual(ksubject,:));
        % Collect the PK in ug/ml from the simulation results
        PK_ugml = simres.variablevalues(:,variableindexIQM(moddos,'Cc'));
        % Collect all individual simulations per trial
        ALL_PK_ugml{ktrial} = [ALL_PK_ugml{ktrial} PK_ugml];
    end
    
end

%% ALL_PK_ugml now contains 100 elements - one per trial
ALL_PK_ugml

%% Each element of ALL_PK_ugml contains 50 individual simulations as done above
ALL_PK_ugml{1}

%% Example for plotting data - Plot individual profiles for trial 1
figure(1); clf;
plot(SIMTIME,ALL_PK_ugml{1});

%% Example for plotting data - Plot individual profiles for trial 10
figure(2); clf;
plot(SIMTIME,ALL_PK_ugml{10});

%% Example for plotting data ... plot medians for each trial
figure(3); clf;
for k=1:Ntrials,
    data = ALL_PK_ugml{k};
    q = quantileIQM(data',[0.05 0.5 0.95]);
    % Plot median for trial k
    plot(SIMTIME,q(2,:),'-','LineWidth',1); hold on
end
    
%% Example for plotting data ... plot median and 5% and 95% quantile with 90% uncertainty across all trials
figure(4); clf;
q05 = [];
q95 = [];
q50 = [];
for k=1:Ntrials,
    data = ALL_PK_ugml{k};
    q05 = [q05; quantileIQM(data',[0.05])];
    q95 = [q95; quantileIQM(data',[0.95])];
    q50 = [q50; quantileIQM(data',[0.5])];
end
q05_q = quantileIQM(q05,[0.05 0.5 0.95]);
q95_q = quantileIQM(q95,[0.05 0.5 0.95]);
q50_q = quantileIQM(q50,[0.05 0.5 0.95]);
set(gca,'YScale','log');
IQMplotfill(SIMTIME,q50_q(1,:),q50_q(3,:),[1 0.8 0.8]); hold on
plot(SIMTIME,q50_q(2,:),'r','LineWidth',2); 
IQMplotfill(SIMTIME,q05_q(1,:),q05_q(3,:),[0.8 1 0.8]); hold on
IQMplotfill(SIMTIME,q95_q(1,:),q95_q(3,:),[0.8 0.8 1]); hold on

% some things to make the plot nicer and more informative!
axis([0 100 0.01 100]);
grid on
xlabel('Time [hours]','FontSize',14)
ylabel('Plasma concentration [ug/ml]','FontSize',14)
set(gca,'FontSize',12)
% Legend are always good! Even if MATLAB legends are not the nicest ones.
legend('Population median 90% uncertainty interval','Population median','5% Quantile 90% uncertainty interval','95% Quantile 90% uncertainty interval','Location','SouthEast')
