%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - Advanced Clinical Trial Example
%
% In this example we want to perform a clinical trial simulation with a
% standard parallel design:
%
% 5 arms will be considered:
%   - Placebo   q4w IV
%   - 0.5mg/kg  q4w IV
%   - 1.5mg/kg  q4w IV
%   - 5mg/kg    q8w IV 
%   - 15mg/kg   q8w IV
%
% PD assessments will be done at times: 0,4,8,12,16,24 weeks
%
% Number of subjects per arm: 10 
%
% Population: 
%   - 5 males and 5 females per arm
%   - Weight distribution:
%       - Male:     mean: 80kg, std: 12kg
%       - Female:   mean: 65kg, std: 14kg
%   - Age distribution:
%       - Male:     mean: 60years, std: 15years
%       - Female:   mean: 55years, std: 15years
%   No correlation assumed between weight and age
%
% 100 trials are simulated. For each trial population parameters are
% sampled from the uncertainty distribution and a new set of patients is
% sampled from the defined distributions of Weight and Age.
%
% Of interest in this simulation is the predicted relative change from
% baseline of the PD readout.
%
% At the end of the simulation a simple example plot is done for a single
% trial and a single group within this trial. There could be tons of
% different post processings of this trial simulation and corresponding
% graphical representations. This example, however, is not about the
% postprocessing and the graphics. It is mainly about how a clinical trial
% simulation can be performed with IQM Tools.
%
% This is a reasonably simple example to explain how clinical trial
% simulation could be done with IQM Tools.
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
IQMinitializeCompliance('SCRIPT_02_Trial_Simulation');

%% Define trial settings

% Number of trials
Ntrials                 = 100; 

% Define dose groups per trial
GroupsDOSE              = [0 0.5 1.5 5 15];     % mg/kg

% Define dosing intervals
GroupsDOSINGINTERVAL    = [4 4 4 8 8]*7;        % Days

% Last dose time
LAST_DOSE_TIME          = 24*7;                 % Days

% Define infusion time
TINF                    = 2/24;                 % Two hours in day unit

% Define number of subjects per dose group
% Half of subjects assumed male, half female. So please use even numbers :-)
Nsubjects               = [10 10 10 10 10];     % Subjects per dose group

% Define observation time for PD readout in days
OBSTIMES               = [0 4 8 12 16 24]*7;   % Days

% Other observation schedules do not require generation of new simulation
% datasets ... just provide a different time vector. Example (if
% uncommented):
% OBSTIMES               = [0:1:24]*7;   % Days

% Define population
WT0_MALE_MEAN           = 80;                   % kg
WT0_MALE_STD            = 12;                   % kg
WT0_FEMALE_MEAN         = 65;                   % kg
WT0_FEMALE_STD          = 14;                   % kg
AGE0_MALE_MEAN          = 60;                   % years
AGE0_MALE_STD           = 15;                   % years
AGE0_FEMALE_MEAN        = 55;                   % years
AGE0_FEMALE_STD         = 15;                   % years

% Define NLME models to sample parameters from 
PKfitNLME               = '../Models/MODEL_PK_FINALMODEL';
PDfitNLME               = '../Models/MODEL_PD_FINALMODEL';

% Define additive error based on PD model fit
% If the simulated readout of the PD part should take into account
% measurement uncertainty, please define a value different from 0 below. A
% reasonable value is the error model parameter from the PD NLME fit, which
% is used here:
add_error_std           = 0.626;

%% Load model and dosing objects, prepare MEX simulation function for fast simulation
model                   = IQMmodel('resources/PKPDmodel.txt');
dosing                  = IQMdosing('resources/PKPDdosing.dos');
moddos                  = mergemoddosIQM(model,dosing);
IQMmakeMEXmodel(moddos,'mexModel');

%% Enable parallel computation (if parallel toolbox available)
startParallelIQM()
    
