function [output] = hptestBC(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simplemodel
% Generated: 08-Sep-2016 15:32:21
% 
% [output] = hptestBC() => output = initial conditions in column vector
% [output] = hptestBC('states') => output = state names in cell-array
% [output] = hptestBC('algebraic') => output = algebraic variable names in cell-array
% [output] = hptestBC('parameters') => output = parameter names in cell-array
% [output] = hptestBC('parametervalues') => output = parameter values in column vector
% [output] = hptestBC('variablenames') => output = variable names in cell-array
% [output] = hptestBC('variableformulas') => output = variable formulas in cell-array
% [output] = hptestBC(time,statevector) => output = time derivatives in column vector
% 
% State names and ordering:
% 
% statevector(1): A
% statevector(2): A2
% statevector(3): C
% statevector(4): D
% statevector(5): B
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global time
parameterValuesNew = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HANDLE VARIABLE INPUT ARGUMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 0,
	% Return initial conditions of the state variables (and possibly algebraic variables)
	output = [0, 0, 0, 0, 1];
	output = output(:);
	return
elseif nargin == 1,
	if strcmp(varargin{1},'states'),
		% Return state names in cell-array
		output = {'A', 'A2', 'C', 'D', 'B'};
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
A2 = statevector(2);
C = statevector(3);
D = statevector(4);
B = statevector(5);

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
R1 = k1*A*B;
R2 = 5.1*B- ((3*A*D));
R3 = 2.7*A^2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIFFERENTIAL EQUATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A_dot = -R1+R2-2*R3;
A2_dot = +R3;
C_dot = +2*R1;
D_dot = +R2;
B_dot = -R1-R2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RETURN VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATE ODEs
output(1) = A_dot;
output(2) = A2_dot;
output(3) = C_dot;
output(4) = D_dot;
output(5) = B_dot;
% return a column vector 
output = output(:);
return


