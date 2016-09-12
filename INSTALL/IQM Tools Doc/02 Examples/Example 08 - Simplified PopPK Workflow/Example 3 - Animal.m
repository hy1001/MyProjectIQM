%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simplified PopPK Workflow - Animal Data Example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 0: Installation of IQM Tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;                        % Clear command window
clear all;                  % Clear workspace from all defined variables
close all;                  % Close all figures
fclose all;                 % Close all open files
restoredefaultpath();       % Clear all user installed toolboxes
PATH_IQM            = 'c:\PROJECTS\iqmtools\01 IQM Tools Suite'; 
oldpath             = pwd(); cd(PATH_IQM); installIQMtools; cd(oldpath);
IQMinitializeCompliance('Example 1 - Theophylline.m');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 1: Define information needed for the simplified popPK workflow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputPath                      = 'Example 3';

simplifiedPopPKInfo             = [];
simplifiedPopPKInfo.dataPath    = 'OriginalData/EX3_simanimal.csv';
simplifiedPopPKInfo.nameDose    = 'ABCD12 Dose';
simplifiedPopPKInfo.namePK      = 'ABCD12 Concentration';

simplifiedPopPKInfo = IQMsimplifiedPopPKinit( outputPath, simplifiedPopPKInfo );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 2: Sanity check if general data format is correct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IQMsimplifiedPopPKcheckData(outputPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 3: Standard graphical exploration of the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IQMsimplifiedPopPKexploreData(outputPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 4: Data cleaning and NLME data generation step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IQMsimplifiedPopPKgetNLMEdata(outputPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 5: Do some simple popPK base model assessment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IQMsimplifiedPopPKmodel(outputPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Following steps: refine the model based on previous results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add DOSE as covariate on Q1 and Vp1
nameSpace                       = 'MODEL_02_BASE';
modeltest                       = [];
modeltest.numberCompartments    = [2];
modeltest.covariateModels       = {'','{Q1,DOSE},{Vp1,DOSE}'};
modeltest.POPvalues0            = [];
%                                 CL        Vc    Q1    Vp1    Q2    Vp2    Fiv      Fabs1        ka    TlagAbs1   Fabs0      Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0          = [ 0.0257    0.115 0.068 49.2   1     1      1        1            0.277 1          1          1     1          0.5     1      1];

IQMsimplifiedPopPKmodel(outputPath,nameSpace,modeltest)

%% Remove Random Effect on CL - keep covariates
nameSpace                       = 'MODEL_03_BASE';
modeltest                       = [];
modeltest.numberCompartments    = [2];
modeltest.covariateModels       = '{Q1,DOSE},{Vp1,DOSE}';
modeltest.POPvalues0            = [];
%                                 CL        Vc    Q1    Vp1    Q2    Vp2    Fiv      Fabs1        ka    TlagAbs1   Fabs0      Tk0   TlagAbs0   Frel0   VMAX   KM
modeltest.POPvalues0          = [ 0.0257    0.115 0.068 49.2   1     1      1        1            0.277 1          1          1     1          0.5     1      1];
modeltest.IIVestimate         = [ 0         1     1     1      1     1      0        0            1     1          0          1     1          1       1      1];

IQMsimplifiedPopPKmodel(outputPath,nameSpace,modeltest)
