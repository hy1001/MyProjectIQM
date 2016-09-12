% In this file you need to provide the names and potentially the paths to
% the executables for tools, such as NONMEM and MONOLIX.
% 
% If executables in the system path, then only the names of the executables are needed.
%
% It is possible to define paths for Windows and Unix independently,
% allowing to use the package on different systems without the need to
% re-edit the paths. If a tool is not available on a system, then just
% leave the path empty.

% NONMEM (currently tested version: 7.2 and 7.3)
PATH_SYSTEM_NONMEM_WINDOWS                  = 'nmfe73';
PATH_SYSTEM_NONMEM_UNIX                     = '';

% NONMEM PARALLEL
PATH_SYSTEM_NONMEM_PARALLEL_WINDOWS         = 'nmfe73par';
PATH_SYSTEM_NONMEM_PARALLEL_UNIX            = '';
% nmfe73par is assumed to be a shell script with the following calling
% syntax:   "nmfe73par NRNODES controlfile outputfile". If you do not have
% one available, please ask your sysadmin to generate on for you

% MONOLIX STANDALONE (version >= 4.3.2)
PATH_SYSTEM_MONOLIX_WINDOWS                 = 'C:\INSTALL\Monolix\Monolix432s\bin\Monolix.bat';
PATH_SYSTEM_MONOLIX_UNIX                    = '.../bin/Monolix.sh';

% MONOLIX STANDALONE PARALLEL (version >= 4.3.2)
PATH_SYSTEM_MONOLIX_PARALLEL_WINDOWS        = '';
PATH_SYSTEM_MONOLIX_PARALLEL_UNIX           = '';

% Name of MATLAB parallel toolbox profile
MATLABPOOL_PROFILE                          = 'local';

% Preferred ordering criterion for tables of NLME estimates
% Only impacts dislay (ordering) in output tables)
NLME_ORDER_CRITERION                        = 'BIC'; % Alternative: 'AIC', 'BIC', or 'OBJ'

% Define default number of processors to use in case that parallel toolbox available
N_PROCESSORS_PAR                            = 8;
