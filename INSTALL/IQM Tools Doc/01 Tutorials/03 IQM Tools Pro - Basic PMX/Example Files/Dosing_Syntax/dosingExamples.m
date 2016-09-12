%% This example script will go through the use of dosing descriptions,
% merging them with models, simulating the resulting models, etc. It serves
% as a documentation in terms of examples for all the functions related to
% the IQMdosing object in the IQM Tools.

%% An example dosing description
edit dosing2.dos
% This example describes a first order absorption with a single dose

%% Another example dosing description
edit dosing1.dos
% This example describes an infusion with multiple doses, realized in
% several different ways

%% Yet another example dosing description
edit dosing3.dos
% This example describes two different input types in the same file. The
% types can also be the same ... only the names (INPUT1, INPUT2, ...) need
% to be different.

%% The complete documentation of the dosing definition syntax can be found 
% in the following file:
edit dosingSyntaxExample.dos

%% Import of a dosing scheme to an IQMdosing object
dosing = IQMdosing('dosing2.dos')

%% Access the internal data structure of an IQMdosing object
s = struct(dosing)

%% The function "isIQMdosing" checks if the argument is an IQMdosing object
isIQMdosing(dosing)  % yes it is
isIQMdosing(1)       % no it isn't

%% The function "IQMcreateDOSfile" exports a dosing object to a dosing file
IQMcreateDOSfile(dosing,'exportedDosing')

%% Calling the "IQMcreateDOSfile" function without an argument creates
% the file "unnamed.dos", which has the same content as the
% "dosingSyntaxExample.dos" file and serves as a reference when you want to
% quickly get informed about the syntax.
IQMcreateDOSfile()

%% The function "IQMdoseupdatevalue" allows to update the dose defined in the
% specified input definition to another value
dosing2 = IQMdoseupdatevalue(dosing,'INPUT1',30) % updates dose from 10 to 30
% To check result we export the dosing2 object to a file and have a look at it:
IQMcreateDOSfile(dosing2,'dose_change_to_30_dosing')
edit dose_change_to_30_dosing.dos

%% A model can be merged with a dosing scheme as follows:
% Import the model
model = IQMmodel('model1.txt');
% Import the dosing object
dosing = IQMdosing('dosing1.dos');
% Merge the two to obtain a simulatable model
moddos = IQMmergemoddos(model,dosing)
% Have a look at the model
IQMcreateTEXTfile(moddos,'mergedMODdosFile')
edit mergedMODdosFile.txt
% Look at the whole model, you will see that mathemtics have been added to
% implement an infusion as a pulse function. Additionally, the multiple
% dose applications have been realized using the MODEL EVENTS section. Only
% the first dosing event is coded in the initial parameter settings.

%% We can simulate this model just as any other IQMmodel, using the
% IQM Tools Lite and Pro functions:
IQMsimulate(moddos,[0:0.1:100])

IQMPsimulate(moddos,[0:0.1:100]) % (only works if IQM Tools Pro installed)

%% Now we make it a little more complicated. For certain applications it is
% not useful to implement multiple dosings using events in the model
% directly. Sometimes one might want to estimate dosing amounts, etc.
% Especially needed is this approach in all cases of trial simulations
% where the model structure stays the same but the dosing scenarios might
% change but keep the same types of dosing. Then the MEX model only needs
% to be generated once - and the simulation goes much faster since no
% compilation is required in between.
%
% The function "mergemoddosIQM" does almost the same as the
% IQMmergemoddos function, except that it will only add the necessary
% mathematics to the model to implement the desired type of dosing. It will
% not add the actual dosing events. Example:
moddos = mergemoddosIQM(model,dosing)
IQMcreateTEXTfile(moddos,'mergedMODdosFile2')
edit mergedMODdosFile2.txt
% Look at the model, you will notice that the mathematics are identical to
% the previous example. The difference is that the Dose parameter
% "Dose_input1" is set to 0 and that no events are present that implement
% the subsequent dosings.
% In the following we will call such a merged model without the actual
% dosings a "model prepared for dosing applications" or just a "prepared
% model".

%% How to simulate a dosing scheme on a prepared model: 
% The function "IQMsimdosing" has been created to allow for the simulation of 
% a dosing scheme on a prepared model:
IQMsimdosing(moddos,dosing,[0:0.1:100])
% The result of this simulation is identical to the previous case. The
% DIFFERENCE is now that the dosing schedule can be changed (the dosing
% amount, etc.) without having to create a new merged model. This is true
% only if you do not want to change the type of dosing applied. The
% IQMsimdosing function is working with MEX simulation functions:

%% Convert the prepared model to a MEX simulation function (only if IQM Tools Pro is available)
IQMmakeMEXmodel(moddos,'preparedMEXmodel')

%% Simulate a dosing scheme using the generated MEX simulation function
IQMsimdosing('preparedMEXmodel',dosing,[0:0.1:100])

%% Simulate again but change the dosing amount before it to 30
dosing2 = IQMdoseupdatevalue(dosing,'INPUT1',30) % updates dose from 10 to 30
IQMsimdosing('preparedMEXmodel',dosing2,[0:0.1:100])

% Now the advantage of mergemoddosIQM and IQMsimdosing might have
% become more clear: It is possible to change the dosing object without
% having to recompile the prepared model. This allows for a much faster
% implementation of your algorithms in the case that you want to run dose
% changes in a loop (for example for the generation of dose response
% curves).

%% An additional feature of the mergemoddosIQM function is that it
% returns the actual dosing definitions as IQMexperiment. 
[moddos,experiment] = mergemoddosIQM(model,dosing)
IQMcreateEXPfile(experiment,'createdEXPfile')
edit createdEXPfile.exp

%% By merging the prepared model with the experiment you obtain exactly the
% same model as you would obtain by using the IQMmergemoddos function:
modexp = IQMmergemodexp(moddos,experiment)
IQMcreateTEXTfile(modexp,'mergedMODexpFile')
edit mergedMODexpFile.txt

%% Finally, as last example we want to merge the model3.txt which contains
% 2 inputs with the dosing description dosing3.dos, containing the two
% corresponding dosing definitions. First check the files:
edit model3.txt
edit dosing3.dos

%% We import both and merge them using IQMmergemoddos
% Import the model
model = IQMmodel('model3.txt');
% Import the dosing object
dosing = IQMdosing('dosing3.dos');
% Merge the two to obtain a simulatable model
moddos = IQMmergemoddos(model,dosing)
% Have a look at the model
IQMcreateTEXTfile(moddos,'mergedMODdosFile3')
edit mergedMODdosFile3.txt

%% Lets simulate the model
IQMsimulate(moddos,[0:0.1:90])

%% I hope that gave you a quick but useful overview over the functionality
% related to the dosing descriptions, included in the IQM Tools. This
% functionality is also used for the implementation of the Monolix interface.

%% Cleanup
delete createdEXPfile.exp
delete dose_change_to_30_dosing.dos
delete exportedDosing.dos
delete mergedMODdosFile.txt
delete mergedMODdosFile2.txt
delete mergedMODdosFile3.txt
delete mergedMODexpFile.txt
clear mex
delete(strcat('preparedMEXmodel.',mexext));
delete unnamed.dos