%% Cycle through Ntrials trial simulations and collect the results
% Initialize simulation result variable
trialsimulationResult = [];
for ktrial=1:Ntrials,
    ktrial
    
    % Cycle through the different dose groups for single trial
    for kgroup=1:length(GroupsDOSE),
        
        % Define the population properties in this group
        NR_SUBJECTS_GROUP                       = Nsubjects(kgroup);
        % Define a column vector with 1 for male and 2 for female - handle
        % potentially odd subject numbers.
        SEX                                     = NaN(NR_SUBJECTS_GROUP,1);
        SEX(1:ceil(NR_SUBJECTS_GROUP/2))        = 1;
        SEX(ceil(NR_SUBJECTS_GROUP/2+1):end)    = 2;
        % Define a column vector with sampled weights - first 5 for male
        % and last 5 for female. In order to handle odd numbers
        % for subjects in groups we first set all to male and then the
        % rounded last half to female.
        WT0                                     = NaN(NR_SUBJECTS_GROUP,1);
        WT0(1:ceil(NR_SUBJECTS_GROUP/2))        = WT0_MALE_MEAN + WT0_MALE_STD*randn(ceil(NR_SUBJECTS_GROUP/2),1);
        WT0(ceil(NR_SUBJECTS_GROUP/2+1):end)    = WT0_FEMALE_MEAN + WT0_FEMALE_STD*randn(NR_SUBJECTS_GROUP-ceil(NR_SUBJECTS_GROUP/2),1);
        % Define a column vector with sampled ages - first 5 for male
        % and last 5 for female. In order to handle odd numbers
        % for subjects in groups we first set all to male and then the
        % rounded last half to female.
        AGE0                                    = NaN(NR_SUBJECTS_GROUP,1);
        AGE0(1:ceil(NR_SUBJECTS_GROUP/2))       = AGE0_MALE_MEAN + AGE0_MALE_STD*randn(ceil(NR_SUBJECTS_GROUP/2),1);
        AGE0(ceil(NR_SUBJECTS_GROUP/2+1):end)   = AGE0_FEMALE_MEAN + AGE0_FEMALE_STD*randn(NR_SUBJECTS_GROUP-ceil(NR_SUBJECTS_GROUP/2),1);
        
        % Ensure positive values - would code that differently in real life. This is just an example. Due
        % to the sampling above the AGE0 and WT0 actually can become negative ...
        AGE0                                        = abs(AGE0);
        WT0                                         = abs(WT0);
        
        % Sample PK and PD model parameters for the subjects in this grup by sampling first population parameters
        % from the uncertainty distributions and then individual parameters
        % from these population parameters, taking the sampled covariates
        % into account
        FLAG_SAMPLE                             = 1;
        PKresults                               = IQMsampleNLMEfitParam(PKfitNLME,FLAG_SAMPLE,NR_SUBJECTS_GROUP,{'WT0'},WT0,{'SEX'},SEX);
        PDresults                               = IQMsampleNLMEfitParam(PDfitNLME,FLAG_SAMPLE,NR_SUBJECTS_GROUP,{'WT0','AGE0'},[WT0 AGE0],{'SEX'},SEX);
        
        % Postprocess the sampled PK parameters. The PK model was built using the popPK workflow in IQM Tools.
        % This means that the NLME fit contains additional parameters that
        % are not used in the model. These need to be removed.
        % In this case the PK parameters CL, Vc, Q1, Vp1, VMAX, and KM need to
        % be available for the PKPD model. These correspond to elements
        % 1,2,3,4,11, and 12 in the PK model fit.
        PKresults.parameterNames                = PKresults.parameterNames([1 2 3 4 11 12]);
        PKresults.parameterValuesIndividual     = PKresults.parameterValuesIndividual(:,[1 2 3 4 11 12]);
        PKresults.parameterValuesPopulation     = PKresults.parameterValuesPopulation([1 2 3 4 11 12]);
        
        % Simulate subject in the current group
        % Do this subject simulation in parallel if parallel toolbox
        % available
        PK_group                                = NaN(length(OBSTIMES),1);
        PD_group                                = NaN(length(OBSTIMES),1);
        PDrel_group                             = NaN(length(OBSTIMES),1);
        parfor ksubject = 1:NR_SUBJECTS_GROUP,
            % Define the subjects dosing scheme (weight based dosing - so
            % it needs to be generated for each subject)
            DOSE                                = GroupsDOSE(kgroup)*WT0(ksubject);
            DOSINGTIME                          = [0:GroupsDOSINGINTERVAL(kgroup):LAST_DOSE_TIME];
            dosing_sim                          = IQMcreateDOSING('INFUSION',DOSE,DOSINGTIME,TINF);
          
            % Simulate individual subject
            simresults_individual               = IQMsimdosing('mexModel',dosing_sim,OBSTIMES,[],[PKresults.parameterNames PDresults.parameterNames],[PKresults.parameterValuesIndividual(ksubject,:) PDresults.parameterValuesIndividual(ksubject,:)]);
            PK                                  = simresults_individual.variablevalues(:,variableindexIQM(moddos,'Cc'));
            PD                                  = simresults_individual.statevalues(:,stateindexIQM(moddos,'PD'));
            
            % Add "measurement noise" to PD using additive error model
            PD_noise                            = PD + add_error_std*randn(length(PD),1);
            
            % Calculate the relative change from baseline in percent
            BASELINE_noise                      = PD_noise(1);
            PDrel_noise                         = 100*(PD_noise-BASELINE_noise)/BASELINE_noise;

            % Collect group simulations
            PK_group(:,ksubject)                = PK;
            PD_group(:,ksubject)                = PD_noise;
            PDrel_group(:,ksubject)             = PDrel_noise;
        end
        % Store trial simulation information
        trialsimulationResult(ktrial).trial                     = ktrial;
        trialsimulationResult(ktrial).OBSTIMES                  = OBSTIMES;
        trialsimulationResult(ktrial).group(kgroup).group       = kgroup;
        trialsimulationResult(ktrial).group(kgroup).dose_mgkg   = GroupsDOSE(kgroup);
        trialsimulationResult(ktrial).group(kgroup).PK          = PK_group;
        trialsimulationResult(ktrial).group(kgroup).PD          = PD_group;
        trialsimulationResult(ktrial).group(kgroup).PDrel       = PDrel_group;
    end
