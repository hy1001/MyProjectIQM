%% Installation of IQM Tools
% This block should always be on the top of every analysis script with IQM
% Tools. It might only be ommitted in the case that a central installation
% of IQM Tools is present on the computer system and the IQM Tools are
% automatically loaded during the startup of MATLAB.
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
IQMinitializeCompliance('SCRIPT_02_model');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate code to generate models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
modelPath                       = 'resources/model.txt';
dosingPath                      = 'resources/dosing.dos';
dataPath                        = '../Data/data_NLME.csv';
projectPath                     = '../Models/MODEL_01';
IQMcreateNLMEmodelGENcode(modelPath,dosingPath,dataPath,projectPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Algorithm settings
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
covNames = {'AGE0','WT0', 'BMI0','GLUC0','INS0'};
catNames = {'SEX' 'STUDYN' 'TRT'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Model generation - MODEL_01 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model                           = IQMmodel('resources/model.txt');
regressionParameters            = {};
data                            = IQMloadCSVdataset('../Data/data_NLME.csv');
dataheader                      = IQMgetNLMEdataHeader(data,covNames,catNames,regressionParameters);
dosing                          = IQMdosing('resources/dosing.dos');
dataFIT                         = [];
dataFIT.dataRelPathFromProject  = '../../Data';
dataFIT.dataHeaderIdent         = dataheader;
dataFIT.dataFileName            = 'data_NLME.csv';
options                         = [];

%                                  Gb      Ib      VG      kaG     kG1     kG2     p1      p2      p3      p4
options.POPvalues0              = [5       7       10      0.05    0.2     0.2     0.04    0.02    0.06    0.25    ];
options.POPestimate             = [1       1       1       1       1       1       1       1       1       1       ];
options.IIVvalues0              = [0.5     0.5     0.5     0.5     0.5     0.5     0.5     0.5     0.5     0.5     ];
options.IIVestimate             = [1       1       1       1       1       1       1       1       1       1       ];
options.IIVdistribution         = {'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     };

options.errorModels             = 'comb1,comb1';
options.errorParam0             = [1,0.3,1,0.3];

options.covarianceModel         = '';
options.covariateModel          = '';

options.Ntests                  = 1;
options.std_noise_setting       = 0;

options.algorithm               = algorithm;

projectPath                     = '../Models/MODEL_01';
IQMcreateNLMEproject('MONOLIX',model,dosing,dataFIT,projectPath,options)

%% Run this model
IQMrunNLMEproject(projectPath)

%% Run also in NONMEM
projectPath                     = '../Models/MODEL_01_NONMEM';
IQMcreateNLMEproject('NONMEM',model,dosing,dataFIT,projectPath,options)
IQMrunNLMEproject(projectPath)

%% Generate table
IQMfitsummaryTable({'../Models/MODEL_01_NONMEM','../Models/MODEL_01'},'../Output/MODEL_01_Table');

%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%% COMPARE RESULTS of both models ... quite different. Which parameter estimation software is right???
%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%% Just looking at the goodness-of-fit plots for both model runs shows that MONOLIX does a MUCH better
% job in fitting the data than NONMEM. Note: settings for algorithms are identical, dataset is identical, 
% and in both cases the SAEM algorithm has been used.  


%% Discussion of the MONOLIX results (NONMEM results would not allow this conclusion and would leave us standing in the rain trying 
% out all different combinations of random effects ... time consuming):
% - kG1 and kG2 estimted with high uncertainty ... at least the random effects should not be estimated (keep fixed on small values)
% - keep only add error model for Insulin and Glucose 

%% Update model and rerun
%                                  Gb      Ib      VG      kaG     kG1     kG2     p1      p2      p3      p4
options.POPvalues0              = [4.8     6.7     16.6    0.058   1.56    3.68    0.013   0.0045  0.133   1.82    ];
options.POPestimate             = [1       1       1       1       1       1       1       1       1       1       ];
options.IIVvalues0              = [0.5     0.5     0.5     0.5     0.05    0.05    0.5     0.5     0.5     0.5     ];
options.IIVestimate             = [1       1       1       1       2       2       1       1       1       1       ];
options.IIVdistribution         = {'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     };

options.errorModels             = 'prop,prop';
options.errorParam0             = [0.3,0.3];

projectPath                     = '../Models/MODEL_02';
IQMcreateNLMEproject('MONOLIX',model,dosing,dataFIT,projectPath,options)
IQMrunNLMEproject(projectPath)

%% Discussion of results:
% - kG1 and kG2 might not be identifiable ... only 1 compartment for glucose? 

%% Update model without second glucose compartment (kG1=kG2=0 fixed ... set to 1e-10 since division by kG2 in initial condition would lead to Inf)
%                                  Gb      Ib      VG      kaG     kG1     kG2     p1      p2      p3      p4
options.POPvalues0              = [4.8     6.7     16.6    0.058   1e-10   1e-10   0.013   0.0045  0.133   1.82    ];
options.POPestimate             = [1       1       1       1       0       0        1       1       1       1       ];
options.IIVvalues0              = [0.5     0.5     0.5     0.5     0       0      0.5     0.5     0.5     0.5     ];
options.IIVestimate             = [1       1       1       1       0       0        1       1       1       1       ];
options.IIVdistribution         = {'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     };

options.errorModels             = 'prop,prop';
options.errorParam0             = [0.3,0.3];

projectPath                     = '../Models/MODEL_03';
IQMcreateNLMEproject('MONOLIX',model,dosing,dataFIT,projectPath,options)
IQMrunNLMEproject(projectPath)

%% Results: 1 cpt for Glucose seems enough ... but random effect on p1 not identifiable!

%% Update model without random effect on p1
%                                  Gb      Ib      VG      kaG     kG1     kG2     p1      p2      p3      p4
options.POPvalues0              = [4.8     6.7     16.6    0.058   1e-10   1e-10   0.013   0.0045  0.133   1.82    ];
options.POPestimate             = [1       1       1       1       0       0        1       1       1       1       ];
options.IIVvalues0              = [0.5     0.5     0.5     0.5     0       0     0.05     0.5     0.5     0.5     ];
options.IIVestimate             = [1       1       1       1       0       0        2       1       1       1       ];
options.IIVdistribution         = {'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     'L'     };

options.errorModels             = 'prop,prop';
options.errorParam0             = [0.3,0.3];

%% Now run this model also in NONMEM - should work better now
projectPath                     = '../Models/MODEL_04_NONMEM';
IQMcreateNLMEproject('NONMEM',model,dosing,dataFIT,projectPath,options)
IQMrunNLMEproject(projectPath,8)

%% Interestingly parameters seem to be very similar between NONMEM and MONOLIX but the DV vs. IPRED plots for Glucose are still far off!

%% Add covariates according to ETA vs COV plots:
%       - BMI0 on Gb, Ib, VG, p1, p2, p4

%                                  Gb      Ib      VG      kaG     kG1     kG2     p1      p2      p3      p4
options.POPvalues0              = [4.8     6.7     26.6    0.058   1e-10   1e-10   0.013   0.0025  0.133   1.82    ];

options.covariateModel          = '{Gb,BMI0},{Ib,BMI0},{VG,BMI0},{p1,BMI0},{p2,BMI0},{p4,BMI0}';

projectPath                     = '../Models/MODEL_04_BMI0';
IQMcreateNLMEproject('MONOLIX',model,dosing,dataFIT,projectPath,options)
IQMrunNLMEproject(projectPath)

%% Discussion of results
% - BMI0 on VG and p1 not significant ... 
% - Might want to remove random effect on p1 as well ...

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Here we change kG2=1 ... second compartment is switched off by kG1=1e-10.
% And model simulation for VPC not possible if kG2=1e-10 (interpreted as 0
% and then division by 0 happens in initial conditions).
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%                                  Gb      Ib      VG      kaG     kG1     kG2     p1      p2      p3      p4
options.POPvalues0              = [4.8     6.7     26.6    0.058   1e-10   1       0.013   0.0025  0.133   1.82    ];
options.IIVvalues0              = [0.5     0.5     0.5     0.5     0       0       0.05     0.5     0.5     0.5     ];
options.IIVestimate             = [1       1       1       1       0       0        2       1       1       1       ];

options.covariateModel          = '{Gb,BMI0},{Ib,BMI0},{p2,BMI0},{p4,BMI0}';

projectPath                     = '../Models/MODEL_05_BMI0';
IQMcreateNLMEproject('MONOLIX',model,dosing,dataFIT,projectPath,options)
IQMrunNLMEproject(projectPath)

% Looks reasonable ...

% This is not an example in perfect model building ... just in using IQM Tools ...

%% VPC
GROUP           = 'TRT';
NLMEproject     = '../Models/MODEL_05_BMI0';

IQMcreateVPCstratified(GROUP,NLMEproject,model,data,'','','../Output/VPC_MODEL_05_BMI0');

