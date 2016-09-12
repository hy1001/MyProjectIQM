%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - PopPKPD Example
%
% SCRIPT_01_Data_Preparation
% --------------------------
% The purpose of this script is to generate a dataset in the general data
% format that is used by IQM Tools (see the specification below) and to
% convert it to a task specific dataset.
%
% The general dataset format contains clinically relevant information in an
% informative and humanly understandable structure. It is independent of a
% specific modeling tool or a software.
%
% Based on this general dataset format a task specific dataset format will
% be generated, from which subsequently, NLME tool specific datasets are
% created.
%
% For more information, please contact: 
% 	Henning Schmidt
%   henning.schmidt@intiquan.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Specification of general dataset format:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COLUMN                SHORT COLUMN        TYPE 		DESCRIPTION
% -------------------------------------------------------------------------
% IXGDF                                     numeric     Column containing numeric indices for each record (1,2,3,4,5, ...) 
%                                                       to allow for matching records in case of postprocessing the general dataset format
% IGNORE                                    string		Reason/comment related to exclusion of the sample/observation from the analysis
% USUBJID                                   string  	Unique subject identifier
% COMPOUND                                  string		Name of the investigational compound 
% STUDY                                     string		Study number
% STUDYDES                                  string		Study description
% PART                                      string		Part of study as defined per protocol (1 if only one part)
% EXTENS                                    numeric 	Extension of the core study (0 if not extension, 1 if extension)   
% CENTER                                    numeric		Center number
% SUBJECT                                   string      Subject identifier (within a center - typically not unique across whole dataset)
% INDNAME                                   string		Indication name   
% TRTNAME                                   string		Name of actual treatment given
% TRTNAMER                                  string 		Name of treatment to which individual was randomized
% VISIT                                     numeric		Visit number
% VISNAME                                  string		Visit name
% BASE                                      numeric		Flag indicating assessments at baseline 
%                                                       (=0 for non-baseline, =1 for first baseline, =2 for second baseline, etc.)
% SCREEN                                    numeric 	Flag indicating assessments at screening
%                                                       (=0 for non-screening, =1 for first screening, =2 for second screening, etc.)
% DATEDAY                                   string		Start date of event ('01-JUL-2015')
% DATETIME                                  string		Start time of event ('09:34')   
% DURATION                                  numeric		Duration of event in same time units as TIMEUNIT
% NT                                        numeric 	Planned time of event. Based on protocol, in the time unit defined in TIMEUNIT column
% TIME                                      numeric 	Actual time of event relative to first administration, in the time unit defined in TIMEUNIT column
% TIMEUNIT                                  string 		Unit of all numerical time definitions in the dataset ('hours','days', or 'weeks')
% TYPENAME                                  string		Unique type of event
% NAME                                      string 		Unique name for the event 
% VALUE                                     numeric  	Value of the event, defined by NAME. E.g., the given dose, the observed PK concentration, 
%                                                       or the value of other readouts. The values need to be in the units, defined in the UNIT column.
%                                                       Specific cases:
%                                                           - For concomitant medications the dose will be given
%                                                           - For BLOQ values, 0 will be used
% 										                    - Severity levels for adverse events
%                                                       Should not be populated if VALUE_TEXT is populated
% VALUETXT                                  string		Text version of value (if available and useful)
%                                                       Character value as given in the CRF.
%                                                       Should not be populated if VALUE is populated
% UNIT              	                    string		Unit of the value reported in the VALUE column. For same event the same unit has to be used across the dataset.
% ULOQ          		                    numeric		Upper limit of quantification of event defined by NAME     
% LLOQ               	                    numeric		Lower limit of quantification of event defined by NAME     
% ROUTE              	                    string		Route of administration (iv, subcut, intramuscular, intraarticular, oral, inhaled, topical, rectal)
% INTERVAL                                  numeric		Interval of dosing, if single row should define multiple dosings
% NRDOSES                                   numeric 	Number of doses given with the specified interval, if single row should define multiple dosings
% COMMENT                                   string 		Additional information for the observation/event
%                                                       For example:
%                                                           - For PK: concatenation of DMPK flag to exclude or not the PK from the 
%                                                                     DMPK analysis and comment for each sample (e.g., if the sample is 
%                                                                     flagged as 'Excluded' than this word should be a prefix to the comment)
%                                                           - For adverse events concatenation of the seriousness and if the AE is drug related or not
%                                                           - For an imputation, it should mention 'Imputed'.
%
% The general data format might also contain the following columns, which
% are numeric equivalents to some string columns. If not provided, then
% these can be generated automatically by using the command
% IQMconvertGeneral2TaskDataset.
%
% IND:              Numeric indication flag (unique for each entry in INDNAME)
% STUDYN:           Numeric study flag (unique for each entry in STUDY)
% TRT:              Numeric actual treatment flag (unique for each entry in TRTNAME)
% TRTR:             Numeric randomized treatment flag (unique for each entry in TRTNAMER)
%
% Any number of additional columns can be added to this general format if
% the user wishes. Additional covariates, flags, etc.

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
% IQM Tools allows to automatically generate logfiles for all output that
% is generated using the functions "IQMprintFigure" and
% "IQMwriteText2File". These logfiles contain the username, the name of the
% generated file (including the path), and the scripts and functions that
% have been called to generate the output file. In order to ensure this is
% working correctly, the only thing that needs to be done is to execute the
% following command at the start of each analysis script. 

