%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IQM Tools - PopPKPD Example
%
% This folder contains an example on how the IQM Tools might be used in a
% workflow manner to accomplish efficient pharmacometric PK and PD modeling.
%
% Example data in the general IQM Tools data format is available as a CSV
% file in the ../Data folder. This data has been generated randomly and
% does not come from a real study. Big efforts have been made to make it
% look reasonably real.
%
% Working through the example scripts in this folder a complete population
% PK and PD analysis is performed, including trial simulation.
%
% Documentation is provided to allow the user to use this example as a
% template and adapt it to own needs.
%
% This is not an example on how to do population modeling. This is an
% example on how the IQM Tools can be used to do so efficiently.
%
% For more information, please contact: 
% 	Henning Schmidt
%   henning.schmidt@intiquan.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUNALL
% The complete analysis can be re-run by executing the following code.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SCRIPT_01_Data_Preparation
SCRIPT_02_Data_Exploration
SCRIPT_03_Data_PK_Conversion
SCRIPT_04_Model_PK_Base
SCRIPT_05_Model_PK_Covariate
SCRIPT_06_Model_PK_Final
SCRIPT_07_Simulation_PK
SCRIPT_08_Data_PD_Conversion
SCRIPT_09_Model_PD