end

%% It is good practice to close the parallel connection again once calculationa are done
stopParallelIQM()
    
%% Plot the results of the simulation

% Select the number of the trial and the number of the group for which you
% would like to plot the results:
NRTRIAL = 1;    % First trial
NRGROUP = 5;    % 5th group (15mg/kg)

% Plot simulated PK, PD and relative PD as change from baseline in percent
% Male subjects are plotted in blue, female subjects in red
figure(NRTRIAL); clf;
subplot(3,1,1);
plot(trialsimulationResult(NRTRIAL).OBSTIMES,trialsimulationResult(NRTRIAL).group(NRGROUP).PK(:,1:ceil(NR_SUBJECTS_GROUP/2)),'b.-','MarkerSize',20); hold on
plot(trialsimulationResult(NRTRIAL).OBSTIMES,trialsimulationResult(NRTRIAL).group(NRGROUP).PK(:,ceil(NR_SUBJECTS_GROUP/2)+1:end),'r.-','MarkerSize',20)
grid on
set(gca,'XLim',[min(OBSTIMES) max(OBSTIMES)]);
try, set(gca,'YLim',[0 max(max(trialsimulationResult(NRTRIAL).group(NRGROUP).PK))]); end
set(gca,'FontSize',12)
ylabel('PK [ug/ml]','FontSize',12)
title(sprintf('Trial: %d, Dose: %gmg/kg q%dw',NRTRIAL,GroupsDOSE(NRGROUP),GroupsDOSINGINTERVAL(NRGROUP)/7));

subplot(3,1,2);
plot(trialsimulationResult(NRTRIAL).OBSTIMES,trialsimulationResult(NRTRIAL).group(NRGROUP).PD(:,1:ceil(NR_SUBJECTS_GROUP/2)),'b.-','MarkerSize',20); hold on
plot(trialsimulationResult(NRTRIAL).OBSTIMES,trialsimulationResult(NRTRIAL).group(NRGROUP).PD(:,ceil(NR_SUBJECTS_GROUP/2)+1:end),'r.-','MarkerSize',20)
grid on
set(gca,'XLim',[min(OBSTIMES) max(OBSTIMES)]);
try, set(gca,'YLim',[min(min(trialsimulationResult(NRTRIAL).group(NRGROUP).PD)) max(max(trialsimulationResult(NRTRIAL).group(NRGROUP).PD))]); end
set(gca,'FontSize',12)
ylabel('PD [mm]','FontSize',12)

subplot(3,1,3);
plot(trialsimulationResult(NRTRIAL).OBSTIMES,trialsimulationResult(NRTRIAL).group(NRGROUP).PDrel(:,1:ceil(NR_SUBJECTS_GROUP/2)),'b.-','MarkerSize',20); hold on
plot(trialsimulationResult(NRTRIAL).OBSTIMES,trialsimulationResult(NRTRIAL).group(NRGROUP).PDrel(:,ceil(NR_SUBJECTS_GROUP/2)+1:end),'r.-','MarkerSize',20)
grid on
set(gca,'XLim',[min(OBSTIMES) max(OBSTIMES)]);
try, set(gca,'YLim',[min(min(trialsimulationResult(NRTRIAL).group(NRGROUP).PDrel)) max(max(trialsimulationResult(NRTRIAL).group(NRGROUP).PDrel))]); end
set(gca,'FontSize',12)
ylabel('Relative PD [%]','FontSize',12)
xlabel('Time [Days]','FontSize',12)

% Many different analyses could be done ... depending on what it the
% question of interest. This example was more about how a clnical trial
% simulation can be performed in IQM Tools. Not so much about the
% postprocessing.

%% As final step: remove the temporary mex model file
clear mex
delete(['mexModel.' mexext]);