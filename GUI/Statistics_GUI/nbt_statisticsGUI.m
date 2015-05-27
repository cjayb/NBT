% nbt_statisticsGUI - this function builds the core NBT statistics GUI
%

%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2012), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
% Resturcture of GUI layout : Simon-Shlomo Poil, 2012-2013
%
% Copyright (C) 2012  Giuseppina Schiavone  (Neuronal Oscillations and Cognition group,
% Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research,
% Neuroscience Campus Amsterdam, VU University Amsterdam)
%
% Part of the Neurophysiological Biomarker Toolbox (NBT)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% See Readme.txt for additional copyright information.
% -------------------------------------------------------------------------
% --------------


function nbt_statisticsGUI
global NBTstudy
try
    NBTstudy = evalin('base','NBTstudy');
catch
   evalin('base','global NBTstudy');
   evalin('base','NBTstudy = nbt_Study;');
end
if (isempty(NBTstudy.groups))
    nbt_definegroups;
end

%----------------------
% First we build the Interface
%----------------------
try %close existing windows
    hh = findobj('Tag','NBTStatMain');
    close(hh)
catch
end

StatSelection = figure('Units','pixels', 'name','NBT: Select Statistics' ,'numbertitle','off','Position',[200  200  610  750.000],...
    'MenuBar','none','NextPlot','new','Resize','off','Tag', 'NBTStatMain');
% fit figure to screen, adapt to screen resolution
StatSelection=nbt_movegui(StatSelection);

% This loads the statistical tests- these needs to be set in nbt_Study.getStatisticsTests.
statList = nbt_Study.getStatisticsTests(0);

hp3 = uipanel(StatSelection,'Title','SELECT TEST','FontSize',10,'Units','pixels','Position',[10 520 360 200],'BackgroundColor','w','fontweight','bold');
ListStat = uicontrol(hp3,'Units', 'pixels','style','listbox','Max',1,'Units', 'pixels','Position',[5 5 350 180],'fontsize',10,'String',statList,'BackgroundColor','w','Tag','ListStat');
% biomarkers
hp2 = uipanel(StatSelection,'Title','SELECT BIOMARKER(S)','FontSize',10,'Units','pixels','Position',[10 300 360 200],'BackgroundColor','w','fontweight','bold');

ListBiom = uicontrol(hp2,'Units', 'pixels','style','listbox','Max',length(NBTstudy.groups{1}.biomarkerList),'Units', 'pixels','Position',[5 5 350 180],'fontsize',10,'String',NBTstudy.groups{1}.biomarkerList,'BackgroundColor','w','Tag','ListBiomarker');

% regions or channels
reglist{1} = 'Channels';
reglist{2} = 'Regions';
reglist{3} = 'Match channels';

hp = uipanel(StatSelection,'Title','SELECT CHANNELS OR REGIONS','FontSize',10,'Units','pixels','Position',[10 220 360 70],'BackgroundColor','w','fontweight','bold');
ListRegion = uicontrol(hp,'Units', 'pixels','style','listbox','Min',0,'Max',2,'Units', 'pixels','Position',[5 5 350 50],'fontsize',10,'String',reglist,'BackgroundColor','w','Tag','ListRegion');

% channel selection button
ChannelsButton = uicontrol(StatSelection,'Style','pushbutton','String','Select Channels and Regions','Position',[400 240 200 30],'fontsize',12);%,'callback',@ChannelsButton_Callback);
set(ChannelsButton,'callback','nbt_selectchansregs;');

% select Group

for i = 1:length(NBTstudy.groups)
    groupList{i} = ['Group ' num2str(i) ' : ' NBTstudy.groups{i}.groupName];
end

