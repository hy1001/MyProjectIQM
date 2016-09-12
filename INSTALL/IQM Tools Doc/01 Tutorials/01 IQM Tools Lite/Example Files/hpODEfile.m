function [output] = hpODEfile(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SimpleModel
% Generated: 08-Sep-2016 15:17:20
% 
% [output] = hpODEfile() => output = initial conditions in column vector
% [output] = hpODEfile('states') => output = state names in cell-array
% [output] = hpODEfile('algebraic') => output = algebraic variable names in cell-array
% [output] = hpODEfile('parameters') => output = parameter names in cell-array
% [output] = hpODEfile('parametervalues') => output = parameter values in column vector
% [output] = hpODEfile('variablenames') => output = variable names in cell-array
% [output] = hpODEfile('variableformulas') => output = variable formulas in cell-array
% [output] = hpODEfile(time,statevector) => output = time derivatives in column vector
% 
% State names and ordering:
% 
% statevector(1): A
% statevector(2): B
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global time
parameterValuesNew = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HANDLE VARIABLE INPUT ARGUMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 0,
	% Return initial conditions of the state variables (and possibly algebraic variables)
	output = [1, 0];
	output = output(:);
	return
elseif nargin == 1,
	if strcmp(varargin{1},'states'),
		% Return state names in cell-array
		output = {'A', 'B'};
	elseif strcmp(varargin{1},'algebraic'),
		% Return algebraic variable names in cell-array
		output = {};
	elseif strcmp(varargin{1},'parameters'),
		% Return parameter names in cell-array
		output = {'k1'};
	elseif strcmp(varargin{1},'parametervalues'),
		% Return parameter values in column vector
		output = [0.5];
	elseif strcmp(varargin{1},'variablenames'),
		% Return variable names in cell-array
		output = {};
	elseif strcmp(varargin{1},'variableformulas'),
		% Return variable formulas in cell-array
		output = {};
	else
		error('Wrong input arguments! Please read the help text to the ODE file.');
	end
	output = output(:);
	return
elseif nargin == 2,
	time = varargin{1};
	statevector = varargin{2};
elseif nargin == 3,
	time = varargin{1};
	statevector = varargin{2};
	parameterValuesNew = varargin{3};
	if length(parameterValuesNew) ~= 1,
		parameterValuesNew = [];
	end
elseif nargin == 4,
	time = varargin{1};
	statevector = varargin{2};
	parameterValuesNew = varargin{4};
else
	error('Wrong input arguments! Please read the help text to the ODE file.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A = statevector(1);
B = statevector(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(parameterValuesNew),
	k1 = 0.5;
else
	k1 = parameterValuesNew(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REACTION KINETICS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R = k1*A;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIFFERENTIAL EQUATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A_dot = -R;
B_dot = R;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RETURN VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATE ODEs
output(1) = A_dot;
output(2) = B_dot;
% return a column vector 
output = output(:);
return


