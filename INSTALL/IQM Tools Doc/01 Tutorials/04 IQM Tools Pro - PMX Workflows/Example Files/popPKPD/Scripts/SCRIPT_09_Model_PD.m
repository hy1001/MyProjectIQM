%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - PopPKPD Example
%
% SCRIPT_09_Model_PD
% ------------------
% In this script we will develop the PD model. We assume that the
% structural model, defined in "resources/PKPDmodel.txt' is adequate and
% mainly show how to obtain the BASE model parameters, how to do the
% covariate search for PD models (or general user defined models, rather
% than popPK models suitable for the popPK workflow), and how to get the
% final model.
%
% The focus here is not on modeling bit on how to use IQM Tools to do
% rather complex stuff easily.
%
% IMPORTANT: General PD modeling is feasible with IQM Tools. A comfortable
% workflow as for standard popPK models is not available but what is
% available is more than enough :-) ... enjoy this example.
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

PATH_IQM            = 'C:\PROJECTS\iqmtools\01 IQM Tools Suite'; 
oldpath             = pwd(); cd(PATH_IQM); installIQMtools; cd(oldpath);

%% "Initialize the compliance mode". 
IQMinitializeCompliance('SCRIPT_09_Model_PD');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Auto-generation of script for NLME model generation
% For a given IQMmodel, an IQMdosing scheme and an NLME dataset the code
% that generates a certain NLME model in NONMEM or MONOLIX can be generated
% automatically. Once generated it can be adapted by the user. The reason
% for auto-generation is that the code is quite long with many options and
% not having to type everything in the right order from scratch does really
% make sense :-)
%
% This is how it works:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define the path to the IQMmodel for which you that want to estimate
% parameters using an NLME algorithm. In this case here it is a standard
% PKPD model that we have prepared in the "resources" folder:
modelPath       = 'resources/PKPDmodel.txt';

% Define the dosing scheme which defines the type of inputs that are
% defined in the model. Here the model contains an INPUT2 - the "2" linking
% it to ADM=2 in the dataset. Administration is by IV Infusion, so the
% dosing scheme file, prepared in "resources" defines a single INPUT2 as
% infusion. The numerical values for dose and time are not important.
dosingPath      = 'resources/PKPDdosing.dos';

% Define the path to the PD modeling dataset that is in a format suitable
% for NONMEM and MONOLIX (the one we prepared in the previous script):
dataPath        = '../Data/dataNLME_popPD.csv';

% Define the path where the generated NLME project should be stored:
projectPath     = '../Models/MODEL_PD/MODEL_PD__01_BASE/MODEL_01';

% Now just run the function below
IQMcreateNLMEmodelGENcode(modelPath,dosingPath,dataPath,projectPath)

% Please have a look in the Command Window. Text has ben displayed there.
% Copy all the text out and read it through. It is highly documented and
% gives explanations. Here in this example we used this auto-generated text
% by copying it into this script here and modifying it to fit our needs.
% Below documentation is done when things have been changed differently
% from the auto-generated text.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Definition of general NLME algorithm options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
algorithm                       = [];
% General settings
algorithm.SEED                  = 123456;
algorithm.K1                    = 500;
algorithm.K2                    = 200;
algorithm.NRCHAINS              = 1;

% NONMEM specific settings
algorithm.METHOD                = 'SAEM';  % 'SAEM' (default) or 'FO', 'FOCE', 'FOCEI'
algorithm.ITS                   = 1;
algorithm.ITS_ITERATIONS        = 10;
algorithm.IMPORTANCESAMPLING    = 1;
algorithm.IMP_ITERATIONS        = 10;
algorithm.MAXEVAL               = 9999;
algorithm.SIGDIGITS             = 3;
algorithm.M4 = 0;  

