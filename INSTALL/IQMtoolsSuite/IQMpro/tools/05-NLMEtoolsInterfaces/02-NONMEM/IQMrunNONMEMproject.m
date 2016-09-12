function [] = IQMrunNONMEMproject(projectPath,NPROCESSORS,NO_GOF_PLOTS)
% This function runs a specified NONMEM project.
%
% [SYNTAX]
% [] = IQMrunNONMEMproject(projectPath)
% [] = IQMrunNONMEMproject(projectPath,N_PROCESSORS)
% [] = IQMrunNONMEMproject(projectPath,N_PROCESSORS,NO_GOF_PLOTS)
%
% [INPUT]
% projectPath:      Path to the project.nmctl NONMEM project file
% NPROCESSORS:      Number of processors if use of parallel (default: 1)
% NO_GOF_PLOTS:     =0: Create GoF plots for all runs (default), 
%                   =1: No Gof plots
%
% [OUTPUT]
% Output generated in the RESULTS folder of the NONMEM project.
%
% Control NONMEM run from commandline:
% ====================================
% CTRL-J: Console iteration printing on/off 
% CTRL-K: Exit analysis at any time, which completes its output, and goes
%         on to next mode or estimation method
% CTRL-E: Exit program gracefully at any time
% CTRL-T: Monitor the progress of each individual during an estimation by
%         toggling ctrl-T. Wait 15 seconds or more to observe a subject’s
%         ID, and individual objective function value. It is also good to
%         test that the problem did not hang if a console output had not
%         been observed for a long while

% <<<COPYRIGHTSTATEMENT - IQM TOOLS PRO>>>

% Handle variable input arguments
if nargin == 1,
    NPROCESSORS = 1;
    NO_GOF_PLOTS = 0;
elseif nargin == 2,
    NO_GOF_PLOTS = 0;
end

% Check if NONMEM project
if ~isNONMEMprojectIQM(projectPath),
    error('Specified "projectPath" does not point to a NONMEM project.');
end

% Load information about the NONMEM PATH
[~,~,PATH_NONMEM,PATH_NONMEM_PAR] = getNLMEtoolInfoIQM();
if isempty(PATH_NONMEM) && NPROCESSORS==1,
    error('Path to NONMEM executable not defined in SETUP_PATHS_TOOLS_IQMPRO.m');
end
if isempty(PATH_NONMEM_PAR) && NPROCESSORS>1,
    error('Path to NONMEM parallel executable not defined in SETUP_PATHS_TOOLS_IQMPRO.m');
end

% Change in to project path
oldpath = pwd;
cd(projectPath);

% Run NONMEM
if NPROCESSORS == 1,
    eval(sprintf('!%s project.nmctl project.nmlog',PATH_NONMEM));
else
    eval(sprintf('!%s %d project.nmctl project.nmlog',PATH_NONMEM_PAR,NPROCESSORS));
end

% Change back to old path
cd(oldpath);

% Cleanup
try
    cleanNONMEMprojectFolderIQM(projectPath);
catch
    error('NONMEM run created a problem. Please check.');
end

% Postprocess ...
try
    IQMplotConvergenceNONMEM(projectPath);
	close all
catch
    disp('Problem with plotting');
    disp(lasterr);    
end
try
    IQMcreateNONMEMresultsTable(projectPath);
catch
    disp('Problem with reporting');
    disp(lasterr);    
end

% Generate information for GOF plots
try
    PROJECTINFO     = parseNONMEMprojectHeaderIQM(projectPath);
    % outputNumber: Defined by metadata "OUTPUTS"
    outputNumberALL = [1:length(PROJECTINFO.OUTPUTS)];
    outputNamesALL  = PROJECTINFO.OUTPUTS;
catch
    warning('Problem with obtaining information for GOF plots.');
    disp(lasterr);    
end

% Do GOF plots
if ~NO_GOF_PLOTS,
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

