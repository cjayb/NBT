function [p] = gui_eeg_contour_steps(parent)

% gui_eeg_contour_steps - GUI for contour steps of topographic maps
%
% Usage: [p] = eeg_contour_steps([parent])
%

% $Revision: 1.1 $ $Date: 2009-04-28 22:13:56 $

% Licence:  GNU GPL, no express or implied warranties
% History:  10/2002, Darren.Weber_at_radiology.ucsf.edu
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% reset the gui_struct parent field to the handles of the input gui_struct

if exist('parent','var'),
    ContourSteps.parent.gui = parent; 
    ParentUserdata = get(parent,'Userdata');
    ContourSteps.p = ParentUserdata.p;
else
    error('No parent gui parameter supplied');
end

% GUI General Parameters
GUIwidth  = 200;
GUIheight = 100;
GUI = figure('Name','Contour Steps','Tag','CONTOURSTEPS',...
             'NumberTitle','off','HandleVisibility','callback',...
             'MenuBar','none','Position',[1 1 GUIwidth GUIheight]);
movegui(GUI,'center');

ContourSteps.gui = GUI;

Font.FontName   = 'Helvetica';
Font.FontUnits  = 'Pixels';
Font.FontSize   = 12;
Font.FontWeight = 'normal';
Font.FontAngle  = 'normal';

% Contour Step Size

switch ContourSteps.p.contour.stepMethod
case 1,     step = [0 1];
otherwise,  step = [1 0];
end
% Step Size
G.BstepMethod0 = uicontrol('Parent',GUI,'Style','Radiobutton',...
    'Units','Normalized',Font,'Position',[.1 .6 .6 .2],...
    'String','Step Size','Value',step(1),...
    'Callback',strcat('ContourSteps = get(gcbf,''Userdata'');',...
                      'ContourSteps.p.contour.stepMethod = 0;',...
                      'set(ContourSteps.handles.BstepMethod0,''Value'',1);',...
                      'set(ContourSteps.handles.BstepMethod1,''Value'',0);',...
                      'set(ContourSteps.handles.EstepMethod0,''String'',num2str(ContourSteps.p.contour.stepSize));',...
                      'set(ContourSteps.gui,''Userdata'',ContourSteps); clear ContourSteps;'));
G.EstepMethod0 = uicontrol('Parent',GUI,'Style','edit',...
    'Units','Normalized',Font,'Position',[.7 .6 .2 .2],...
    'String',num2str(ContourSteps.p.contour.stepSize),...
    'Callback',strcat('ContourSteps = get(gcbf,''Userdata'');',...
                      'ContourSteps.p.contour.stepSize = str2num(get(ContourSteps.handles.EstepMethod0,''String''));',...
                      'set(ContourSteps.gui,''Userdata'',ContourSteps); clear ContourSteps;'));


% Number of steps
G.BstepMethod1 = uicontrol('Parent',GUI,'Style','Radiobutton',...
    'Units','Normalized',Font,'Position',[.1 .4 .6 .2],...
    'String','Number of Steps','Value',step(2),...
    'Callback',strcat('ContourSteps = get(gcbf,''Userdata'');',...
                      'ContourSteps.p.contour.stepMethod = 1;',...
                      'set(ContourSteps.handles.BstepMethod0,''Value'',0);',...
                      'set(ContourSteps.handles.BstepMethod1,''Value'',1);',...
                      'set(ContourSteps.handles.EstepMethod1,''String'',num2str(ContourSteps.p.contour.Nsteps));',...
                      'set(ContourSteps.gui,''Userdata'',ContourSteps); clear ContourSteps;'));
G.EstepMethod1 = uicontrol('Parent',GUI,'Style','edit',...
    'Units','Normalized',Font,'Position',[.7 .4 .2 .2],...
    'String',num2str(ContourSteps.p.contour.Nsteps),...
    'Callback',strcat('ContourSteps = get(gcbf,''Userdata'');',...
                      'ContourSteps.p.contour.Nsteps = str2num(get(ContourSteps.handles.EstepMethod1,''String''));',...
                      'set(ContourSteps.gui,''Userdata'',ContourSteps); clear ContourSteps;'));



Font.FontWeight = 'bold';

% OK: Return the parameters!
G.Bdone = uicontrol('Parent',GUI,'Style','pushbutton','Units','Normalized', Font, ...
    'Position',[.3 .15 .3 .2],...
    'String','OK','BusyAction','queue',...
    'TooltipString','Update the ascii parameters.',...
    'BackgroundColor',[0.0 0.5 0.0],...
    'ForegroundColor', [1 1 1], 'HorizontalAlignment', 'center',...
    'Callback',strcat('ContourSteps = get(gcbf,''Userdata'');',...
                      'if isfield(ContourSteps,''parent''),',...
                          'if isfield(ContourSteps.parent,''gui''),',...
                            'parent = get(ContourSteps.parent.gui,''UserData'');',...
                            'if isfield(parent,''p'') & isfield(ContourSteps,''p''),',...
                                'parent.p = ContourSteps.p;',...
                                'set(ContourSteps.parent.gui,''UserData'',parent);',...
                            'end; ',...
                          'end; ',...
                      'end; ',...
                      'close gcbf;[p] = ContourSteps.p; clear ContourSteps parent;'));
                  
% Cancel
G.Bquit = uicontrol('Parent',GUI,'Style','pushbutton','Units','Normalized', Font, ...
    'Position',[.6 .15 .3 .2],...
    'String','CANCEL','BusyAction','queue',...
    'BackgroundColor',[0.75 0.0 0.0],...
    'ForegroundColor', [1 1 1], 'HorizontalAlignment', 'center',...
    'Callback','close gcbf;');


% Update the gui_struct handles for this gui
ContourSteps.handles = G;
set(ContourSteps.gui,'Userdata',ContourSteps);

p = ContourSteps.p;
return