hp4 = uipanel(StatSelection,'Title','SELECT GROUP(S)','FontSize',10,'Units','pixels','Position',[10 110 360 100],'BackgroundColor','w','fontweight','bold');
ListGroup = uicontrol(hp4,'Units', 'pixels','style','listbox','Max',length(groupList),'Units', 'pixels','Position',[5 5 350 80],'fontsize',10,'String',groupList,'BackgroundColor','w','Tag','ListGroup');
% run test
RunButton = uicontrol(StatSelection,'Style','pushbutton','String','Run Test','Position',[500 5 100 50],'fontsize',10,'callback', 'nbt_runStatistics(1)', 'Tag', 'NBTstatRunButton');
% join button
joinButton = uicontrol(StatSelection,'Style','pushbutton','String','Join Groups','Position',[5 70 70 30],'fontsize',8,'callback',@join_groups);
% create difference group button
groupdiffButton = uicontrol(StatSelection,'Style','pushbutton','String','Difference Group','Position',[280 70 100 30],'fontsize',8,'callback',@diff_group);
% create difference group button
definegroupButton = uicontrol(StatSelection,'Style','pushbutton','String','Define New Group(s)','Position',[400 140 150 30],'fontsize',12,'callback',@nbt_definegroups);
% create difference group button
addgroupButton = uicontrol(StatSelection,'Style','pushbutton','String','Update Groups List','Position',[130 40 110 30],'fontsize',8,'callback',@add_new_groups);
% remove group(s)
removeGroupButton = uicontrol(StatSelection,'Style','pushbutton','String','Remove Group(s)','Position',[80 70 100 30],'fontsize',8,'callback',@remove_groups);
% save group(s)
saveGroupButton = uicontrol(StatSelection,'Style','pushbutton','String','Save Group(s)','Position',[185 70 90 30],'fontsize',8,'callback',@save_groups);
% export bioms
ExportBio = uicontrol(StatSelection,'Style','pushbutton','String','Export Biomarker(s) to .txt','Position',[5 10 150 30],'fontsize',8,'callback',@export_bioms);

% NBT Print button
% create difference group button
NBTprintButton = uicontrol(StatSelection,'Style','pushbutton','String','NBT Print','Position',[280 10 100 30],'fontsize',8,'callback',@printNBTprint);

