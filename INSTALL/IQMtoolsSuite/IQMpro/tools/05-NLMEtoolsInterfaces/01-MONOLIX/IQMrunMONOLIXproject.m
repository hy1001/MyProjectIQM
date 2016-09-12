function [] = IQMrunMONOLIXproject(projectPath,NPROCESSORS,NO_GOF_PLOTS)
% This function runs a specified Monolix project.
%
% [SYNTAX]
% [] = IQMrunMONOLIXproject(projectPath)
% [] = IQMrunMONOLIXproject(projectPath,N_PROCESSORS)
% [] = IQMrunMONOLIXproject(projectPath,N_PROCESSORS,NO_GOF_PLOTS)
%
% [INPUT]
% projectPath:      Path to the .mlxtran Monolix project file
% NPROCESSORS:      Number of processors if use of parallel (default: 1)
%                   This argumentis not used yet!
% NO_GOF_PLOTS:     =0: Create GoF plots for all runs (default), 
%                   =1: No Gof plots
%
% [OUTPUT]
% Output generated in the RESULTS folder of the Monolix project.

% <<<COPYRIGHTSTATEMENT - IQM TOOLS PRO>>>

% Handle variable input arguments
if nargin == 1,
    NPROCESSORS = 1;
    NO_GOF_PLOTS = 0;
elseif nargin == 2,
    NO_GOF_PLOTS = 0;
end

% Check if MONOLIX project
if ~isMONOLIXprojectIQM(projectPath),
    error('Specified "projectPath" does not point to a MONOLIX project.');
end

% Load information about the MONOLIX PATH
[PATH_MONOLIX,PATH_MONOLIX_PAR] = getNLMEtoolInfoIQM();
if isempty(PATH_MONOLIX),
    error('Path to MONOLIX standalone version not defined in SETUP_PATHS_TOOLS_IQMPRO.m');
end

% Change in to project path 
oldpath = pwd;
cd(projectPath);

% Run the MONOLIX project
if isunix,
    system([PATH_MONOLIX ' -p ./project.mlxtran -nowin -f run']);
else
    fullProjectPath = pwd();
    PATH_MONOLIX_BAT = fileparts(PATH_MONOLIX);
    cd(PATH_MONOLIX_BAT);
    systemcall = sprintf('Monolix.bat -p "%s/project.mlxtran" -nowin -f run',fullProjectPath);
    system(systemcall);
    cd(fullProjectPath);
end

% Convert the results.ps to results.pdf
try
    IQMconvert2pdf('RESULTS/results.ps')
end

% Change back to previous path
cd(oldpath)

% Generate information for GOF plots
try
    PROJECTINFO     = parseMONOLIXprojectHeaderIQM(projectPath);
    % outputNumber: Defined by metadata "OUTPUTS"
    outputNumberALL = [1:length(PROJECTINFO.OUTPUTS)];
    outputNamesALL  = PROJECTINFO.OUTPUTS;
catch
    warning('Problem with obtaining information for GOF plots.');
    disp(lasterr);
end

% Do GOF plots
if ~NO_GOF_PLOTS,
    rehash
    try
        % General GOF plots
        IQMfitanalysisGeneralPlots(projectPath);
    catch
        warning('Problem with General GOF plots.');
        disp(lasterr);
    end
    try
        % Output specific GOF plots
        IQMfitanalysisOutputPlots(projectPath);
    catch
        warning('Problem with Output specific GOF plots.');
        disp(lasterr);
    end    
end




