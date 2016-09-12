%% This is an example, explaining the use of INPUT definitions in SBmodels.

%% First have a look at the first model
edit model1.txt
% You can see that there is an input definition in the ODE (INPUT1).
% The prefactor "F" might be interpreted as bioavailability. You can 
% use any prefactor (also a mathematical expression). Only model parameters
% and numeric values are allowed in these expressions (and any mathematical
% function, such as sin, cos, ...).
% You can also see that "INPUT1" does not appear anywhere else in the
% model. This means the model as it is in this file is not directly
% simulatable.

%% Import the model to MATLAB and have a look at it
model1 = IQMmodel('model1.txt')
IQMedit(model1)
% Have a look at the imported model. You see that INPUT1 = 0 is now defined
% as a parameter. During import (if not already defined) all the input
% definitions will be added as parameters with 0 value.

% IMPORTANT: Before continuing you need to close the SBedit window.

%% Set the input INPUT1 to 0.1 and simulate
model1 = IQMparameters(model1,'INPUT1',0.1);
IQMsimulate(model1,[0:0.1:10])
% In the following tutorial sections you will learn how to apply other
% kinds of inputs to these INPUT* definitions, based on dosing schemes

%% Now have a look at the second model
edit model2.txtbc
% The main difference is that 1) it is defined in the biochemical reaction
% framework and 2) INPUT1 is also defined as a parameter with value 0.1

%% Import the model to MATLAB and have a look at it
model2 = IQMmodel('model2.txtbc');
IQMedit(model2)
% Have a look at the imported model. You see that INPUT1 = 0.1 has not been
% changed. So, if you set a value from the beginning, the import function
% will not remove your selection.

% IMPORTANT: INPUT1, 2, 3, 4, ... is a reserved word and used to recognize
% input definitions. Do not use it for any other component in the model
% (e.g. not as state name or variable name, etc.).

%% A slightly more complex model having two different inputs INPUT1 and INPUT3.
edit model3.txt
% You see an example of a model with 2 inputs. INPUT1 has been added both
% to state 1 and state 2 (with different prefactors), while INPUT3 only has
% been added to state 3. I tried to let it ressemble a 3 compartment PK
% model but one might argue about its physiological basis :)

%% Import the model and look at it
model3 = IQMmodel('model3.txt');
IQMedit(model3)
% You see nothing unexpected I guess.

%% Finally, lets look at the underlying structure of the imported model
s = struct(model3)
% You can see that the model representation structure contains an "inputs"
% field.

%% Consider the models inputs field:
s.inputs(1)
s.inputs(2)
% You see that some information about the inputs in the model is stored in
% the model structure. By having a closer look you will see what it means.
% This information is determined during the model import and can be used by
% subsequent functions to add INPUT functionality. The normal user will not
% have to care about it and can forget about this again. Higher level
% functions will deal with it automatically.
