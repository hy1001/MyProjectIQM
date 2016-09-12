%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - PopPKPD Example
%
% SCRIPT_08_Data_PD_Conversion
% ----------------------------
% The purpose of this script is to prepare the PD modeling dataset. Here we
% use sequential PKPD modeling. So we will add the individual PK parameters
% into the PD dataset and then focus on PD modeling. Additionally, the PD
% modeling data need to be cleaned somewhat - as shown and discussed below.
%
% Additionally, summary level information is generated for the final
% cleaned popPD dataset. 
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
IQMinitializeCompliance('SCRIPT_08_Data_PD_Conversion');

%% Load the task specific dataset format
dataTask = IQMloadCSVdataset('../Data/dataTask_Example.csv');

%% Define task specific information
DOSENAME    = 'Dose Z';

% Define NAME of PD observation
OBSNAME     = 'Efficacy marker';

% Continuous covariates
covNames    = {'AGE0'    'WT0'       'EFF0'};

% Categorical covariates
catNames    = {'SEX'     'STUDYN'    'TRT'     'IND'};

%% General Data Cleaning for PD modeling
% The general data cleaning performs several steps that are typically
% always required:
% 1) IQMcleanRemoveRecordsSUBJECTs          - removes manually selected records and subjects
% 2) IQMselectDataEvents                    - keeps only selected dose and observation
% 3) IQMcleanRemoveIGNOREDrecords           - removes ignored records by IGNORE column
% 4) IQMcleanRemoveSubjectsNoObservations   - removes subjects without PD observations
% 5) IQMcleanRemoveZeroDoses                - removes doses with 0 amount
% 6) IQMcleanImputeCovariates               - imputes covariates - continuous to the median, categorical to 99999 
% 7) Removes all observation records that are set to MDV=1
%
% The function used for all this (IQMcleanPopPDdataWrapper) is suitable if
% single dose and single PD readout considered. If multiple readouts then
% the user might need to use the different functions themselves to
% accomplish some cleaning.

% Please provide the indices of the PD records that you wish to remove from
% the analysis and the reason why. These indices correspond to the of the
% row in the dataset (-1 due to the header). These indices are also
% displayed as IX# in the individual plots when using the
% IQMexplorePDdataWrapper function (see file
% Output\01-DataExploration\05-PDwrapper\01_Individual_Summary_Linear.pdf
% or 02_Individual_Single_Linear.pdf).
%
% If nothing is to be removed then set to removeREC = {};

removeREC       = {
 %  IX in data          Reason
};

% Please provide the USUBJIDs of the subjects that you wish to remove from
% the analysis and the reason why. If nothing is to be removed then set to
% removeSUBJECT = {};

removeSUBJECT   = {
 %  USUBJID             Reason
};

% Please provide the path of the output folder where you wish the cleaning
% log files for each sub function to be created.
outputPath      = '../Output/06-DataCleaning_PD';

% Run the data cleaning
dataClean       = IQMcleanPopPDdataWrapper(dataTask,DOSENAME,OBSNAME,covNames,catNames,removeSUBJECT,removeREC,outputPath);

%% Handling of observations below the lower limit of quantification
% Omitted here, since no LLOQ information - but it basically works as shown
% in SCRIPT_03_Data_PK_Conversion.

%% Generate summary statistics
% Create a table with information about studies, treatment groups, number
% of active doses and number of PK observations for the cleaned dataset.
filename = '../Output/03-SummaryStatistics_PK_modeling_Data/01-DataContents';
IQMexploreDataContents(dataClean,DOSENAME,OBSNAME,filename);

% Generate a table with summary statistics for thre cleaned dataset.
filename = '../Output/03-SummaryStatistics_PK_modeling_Data/02-SummaryStatistics';
IQMexploreSummaryStats(dataClean,covNames,catNames,filename);

%% Updating the dataset with correct ADM values for linking to the model.
% It is important to link the dosing input in the desired PKPD models to
% the correct ADM value in the dataset. In the popPK workflow IV
% administrations have a default of ADM=2, linking to INPUT2 in the model.
% INPUT1 and ADM=1 is for first order absorption.
%
% Since we only had IV data for the PK it does not make sense to include
% the first order absorption part into the PD model (although that would be
% possible). We decide to use INPUT1 as IV and remove the absorption part. 
% See an example model in resources/PKPDmodel.txt and the associated dosing
% definition in resources/PKPDdosing.dos.
%
% This means that in the dataClean dataset we need to update ADM for all
% doses to ADM=1 to make the correct link between model and data.
%
% Currently the ADM values are set as follows:
IQMinfoNLMEdata(dataClean)

% Update ADM for all doses to 1
dataClean.ADM(dataClean.ADM==2) = 1;

% Check if it is done
IQMinfoNLMEdata(dataClean)

% Ok, it is done.

%% Augmentation of dataset with individual PK parameters as regression parameters
% and generation of an NLME dataset for running with NONMEM and MONOLIX
%
% This requires several steps:

% Step 1: Loading a candidate PKPD model. This PKPD model needs to be an
% IQMmodel and contain the PK model equations to be used with the same PK
% parameter names as the ones estimated in the PK models. Here these are
% the parameters: CL, Vc, Q1, Vp1, VMAX, KM. These need to be defined as
% regression parameters in the model. The PD part in the model is of no
% importance at the moment. It can be present or absent or be in any form.
% The main goal here is to get the PK parameters into the dataset.

% Before defining this model, please check which INPUT definitions should
% be present and how these should be used. For this use the function
% IQMinfoNLMEdata to see which ADM values are present in the dataset and to
% which routes and doses these corresponds. Please use the INPUT*
% accordingly in your model.
IQMinfoNLMEdata(dataClean)

% Load the model
model               = IQMmodel('resources/PKPDmodel.txt');

% Step 2: Loading a dosing scheme, defining the dosing into the model and
% making the link afterwards for the input for the NLME modeling software.
dosing              = IQMdosing('resources/PKPDdosing.dos');

% Step 3: Defining the PK model from which to take the individual PK
% parameters. Subjects for which no PK parameters have been estimated
% obtain the population estimates (possible adjusted based on the covariate
% model in the PK model and the covariates stored in the dataset).
PKprojectPath       = '../Output/04-PKmodels/MODEL_PK_03_FINALMODEL';

% Step 4: Run the function IQMaddIndivRegressionParamFromNLMEproject
[data_with_regression_param,regressionNames] = IQMaddIndivRegressionParamFromNLMEproject(dataClean,model,dosing,PKprojectPath);

% Provide a path and name for your popPK NLME modeling dataset:
filename = '../Data/dataNLME_popPD.csv';

% Convert and export the NLME dataset
IQMconvertTask2NLMEdataset(data_with_regression_param,DOSENAME,OBSNAME,covNames,catNames,regressionNames,filename);

% Please have a careful look at the output of the previous function. It
% shows something like:
%
% NLME dataset generation: Mapping between ADM and ROUTE for the doses:
%       NAME      ROUTE    ADM
%     ________    _____    ___
% 
%     'Dose Z'    'iv'     1  
% 
% NLME dataset generation: Mapping between OBSNAMES and YTYPE:
%           NAME           YTYPE
%     _________________    _____
% 
%     'Efficacy marker'    1    
%
% This means that in your model the IV dose should be implemented as
% INPUT1 and the output of the PD model should be implemented as OUTPUT1.
%
% Thats it! - Not too complicated :-)
