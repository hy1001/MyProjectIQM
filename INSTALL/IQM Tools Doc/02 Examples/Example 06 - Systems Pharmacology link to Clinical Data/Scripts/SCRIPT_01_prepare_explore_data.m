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
IQMinitializeCompliance('SCRIPT_01_prepare_explore_data');

%% Load general dataset
data = IQMloadCSVdataset('../Data/data_general.csv');

%% Check consistency of general dataset
IQMcheckGeneralDataFormat(data);

%% Create Task specific dataset
DOSENAME = 'Glucose dose';
OBSNAMES = {'Glucose','Insulin'};

covariateInfo = {
    'Weight'    'WT0'
    'BMI'       'BMI0'
    'Gender'    'SEX'
    'Age'       'AGE0'
    'Glucose'   'GLUC0'
    'Insulin'   'INS0'
};

dataTask = IQMconvertGeneral2TaskDataset(data,DOSENAME,OBSNAMES,covariateInfo);

%% Define covariates to consider 
covNames = {'AGE0','WT0', 'BMI0','GLUC0','INS0'};
catNames = {'SEX' 'STUDYN' 'TRT'};

%% Explore data
options = [];
options.outputPath = '../Output/DataExploration';
IQMexplorePDdataWrapper(dataTask,DOSENAME,OBSNAMES,'continuous',[],covNames,catNames,options)

% Please have a look in the ../Output/DataExploration folder. It contains the results of this analysis

%% Create NLME dataset
IQMconvertTask2NLMEdataset(dataTask,DOSENAME,OBSNAMES,covNames,catNames,{},'../Data/data_NLME');

%% If an error is shown in the last step then this is OK. Please read the error message.
% The compliance mode is on. For systems pharmacology work you could switch
% it off. Or alternatively, you could perform the data cleaning steps
% manually. Here these cleaning steps are not done manually and the
% IQMconvertTask2NLMEdataset function will automatically take care of
% things that otherwise might make NONMEM crash or just not needed.
% So also if the error appeared you can continue the example ... the NLME
% dataset has been created before the error message.

