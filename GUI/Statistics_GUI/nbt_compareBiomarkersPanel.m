StatSelection = figure('Units','points', 'name','Biomarkers Comparison' ,'numbertitle','off','Position',[50  100  500  450],...
    'MenuBar','none','NextPlot','new','Resize','off');

% regions or channels
reglist{1} = 'Channels';
reglist{2} = 'Regions';
reglist{3} = 'Components';

hp = uipanel(StatSelection,'Title','Select Channels,Regions,Components','FontSize',8,'Units','pixels','Position',[5 340 300 50]);
ListRegion = uicontrol(hp,'Units', 'pixels','style','listbox','Max',1,'Units', 'pixels','Position',[5 5 290 30],'fontsize',8,'String',reglist);
% biomarkers
hp2 = uipanel(StatSelection,'Title','Biomarker to split on','FontSize',8,'Units','pixels','Position',[325 410 300 150]);
ListBiom2 = uicontrol(hp2,'Units', 'pixels','style','listbox','Max',1,'Units', 'pixels','Position',[5 5 290 130],'fontsize',8,'String',StatObj.getBiomarkerNames);
% tests
hp3 = uipanel(StatSelection,'Title','Select Biomarker to compare','FontSize',8,'Units','pixels','Position',[5 410 300 150]);
ListBiom1 = uicontrol(hp3,'Units', 'pixels','style','listbox','Max',1,'Units', 'pixels','Position',[5 5 290 130],'fontsize',8,'String',StatObj.getBiomarkerNames);
% select Group
for i = 1:length(NBTstudy.groups)
    gname = NBTstudy.groups{i}.groupName;
    groupList{i} = ['Group ' num2str(i) ' : ' gname];    
end

%select test
hp4 = uipanel(StatSelection,'Title','Type of Test','FontSize',8,'Units','pixels','Position',[5 250 300 80]);
ListTest = uicontrol(hp4,'Units', 'pixels','style','listbox','Max',1,'Units', 'pixels','Position',[5 5 290 60],'fontsize',8,'String',{'Spearman Correlation','TTest after splitting on Biomarker','Pearson Correlation','Kendall Correlation'});

%select display
hp5 = uipanel(StatSelection,'Title','Type of Display','FontSize',8,'Units','pixels','Position',[5 190 300 50]);
ListDisplay = uicontrol(hp5,'Units', 'pixels','style','listbox','Max',1,'Units', 'pixels','Position',[5 5 290 30],'fontsize',8,'String',{'Individual Channels','Topoplots'});
    
 
%  %biomarker
%  hp7 = uipanel(StatSelection,'Title','Select Biomarker to split on','FontSize',8,'Units','pixels','Position',[5 240 300 50]);
%  ListBio = uicontrol(hp7,'Units', 'pixels','style','listbox','Max',1,'Units', 'pixels','Position',[5 5 290 30],'fontsize',8,'String',{'Biomarker 1','Biomarker 2'});
 % Type of split
 hp8 = uipanel(StatSelection,'Title','%split or split on value','FontSize',8,'Units','pixels','Position',[325 340 300 50]);
 ListSplit = uicontrol(hp8,'Units', 'pixels','style','listbox','Max',1,'Units', 'pixels','Position',[5 5 290 30],'fontsize',8,'String',{'% split','value split'});
 % tests
 hp9 = uipanel(StatSelection,'Title','value','FontSize',8,'Units','pixels','Position',[325 280 300 50]);
 ListSplitValue = uicontrol(hp9,'Units', 'pixels','style','edit','Max',1,'Units', 'pixels','Position',[5 5 290 30],'fontsize',8,'String','50');

 hp6 = uipanel(StatSelection,'Title','Select Group(s)','FontSize',8,'Units','pixels','Position',[5 120 300 60]);

ListGroup = uicontrol(hp6,'Units', 'pixels','style','listbox','Max',length(groupList),'Units', 'pixels','Position',[5 5 290 40],'fontsize',8,'String',groupList);
% run test


ViewGraphsButton = uicontrol(StatSelection,'Style','pushbutton','String',{'View Splitting', 'Graphs'},'Position',[425 180 100 50],'fontsize',8,'callback',{@nbt_splitPlotGroups,ListSplit,ListSplitValue,ListBiom1, ListBiom2, ListRegion, ListGroup,G});


RunButton = uicontrol(StatSelection,'Style','pushbutton','String','Run Test','Position',[250 50 100 50],'fontsize',8,'callback',{@nbt_compareBiomarkersGetSettings,ListBiom1, ListBiom2, ListRegion, ListGroup,ListTest,ListDisplay,ListSplit,ListSplitValue,G});