% MONOLIX specific settings
algorithm.LLsetting             = 'linearization';   % or 'linearization' (default) or 'importantsampling'
algorithm.FIMsetting            = 'linearization';   % 'linearization' (default) or 'stochasticApproximation'
algorithm.INDIVparametersetting = 'conditionalMode'; % 'conditionalMode' (default) ... others not considered for now

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define names of covariates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
covNames                = {'AGE0'    'WT0'       'EFF0'};
catNames                = {'SEX'     'STUDYN'    'TRT'     'IND'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Model generation code template - MODEL01
% Documentation added only when changes from the auto generated code
% present.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

model                           = IQMmodel('resources/PKPDmodel.txt');
regressionParameters            = {'CL' 'Vc' 'Q1' 'Vp1' 'VMAX' 'KM'};
data                            = IQMloadCSVdataset('../Data/dataNLME_popPD.csv');
dataheader                      = IQMgetNLMEdataHeader(data,covNames,catNames,regressionParameters);
dosing                          = IQMdosing('resources/PKPDdosing.dos');
dataFIT                         = [];
dataFIT.dataRelPathFromProject  = '../../../../Data';
dataFIT.dataHeaderIdent         = dataheader;
dataFIT.dataFileName            = 'dataNLME_popPD.csv';

options                         = [];
% We want to model the efficacy marker. From the data exploration in
% SCRIPT_02_Data_Exploration.m we know that the baseline lies around 30.
% The efficacy model in PKPDmodel.txt is relative, so EMAX will define the
% maximum change from baseline in fraction from baseline. Based on the
% graphical exploration (..\Output\01-DataExploration\05-PDwrapper\09_Median_RR_Information.pdf)
% the relative change lies around 10%=> EMAX=0.1 is a good starting guess.
% EC50 is harder to determine an initial guess. We set it to 5x the KM
% value of the PK model. Mainly, since the KM value is expected to be close
% to 50% receptor occupancy. kout is initialized as 1/(time to
% steady-state) as shown in exploration file
% (..\Output\01-DataExploration\02-PKPDdataByTreatmentGroup.pdf). Of
% course, these are very rough guesses, but optimization basd on the data
% follows to refine them.

%                                  BASELINE  kout    EMAX    EC50
options.POPvalues0              = [30       0.01     0.1     15      ];
options.POPestimate             = [1         1       1       1       ];
options.IIVvalues0              = [0.5       0.5     0.5     0.5     ];
options.IIVestimate             = [1         1       1       1       ];

% Determination of assumed distributions of the individual parameters:
% BASELINE: 'normal' based on 12_Data_Distribution.pdf (PAGE 1)
% kout:     'lognormal' since it has to be a positive value
% EMAX:     'normal' based on 12_Data_Distribution.pdf (PAGE 4)
% EC50:     'lognormal' since supposed to be positive

options.IIVdistribution         = {'N'       'L'     'N'     'L'     };

% An additive-proportional error model does not make sense in this
% modeling. The graphical analysis (01_Individual_Summary_Linear.pdf) shows
% that the PD lines are mostly flat ... due to the high baseline in
% relation to the obtained effect. We use an additive error model.
options.errorModels             = 'const';

% The starting guesses for the additive error model is important -
% when using NONMEM. Here we set it to 5% of the baseline value: 1.5
options.errorParam0             = [1.5];

options.covarianceModel         = '';
options.covariateModel          = '';

options.Ntests                  = 1;
options.std_noise_setting       = 0;

options.algorithm               = algorithm;


% In a first step we use both NONMEM and MONOLIX. Reason is to compare the
% results of both tools. NONMEM is often faster but MONOLIX is more accurate
% numerically. If both give the same/similar results we continue in NONMEM.
% Otherwise in MONOLIX.

% Create the NONMEM model
projectPath                     = '../Models/MODEL_PD/MODEL_PD__01_BASE/MODEL_01_NONMEM';
IQMcreateNLMEproject('NONMEM',model,dosing,dataFIT,projectPath,options)

% Create the MONOLIX model
projectPath                     = '../Models/MODEL_PD/MODEL_PD__01_BASE/MODEL_01_MONOLIX';
IQMcreateNLMEproject('MONOLIX',model,dosing,dataFIT,projectPath,options)

% Run the models in parallel - instead of a single project folder, provide
% the path to the folder in which the project folders are located.
IQMrunNLMEprojectFolder('../Models/MODEL_PD/MODEL_PD__01_BASE',2)

%% Discussion of results:
% The output generated in the RESULTS folder of the model shows:
% - Both tools give approximately the same results
% - SAEM convergence trajectories suggest non identifiability of random
%   effect of at least EC50 and kout.
% - Very high shrinkage of kout, EMAX and EC50. This has to be handled with
%   care since we have about half the patients with placebo doses in the
%   dataset. To get a better shrinkage estimate one would remove the placebo
%   patients from the dataset and refit. Here easy, since no placebo model
%   considered.
% - High correlation of EC50 and EMAX (to be expected). But very low
%   variability of EMAX and higher on EC50
% - Baseline highly dependent on WT0, AGE0, and SEX. 
%
% Next steps:
% - Use MONOLIX and NONMEM again in parallel
% - Do not use a random effect on EMAX (fix to small value due to
%   use of SAEM
% - Do use WT0, AGE0, and SEX as covariates on BASE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Model generation code template - MODEL02
% Basically copy the code from above and change what you want to be changed
% - Use MONOLIX and NONMEM again in parallel
% - Do not use a random effect on EMAX (fix to small value due to
%   use of SAEM - value around estimated in MODEL_01
% - Do use WT0, AGE0, and SEX as covariates on BASE
%   Mainly to ensure population predictions are more accurate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model                           = IQMmodel('resources/PKPDmodel.txt');
regressionParameters            = {'CL' 'Vc' 'Q1' 'Vp1' 'VMAX' 'KM'};
data                            = IQMloadCSVdataset('../Data/dataNLME_popPD.csv');
dataheader                      = IQMgetNLMEdataHeader(data,covNames,catNames,regressionParameters);
dosing                          = IQMdosing('resources/PKPDdosing.dos');
dataFIT                         = [];
dataFIT.dataRelPathFromProject  = '../../../../Data';
dataFIT.dataHeaderIdent         = dataheader;
dataFIT.dataFileName            = 'dataNLME_popPD.csv';

options                         = [];
%                                  BASELINE  kout    EMAX    EC50
options.POPvalues0              = [32       0.03     0.12    20      ];
options.POPestimate             = [1         1       1       1       ];
% Fix kout to a small variability (needed for SAEM) 
options.IIVvalues0              = [9        0.4      0.04    0.85    ];
options.IIVestimate             = [1         1       2       1       ];
options.IIVdistribution         = {'N'       'L'     'N'     'L'     };
options.errorModels             = 'const';
options.errorParam0             = [1.5];
options.covarianceModel         = '';
% Do use SEX, AGE and WT0 as covariate on BASELINE
options.covariateModel          = '{BASELINE,SEX,AGE0,WT0}';
options.Ntests                  = 1;
options.std_noise_setting       = 0;
options.algorithm               = algorithm;

% Create the NONMEM model
projectPath                     = '../Models/MODEL_PD/MODEL_PD__02_BASE/MODEL_02_NONMEM';
IQMcreateNLMEproject('NONMEM',model,dosing,dataFIT,projectPath,options)

% Create the MONOLIX model
projectPath                     = '../Models/MODEL_PD/MODEL_PD__02_BASE/MODEL_02_MONOLIX';
IQMcreateNLMEproject('MONOLIX',model,dosing,dataFIT,projectPath,options)

% Run the models in parallel - instead of a single project folder, provide
% the path to the folder in which the project folders are located.
IQMrunNLMEprojectFolder('../Models/MODEL_PD/MODEL_PD__02_BASE',2)

%% Discussion of results:
% Both fits look reasonable. NONMEM seems to underestimate the variability
% in EC50. 13.5CV% seem unlikely small for a PD model. Same for kout.
% 
% Other diagnostics look fine. We decide to perform a robustness assessment
% with 4 runs from different initial guesses. Here we will only use MONOLIX.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Model generation code template - MODEL03
% Same as MODEL02 but only MONOLIX and repeat same fit from 4 different
% randomized initial guesses.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model                           = IQMmodel('resources/PKPDmodel.txt');
regressionParameters            = {'CL' 'Vc' 'Q1' 'Vp1' 'VMAX' 'KM'};
data                            = IQMloadCSVdataset('../Data/dataNLME_popPD.csv');
dataheader                      = IQMgetNLMEdataHeader(data,covNames,catNames,regressionParameters);
dosing                          = IQMdosing('resources/PKPDdosing.dos');
dataFIT                         = [];
dataFIT.dataRelPathFromProject  = '../../../../Data';
dataFIT.dataHeaderIdent         = dataheader;
dataFIT.dataFileName            = 'dataNLME_popPD.csv';

options                         = [];
%                                  BASELINE  kout    EMAX    EC50
options.POPvalues0              = [27        0.03    0.11    3.2     ];
options.POPestimate             = [1         1       1       1       ];
options.IIVvalues0              = [6         0.5     0.04    1.7     ];
options.IIVestimate             = [1         1       2       1       ];
options.IIVdistribution         = {'N'       'L'     'N'     'L'     };
options.errorModels             = 'const';
options.errorParam0             = [0.6];
options.covarianceModel         = '';
options.covariateModel          = '{BASELINE,SEX,AGE0,WT0}';
% Repeat fit 8 times from different initial guesses (0.5=50%CV in fixed
% effects that are estimated)
options.Ntests                  = 4;
options.std_noise_setting       = 0.5;
options.algorithm               = algorithm;

% Define the path in which to create the 8 models
projectPath                     = '../Models/MODEL_PD/MODEL_PD__03_BASE_ROBUSTNESS';
IQMcreateNLMEproject('MONOLIX',model,dosing,dataFIT,projectPath,options)

% Run the models in parallel - instead of a single project folder, provide
% the path to the folder in which the project folders are located.
IQMrunNLMEprojectFolder('../Models/MODEL_PD/MODEL_PD__03_BASE_ROBUSTNESS')

%% Discussion of results:
% - Very robust fits from OFV
% - Clearly EC50 not robustly identifiable
% We pick model MODEL_2 as the final base model

%% Duplication of selected BASE model to Output
modelSource         = '../Models/MODEL_PD/MODEL_PD__03_BASE_ROBUSTNESS/MODEL_2';
modelDestination    = '../Output/07-PDmodels/MODEL_PD_01_BASEMODEL';

% Need to define the folder in which the modeling dataset is located in
% relation to the modelDestination folder.
relPathData         = '../../../Data';

% Duplicate it
IQMduplicateNLMEmodel(modelSource,modelDestination,relPathData)

%% Prepare a VPC for the base model - for absolute PD readout
% Define the sratification group
GROUP           = 'TRTNAME';

% Define the path to the project that the VPC should be generated for
NLMEproject     = '../Output/07-PDmodels/MODEL_PD_01_BASEMODEL';

% Define the model 
model           = 'resources/PKPDmodel.txt';

% The dataset for the VPC needs to be defined (as MATLAB table or as string
% with path to the dataset)
dataVPC         = '../Data/dataNLME_popPD.csv';

% Define the model outputs
outputsModel    = 'PD';

% Define the data NAME to match with the output
outputsData     = 'Efficacy marker';

% Define the path to the output PDF with the VPC information
filename        = '../Output/07-PDmodels/VPC__MODEL_PD_01_BASEMODEL';

% Define options
options         = [];
options.NTRIALS = 20;

% Run the VPC function
vpcresult =  IQMcreateVPCstratified(GROUP,NLMEproject,model,dataVPC,outputsModel,outputsData,filename,options);

% When we look at this VPC we see that it is not very useful. Relative
% change from baseline would be more interesting and informative.
% This can be accomplished as follows.

%% Prepare a VPC for the base model - for relative PD change from baseline
GROUP           = 'TRTNAME';
NLMEproject     = '../Output/07-PDmodels/MODEL_PD_01_BASEMODEL';
model           = 'resources/PKPDmodel.txt';
dataVPC         = '../Data/dataNLME_popPD.csv';

% Calculate DV as relative change from baseline (EFF0) in percent
dataVPC                 = IQMloadCSVdataset(dataVPC);
ix_PD                   = find(dataVPC.YTYPE==1);
dataVPC.DV(ix_PD)       = 100*(dataVPC.DV(ix_PD)-dataVPC.EFF0(ix_PD))./dataVPC.EFF0(ix_PD);
dataVPC.UNIT(ix_PD)     = {'% baseline'};

% Define the model output which calculate the relative change from baseline
outputsModel            = 'PD_rel';

outputsData     = 'Efficacy marker';
filename        = '../Output/07-PDmodels/VPC__MODEL_PD_01_BASEMODEL_relative_change';
options         = [];
options.NTRIALS = 20;
vpcresult =  IQMcreateVPCstratified(GROUP,NLMEproject,model,dataVPC,outputsModel,outputsData,filename,options);

% The VPC looks acceptable. The reason why no simulation bands are shown in
% the placebo groups is because no placebo disease model is present -
% excpet that PD remains at baseline under no treatment.

%% Next steps:
% An additional covariate of interest might be IND=3 based on the
% ETA vs. COV plots for the final base model.
% Assessment of covariance does not seem reasonable, since except EMAX and
% EC50 nothing seems to be correlated - and in the case of EMAX the
% variability is so small (and fixed) that correlation is not important to
% assess.
% Other models - for example effect on output or hill coefficient and more
% complex disease models could be investigated. It all would boil down to
% write a new PKPDmodel2/3/4/5...txt model and rerun the procedure from
% above. The names of the model files are arbitary and you can select them.
%
% If there would be more covariate information, a stepwise covariate search
% could be performed by the function IQMscm. And a bootstrap by
% IQMbootstrap. No magic.
%
% Here we decide that the final model is the final base model.

%% Duplication of selected FINAL model to Output
modelSource         = '../Output/07-PDmodels/MODEL_PD_01_BASEMODEL';
modelDestination    = '../Output/07-PDmodels/MODEL_PD_02_FINALMODEL';

% Need to define the folder in which the modeling dataset is located in
% relation to the modelDestination folder.
relPathData         = '../../../Data';

% Duplicate it
IQMduplicateNLMEmodel(modelSource,modelDestination,relPathData)

% You can repeat the VPC ... but not really needed, since it is the same
% model.

%% As last step we prepare a table with the parameter estimates for the FINAL model
% Table with base and final model only
projectPaths =  {
                    '../Output/07-PDmodels/MODEL_PD_02_FINALMODEL'
                };
IQMfitsummaryTable(projectPaths,'../Output/07-PDmodels/TABLE_MODEL_PD_02_FINALMODEL');

% That's it! Only remains to simulate the PKPD model for a dosing regimen
% of interest. Given then the EC50 is highly uncertain such simulations are
% dangerous and we avoid this here. It is the subject of a different
% example.
