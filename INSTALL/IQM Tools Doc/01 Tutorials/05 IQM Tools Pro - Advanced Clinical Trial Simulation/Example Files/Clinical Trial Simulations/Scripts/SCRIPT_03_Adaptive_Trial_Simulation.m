%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - Advanced Clinical Trial Example
%
% In this example we want to perform an adaptive clinical trial simulation.
% The following doses will be considered:
%
% 5 arms will be considered:
%   - Placebo   q4w IV
%   - 0.5mg/kg  q4w IV
%   - 1.5mg/kg  q4w IV
%   - 5mg/kg    q8w IV 
%   - 15mg/kg   q8w IV
%
% All subjects are started on the lowest dose level (placebo). 
% If at next dosing time point a subject does not show an increase of 3% 
% in the PD readout (relative to baseline) then the subject is added to the
% next higher dose group.
%
% Total number of subjects: 50
%
% Population: 
%   - 25 males and 25 females
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
% baseline of the PD readout and the number of subjects in each dose group
% at the end of the study.
%
% This is a reasonably simple example to explain how clinical trial
% simulation could be done with IQM Tools. The focus is on the simulation
% itself, not so much on the postprocessing of the results and their
% graphical display.
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
IQMinitializeCompliance('SCRIPT_03_Adaptive_Trial_Simulation');

%% Define trial settings

% Number of trials
Ntrials                 = 100; 

% Define dose groups per trial
GroupsDOSE              = [0 0.5 1.5 5 15];     % mg/kg

% Define dosing intervals
GroupsDOSINGINTERVAL    = [4 4 4 8 8]*7;        % Days

% Define endtime of study (last simulation timepoint)
ENDTIME                 = 36*7;                 % Days (36 weeks in days)

% Define infusion time
TINF                    = 2/24;                 % Two hours in day unit

% Define total number of subjects
% Half of subjects assumed male, half female. So please use even numbers :-)
Nsubjects               = 50;     % Subjects per dose group

% Define observation time for PD readout in days
OBSTIMES               = [0:4*7:ENDTIME];       % Days (observations every 4th week)
% For more dense simulation results, you can change the simulation time vector
% OBSTIMES               = [0:1:ENDTIME];         % Days

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

% Define threshold for uptitration
% If at given dose time the change from baseline is not higher than this
% threshold then subject is moved to next higher dose group
THRESHOLD_PD            = 3; % percent

%% Load model and dosing objects, prepare MEX simulation function for fast simulation
model                   = IQMmodel('resources/PKPDmodel.txt');
dosing                  = IQMdosing('resources/PKPDdosing.dos');
moddos                  = mergemoddosIQM(model,dosing);
IQMmakeMEXmodel(moddos,'mexModel');

% % Through uncommenting the following code you could use parallel
% processing if the parallel toolbox is available. We do not do that here,
% since it will allow checking of simulations - for example purposes later.
% %% Enable parallel computation (if parallel toolbox available)
% startParallelIQM();