% move up
upButton = uicontrol(StatSelection,'Style','pushbutton','String','/\','Position',[370 165 25 25],'fontsize',8,'callback',@up_group);
% move down
downButton = uicontrol(StatSelection,'Style','pushbutton','String','\/','Position',[370 140 25 25],'fontsize',8,'callback',@down_group);

    function printNBTprint(d1,d2)
        % Move to selectRunStatistics?
        
        % Get the groups from the GUI
        groups = get(ListGroup,'Value');
        statTest = get(ListStat,'Value');
        nbt_Print(NBTstudy,statTest,groups);
    end

        function diff_group(d1,d2)

            group_ind = get(ListGroup,'Value'); % obj.groups
            if length(group_ind)>2
                warning('Select only two for difference group creation!')
            elseif length(group_ind) == 1
                warning('Two groups are necessary for difference group creation!')
            elseif length(group_ind) == 2
                % if (size(Data1.subjectList{1},2) == size(Data2.subjectList{1},2))
                % SH: Changed class to difference group
                DiffGroup = nbt_DiffGroup;
                DiffGroup.grpNumber = length(NBTstudy.groups) + 1;
                DiffGroup.groupDifference = group_ind;
                DiffGroup.biomarkerList = NBTstudy.groups{group_ind(1)}.biomarkerList;
                DiffGroup.chanLocs = NBTstudy.groups{group_ind(1)}.chanLocs;
                DiffGroup.ref = NBTstudy.groups{group_ind(1)}.ref;
                DiffGroup.listRegData = NBTstudy.groups{group_ind(1)}.listRegData;
                
                % Put the group in the NBTstudy object
                NBTstudy.groups{end+1} = DiffGroup;
                
                %NBTstudy.groups{end+1} = NBTstudy.groups{group_ind(1)};
                %NBTstudy.groups{end}.grpNumber = length(NBTstudy.groups);
                %NBTstudy.groups{end}.groupType = 'difference';
                %NBTstudy.groups{end}.groupDifference = group_ind;

                scrsz = get(0,'ScreenSize');
                % fit figure to screen, adapt to screen resolution
                hh2 = figure('Units','pixels', 'name','Define group difference' ,'numbertitle','off','Position',[scrsz(3)/4  scrsz(4)/2  250  120],...
                    'MenuBar','none','NextPlot','new','Resize','off');
                col =  get(hh2,'Color' );
                set(hh2,'CreateFcn','movegui')
                hgsave(hh2,'onscreenfig')
                close(hh2)
                hh2 = hgload('onscreenfig');
                currentFolder = pwd;
                delete([currentFolder '/onscreenfig.fig']);
                step = 40;

                nameg1 = NBTstudy.groups{group_ind(1)}.groupName;
                %                 sep = findstr(nameg1,':');
                %                 nameg1 = nameg1(sep+1:end);
                nameg2 = NBTstudy.groups{group_ind(2)}.groupName;
                %                 sep = findstr(nameg2,':');
                %                 nameg2 = nameg2(sep+1:end);

                text_diff1= uicontrol(hh2,'Style','text','Position',[25 45+step 200 20],'string','Group 1     minus     Group 2','fontsize',10,'fontweight','Bold','BackgroundColor',col);
                text_diff2= uicontrol(hh2,'Style','edit','Position',[25 10+step 80 30],'string',nameg1,'fontsize',10);
                text_diff3= uicontrol(hh2,'Style','text','Position',[115 20+step 20 20],'string',' - ','fontsize',15,'fontweight','Bold','BackgroundColor',col);
                text_diff4= uicontrol(hh2,'Style','edit','Position',[150 10+step 80 30],'string',nameg2,'fontsize',10,'BackgroundColor',col);
                OkButton = uicontrol(hh2,'Style','pushbutton','String','OK','Position',[25 10 200 30],'fontsize',10,'callback',{@confirm_diff_group,text_diff2,text_diff4});
            else
                warning('The two groups must have same number of subjects!')
            end
            
            NBTstudy.groups{end}.groupDifferenceType = input('Which kind of difference? Please type "regular", "absolute" or "squared": ','s');

        end

    function confirm_diff_group(d1,d2,text_diff2,text_diff4)
        % SH: Line 178: indices of groups should be taken from the input
        % fields instead of get(listGroup), otherwise we can't say group2
        % minus group1
        group_ind = get(ListGroup,'Value'); % obj.groups
        nameg1 = get(text_diff2,'string');
        %             sep = findstr(nameg1,':');
        %             nameg1 = nameg1(sep+1:end);
        nameg2 = get(text_diff4,'string');
        %             sep = findstr(nameg2,':');
        %             nameg2 = nameg2(sep+1:end);
        
        new_group_name = [nameg1 ' minus ' nameg2];
        NBTstudy.groups{end}.groupName = new_group_name;
        NBTstudy.groups{end}.parameters = [NBTstudy.groups{group_ind(1)}.parameters; NBTstudy.groups{group_ind(2)}.parameters];
        
        groupList{end+1} = ['Group ' num2str(length(NBTstudy.groups)) ' : ' new_group_name];
        set(ListGroup,'Max',length(groupList),'fontsize',10,'String',groupList,'BackgroundColor','w');
        
        %assignin('base','NBTstudy',NBTstudy)
        h = get(0,'CurrentFigure');
        close(h)
    end

% remove groups
    function remove_groups(d1,d2)
        group_ind = get(ListGroup,'Value');
        group_name = get(ListGroup,'String');
        
        if length(group_name)>1 && length(group_ind)<length(group_name)
            
            n_groups = length(NBTstudy.groups);
            NBTstudy.groups = NBTstudy.groups(setdiff([1:n_groups],group_ind));
            groupList = groupList(setdiff([1:n_groups],group_ind));
            
            for i = 1:length(groupList)
                oldName = groupList{i};
                gr_num_loc = strfind(groupList{i},':');
                groupList{i} = ['Group ',num2str(i),oldName(gr_num_loc-1:end)];
            end
        else
            groupList = {''};
        end
        set(ListGroup,'String','');
        set(ListGroup,'Value',length(groupList));
        set(ListGroup,'Max',length(groupList),'fontsize',10,'String',groupList,'BackgroundColor','w');
        
    end

end