% The input argument to the "IQMinitializeCompliance" function needs to be
% the name of the script file.
IQMinitializeCompliance('SCRIPT_01_Data_Preparation');

%% Preparation of the general dataset
% You might get your dataset from your programmer(s) or you might want to
% generate it yourself. You can do this here or call from here other
% functions (SAS or R) which complete the task. Or you can do it completely
% outside of MATLAB.
%
% Ideally, you store the final CSV dataset in the general data format in
% the ../Data folder. But you could have it anywhere on your system where
% you can access it by absolute or relative paths.

%% Load the general dataset
% NOTE: In contrast to R, where a working directory has to be set, MATLABs
% working directory is always the one which is shown on the top or in the
% "Current Folder" panel. All scripts and all parts of these scripts need
% to be executed in this folder. 

dataGeneral = IQMloadCSVdataset('../Data/dataGeneral_Example.csv');

%% Checking the general dataset format
% During dataset generation a lot of things can go wrong - and
% unfortunately in many cases do go wrong. The reasons are manifold.
% One of the advantages of using a standard general dataset format is that
% standard sanity checks on data consistency can be performed
% automatically. These will not cover all aspects and not find all
% programming mistakes, but they allow a quick first assessment of the
% consistency of your dataset.  

IQMcheckGeneralDataFormat(dataGeneral);

% Please look carefully at all the output of this function. They give
% useful information about potential data issues.

%% Convert general dataset to task specific dataset format
% In this example we want to conduct a popPK and a popPKPD. The general
% dataset might contain information or readouts that are not needed for
% your analysis. And it does not contain all the columns that are needed
% for running NLME estimations. In this section the general dataset is
% converted to a task specific dataset format. At this point we do not
% generate one dataset for popPK and one for popPKPD, but one covering both
% tasks.

% Columns that the user added to the general data format will remain in the
% task specific data format and can be used in the graphical analysis and
% modeling later on.

% Define the NAMEs of the event in the dataset that corresponds to the DOSE
% that you want to consider. If your data contains doses of multiple
% compounds, multiple names for the doses can be provided.
DOSENAMES = {'Dose Z'};

% Define the NAMEs of the observations that you want to analyze:
OBSNAMES = {'Plasma concentration Z','Efficacy marker'};

% Define the baseline candidate covariates by their NAME in the general
% dataset and by the name of the covariate column for the modeling. It is
% not allowed to use underscores "_" in covariate column names!
covariateInfoTimeIndependent = {
    % NAME                BASELINE COVARIATE COLUMN NAME      
     'Gender'            'SEX'
     'Age'               'AGE0'
     'Weight'            'WT0'
     'Efficacy marker'   'EFF0'
};

% Define time varying covariates / regression parameters by their NAME in
% the general dataset and by the name of the covariate column for the
% modeling. It is not allowed to use underscores "_" in covariate column
% names! 
covariateInfoTimeDependent = {
    % NAME                TIME DEPENDENT COLUMN NAME      
     'Weight'            'WT'    
};

% Convert the general dataset format to the task specific one
dataTask = IQMconvertGeneral2TaskDataset(dataGeneral,DOSENAMES,OBSNAMES,covariateInfoTimeIndependent,covariateInfoTimeDependent);

%% Check the task specific dataset format
% As with the general dataset format, the task specific dataset format can
% be checked automatically for consistency problems. Please look carefully
% at the output and handle accordingly.

IQMcheckTaskDataset(dataTask);

%% Export the task specific dataset format to the ../Data folder
% The following scripts will work with the task specific dataset.

IQMexportCSVdataset(dataTask,'../Data/dataTask_Example.csv');
 