%% Cycle through Ntrials trial simulations and collect the results
% Initialize simulation result variable
trialsimulationResult                           = [];
for ktrial=1:Ntrials,
    ktrial

    % Define a column vector with 1 for male and 2 for female - handle
    % potentially odd subject numbers.
    SEX                                         = NaN(Nsubjects,1);
    SEX(1:ceil(Nsubjects/2))                    = 1;
    SEX(ceil(Nsubjects/2+1):end)                = 2;
    % Define a column vector with sampled weights - first 5 for male
    % and last 5 for female. In order to handle odd numbers
    % for subjects in groups we first set all to male and then the
    % rounded last half to female.
    WT0                                         = NaN(Nsubjects,1);
    WT0(1:ceil(Nsubjects/2))                    = WT0_MALE_MEAN + WT0_MALE_STD*randn(ceil(Nsubjects/2),1);
    WT0(ceil(Nsubjects/2+1):end)                = WT0_FEMALE_MEAN + WT0_FEMALE_STD*randn(Nsubjects-ceil(Nsubjects/2),1);
    % Define a column vector with sampled ages - first 5 for male
    % and last 5 for female. In order to handle odd numbers
    % for subjects in groups we first set all to male and then the
    % rounded last half to female.
    AGE0                                        = NaN(Nsubjects,1);
    AGE0(1:ceil(Nsubjects/2))                   = AGE0_MALE_MEAN + AGE0_MALE_STD*randn(ceil(Nsubjects/2),1);
    AGE0(ceil(Nsubjects/2+1):end)               = AGE0_FEMALE_MEAN + AGE0_FEMALE_STD*randn(Nsubjects-ceil(Nsubjects/2),1);
    
    % Ensure positive values - would code that differently in real life. This is just an example. Due
    % to the sampling above the AGE0 and WT0 actually can become negative ...
    AGE0                                        = abs(AGE0);
    WT0                                         = abs(WT0);
    
    % Sample PK and PD model parameters for the subjects in this grup by sampling first population parameters
    % from the uncertainty distributions and then individual parameters
    % from these population parameters, taking the sampled covariates
    % into account
    FLAG_SAMPLE                                 = 1;
    PKresults                                   = IQMsampleNLMEfitParam(PKfitNLME,FLAG_SAMPLE,Nsubjects,{'WT0'},WT0,{'SEX'},SEX);
    PDresults                                   = IQMsampleNLMEfitParam(PDfitNLME,FLAG_SAMPLE,Nsubjects,{'WT0','AGE0'},[WT0 AGE0],{'SEX'},SEX);
    
    % Postprocess the sampled PK parameters. The PK model was built using the popPK workflow in IQM Tools.
    % This means that the NLME fit contains additional parameters that
    % are not used in the model. These need to be removed.
    % In this case the PK parameters CL, Vc, Q1, Vp1, VMAX, and KM need to
    % be available for the PKPD model. These correspond to elements
    % 1,2,3,4,11, and 12 in the PK model fit.
    PKresults.parameterNames                    = PKresults.parameterNames([1 2 3 4 11 12]);
    PKresults.parameterValuesIndividual         = PKresults.parameterValuesIndividual(:,[1 2 3 4 11 12]);
    PKresults.parameterValuesPopulation         = PKresults.parameterValuesPopulation([1 2 3 4 11 12]);
       
    % Assign all subjects to the first (lowest) dose group
    GROUPING_SUBJECTS                           = [[1:Nsubjects]' [1*ones(1,Nsubjects)]'];
    
    % Do simulations for the adaptive trial design
    for ksubject = 1:Nsubjects,
        % Get PK and PD parameters for this subject
        PKparam_names                           = PKresults.parameterNames;        
        PKparam_values                          = PKresults.parameterValuesIndividual(ksubject,:); 
        PDparam_names                           = PDresults.parameterNames;          
        PDparam_values                          = PDresults.parameterValuesIndividual(ksubject,:); 
        
        % Set timecounter
        TIME                                    = 0;
        % Set dose counter
        NRDOSE                                  = 0;
        
        % Set TIMEVECTOR and PDVECTORs for collecting results
        TIMEVECTOR                              = [];
        PDVECTOR_NOISE                          = [];
        PDVECTORREL_NOISE                       = [];
        TIMEVECTOR_DOSE                         = [];
        DOSEVECTOR                              = [];
        
        % Get sampled PD baseline
        PDbaseline                              = PDparam_values(1);
        
        % Get group index in which the subject is in
        ixGroup                                 = GROUPING_SUBJECTS(ksubject,2);
        
        % Get initial conditions 
        IC                                      = [0 0 PDbaseline];
                
        % Run adaptive loop until time above ENDTIME
        while TIME<=ENDTIME,
            % Based on group get the dose in mg/kg and the interval
            dose_mg_kg                          = GroupsDOSE(ixGroup);
            dose_interval                       = GroupsDOSINGINTERVAL(ixGroup);
            
            % Define dosing scheme - single dose, since each dose interval
            % is simulated independently
            DOSE                                = dose_mg_kg*WT0(ksubject);
            DOSING_TIME                         = 0;
            dosing_sim                          = IQMcreateDOSING('INFUSION',DOSE,DOSING_TIME,TINF);
            
            % Simulate subject over the current dose interval
            % Simulation here done with provided initial conditions. Since
            % the stepwise simulation requires changes in initial
            % conditions. 
            SIMTIME                             = [0:1:dose_interval];
            simresults_individual               = IQMsimdosing('mexModel',dosing_sim,SIMTIME,IC,[PKparam_names PDparam_names],[PKparam_values PDparam_values]);
            PK                                  = simresults_individual.variablevalues(:,variableindexIQM(moddos,'Cc'));
            PD                                  = simresults_individual.statevalues(:,stateindexIQM(moddos,'PD'));
   
            % Add "measurement noise" to PD using additive error model
            PD_noise                            = PD + add_error_std*randn(length(PD),1);
            
            % Calculate the relative change from baseline in percent
            PDrel_noise                         = 100*(PD_noise-PDbaseline)/PDbaseline;

            % Collect results
            if NRDOSE==0,
                TIMEVECTOR                      = [TIMEVECTOR SIMTIME];
                PDVECTOR_NOISE                  = [PDVECTOR_NOISE PD_noise'];
                PDVECTORREL_NOISE               = [PDVECTORREL_NOISE PDrel_noise'];
            else
                TIMEVECTOR                      = [TIMEVECTOR TIME+SIMTIME(2:end)];
                PDVECTOR_NOISE                  = [PDVECTOR_NOISE PD_noise(2:end)'];
                PDVECTORREL_NOISE               = [PDVECTORREL_NOISE PDrel_noise(2:end)'];
            end
            
            % Collect dose information (time and dose)
            TIMEVECTOR_DOSE                     = [TIMEVECTOR_DOSE TIME];
            DOSEVECTOR                          = [DOSEVECTOR DOSE];
            
            % Handle checking of PD change and potential change of dose group
            PDrel_noise_nextDose                = PDrel_noise(end);
            dose_old                            = dose_mg_kg;
            
            % Check increase against threshold
            if PDrel_noise_nextDose < THRESHOLD_PD,
                % Increase the group index. Max is the maximum number of
                % available groups.
                ixGroup                         = min(ixGroup+1,length(GroupsDOSE));
            else
                % Stay on current dose
                ixGroup                         = ixGroup;
            end
            
            % Record changes in dose level
            GROUPING_SUBJECTS(ksubject,NRDOSE+3) = ixGroup;
            
            % Increment TIME and DOSE counter
            TIME                                = TIME + dose_interval;
            NRDOSE                              = NRDOSE + 1;
            
            % Determine new initial conditions for next interval simulation
            IC                                  = simresults_individual.statevalues(end,:);
            
            % Determine PD values at observation time points
            [A,ix_PD_TIME]                      = intersect(TIMEVECTOR,OBSTIMES);
            PD_observed                         = PDVECTOR_NOISE(ix_PD_TIME);
            PDrel_observed                      = PDVECTORREL_NOISE(ix_PD_TIME);
        end
        
%         % Uncomment the following for monitoring the simulation
%         figure(1); clf;
%         subplot(2,1,1);
%         plot(OBSTIMES/7,PDrel_observed,'b.-','MarkerSize',20); hold on;
%         plot(get(gca,'XLim'),THRESHOLD_PD*[1 1],'k--');
%         for k=1:length(TIMEVECTOR_DOSE),
%             plot(TIMEVECTOR_DOSE(k)*[1 1]/7,get(gca,'YLim'),'k--');
%         end            
%         set(gca,'XLim',[0 ENDTIME/7]);
%         ylabel('Rel PD observation [%]','FontSize',12);
%         
%         subplot(2,1,2);
%         plot(TIMEVECTOR_DOSE/7,DOSEVECTOR/WT0(ksubject),'b.-','MarkerSize',20); hold on;
%         for k=1:length(TIMEVECTOR_DOSE),
%             plot(TIMEVECTOR_DOSE(k)*[1 1]/7,get(gca,'YLim'),'k--');
%         end         
%         set(gca,'XLim',[0 ENDTIME/7]);
%         xlabel('Time [Weeks]','FontSize',12);
%         ylabel('Dose Group [mg/kg]','FontSize',12);
%         pause

        % Collect trial simulation information
        trialsimulationResult(ktrial).trial                                 = ktrial;
        trialsimulationResult(ktrial).subject(ksubject).subject             = ksubject;
        trialsimulationResult(ktrial).subject(ksubject).OBSTIMES            = OBSTIMES;
        trialsimulationResult(ktrial).subject(ksubject).PD_observed         = PD_observed;
        trialsimulationResult(ktrial).subject(ksubject).PDrel_observed      = PDrel_observed;
        trialsimulationResult(ktrial).subject(ksubject).TIMEVECTOR_DOSE     = TIMEVECTOR_DOSE;
        trialsimulationResult(ktrial).subject(ksubject).DOSEVECTOR_MGKG     = DOSEVECTOR/WT0(ksubject);
    end
end

%% Postprocess the trial simulation results and do some plots
% These are very basic - obviously, many analyses could be done - depending
% on the question to address. The purpose of this example is mainly to show
% how to do an reasonably complex adaptive trial simulation with IQM Tools.

% In the following we would like to assess the number of subjects in the
% different dose groups at the end of the trials. Additionally some
% statistics on the relative PD change in this groups.

%% First get information about each subject in each trial regarding the last
% dose group and the relative change of the PD at ENDTIME.
LAST_DOSE_GROUP                                 = NaN(Ntrials,Nsubjects);
PDrel_ENDTIME                                   = NaN(Ntrials,Nsubjects);
for ktrial=1:Ntrials,
    trialresults                                = trialsimulationResult(ktrial);
    for ksubject=1:length(trialresults.subject),
        subject                                 = trialresults.subject(ksubject);
        LAST_DOSE_GROUP(ktrial,ksubject)        = subject.DOSEVECTOR_MGKG(end);
        PDrel_ENDTIME(ktrial,ksubject)          = subject.PDrel_observed(subject.OBSTIMES==ENDTIME);
    end
end

%% Determine median and std of subject numbers in the different dose groups at ENDTIME
NR_SUBJECTS_GROUPS = NaN(Ntrials,length(GroupsDOSE));
for ktrial=1:Ntrials,
    trialinfo                                   = LAST_DOSE_GROUP(ktrial,:);
    for kdose=1:length(GroupsDOSE),
        NR_SUBJECTS_GROUPS(ktrial,kdose)        = sum(trialinfo==GroupsDOSE(kdose));
    end
end
medianNumbers                                   = median(NR_SUBJECTS_GROUPS);
stdNumber                                       = std(NR_SUBJECTS_GROUPS);
tableCell                                       = {'<TT>', sprintf('Number of subjects in the different dose groups at the end of the trials (Ntrials=%d)',Ntrials), '', ''};
tableCell(end+1,:)                              = {'<TH>' 'Dose (mg/kg)' 'Median subject number' 'Standard deviation across trials'};
for k=1:length(medianNumbers),
    tableCell{end+1,1}                          = '<TR>';
    tableCell{end,2}                            = GroupsDOSE(k);
    tableCell{end,3}                            = medianNumbers(k);
    tableCell{end,4}                            = stdNumber(k);
end
disp(IQMconvertCellTable2ReportTable(tableCell,'text'))
    
%% Determine median and std of change of PD from baseline in percent in the different dose groups at ENDTIME
% Here it is done VERY simply ... I know ... it coud be much more 
% elaborated. No time ... its an example for trial simulation ... not a
% guide on how to postprocess results.
PD_SUBJECTS_GROUPS = NaN(Ntrials,length(GroupsDOSE));
for ktrial=1:Ntrials,
    GROUPinfo                                   = LAST_DOSE_GROUP(ktrial,:);
    PDinfo                                      = PDrel_ENDTIME(ktrial,:);
    for kdose=1:length(GroupsDOSE),
        PD_SUBJECTS_GROUPS(ktrial,kdose)        = median(PDinfo(GROUPinfo==GroupsDOSE(kdose)));
    end
end
medianPD                                        = nanmedianIQM(PD_SUBJECTS_GROUPS);
stdPD                                           = nanstdIQM(PD_SUBJECTS_GROUPS);
tableCell                                       = {'<TT>', sprintf('Median change of PD in percent from baseline in the different dose groups at the end of the trials (Ntrials=%d)',Ntrials), '', ''};
tableCell(end+1,:)                              = {'<TH>' 'Dose (mg/kg)' 'Median of median change in each trial' 'Standard deviation of median across trials'};
for k=1:length(medianNumbers),
    tableCell{end+1,1}                          = '<TR>';
    tableCell{end,2}                            = GroupsDOSE(k);
    if isnan(medianPD(k)),
        tableCell{end,3}                        = 'No information';
        tableCell{end,4}                        = 'No information';
    else
        tableCell{end,3}                        = medianPD(k);
        tableCell{end,4}                        = stdPD(k);
    end
end
disp(IQMconvertCellTable2ReportTable(tableCell,'text'))

%% As final step: remove the temporary mex model file
clear mex
delete(['mexModel.' mexext]);

