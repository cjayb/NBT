%NBTelement object defintion
%
% methods: nbt_NBTelement, nbt_LimitPool
%
% %%% nbt_NBTelement
% NBTelement = nbt_NBTelement(ElementID, Key, Uplink)
% Returns an NBTelement
%
% Input:
% ElementID; the element ID
% Key; Key string to decode the NBTelement.ID, i.e. sub.parent.superparent
% Uplink; the elementID of the parent of this NBTelement
%
%
% %%% nbt_LimitPool
% [NewPoolID, NewKey] = nbt_LimitPool(NBTelement,UpPool, UpPoolKey,
% DataString)
%
% Return a new pool of IDs limited by 'DataString', from the existing
% 'UpPool' pool of IDs (The UpPool is decoded using the UpPoolKey
%
% see also:
%NBT_GETDATA, NBT_SETDATA, NBT_CONNECTNBTELEMENTS


% Copyright (C) 2010 Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
% Code written by Simon-Shlomo Poil
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
%

% ChangeLog - see version control log for details
% First version written by Simon-Shlomo Poil


classdef nbt_NBTelement %< handle
    properties
        name ='';
        ElementID = []; % define element position
        Key = []; % define format of ID
        Uplink = [];
        Children = [];
        Relation =[];
        ID = cell(0,0); % ID
        Data = []; %Data
        Biomarkers = cell(0,0);
        BiomarkerType = cell(0,0);
        BiomarkerUnit = cell(0,0);
        ProjectID = [];
        Info = [];
        Identifier = false;
        isBiomarker = true;
        Class = []; %w.g. subjectInfo, nbt_CrossChannelBiomarker, nbt_SignalBiomarker, nbt_QBiomarker
    end
    methods
        function NBTelement = nbt_NBTelement(ElementID, Key, Uplink)
            NBTelement.ElementID = ElementID;
            NBTelement.Key = Key;
            NBTelement.Uplink = Uplink;
            if ~isempty(Uplink)
                s = evalin('caller','whos');
                parentName = [];
                for i = 1:length(s)
                    if strcmp(s(i).class,'nbt_NBTelement')
                        sID = evalin('caller',[s(i).name '.ElementID']);
                        if sID == Uplink
                            parentName = s(i).name;
                        end
                    end
                end
                if isempty(parentName)
                    disp('Parent Not Found');
                else
                    evalin('caller',[parentName '.Children = unique([' parentName '.Children; ' num2str(ElementID) ']);']);
                end
            end
            NBTelement.Children = [];
            NBTelement.Relation = [];
            NBTelement.ID = [];
            NBTelement.Data = [];
            NBTelement.Biomarkers = cell(0,0);
            NBTelement.ProjectID = [];
            NBTelement.Info = [];
        end
        
        function NBTelement = nbt_isBiomarkerSwitch(NBTelement,biomarkerClass)
            if(NBTelement.isBiomarker)
                NBTelement.isBiomarker = false;
                NBTelement.Biomarkers = cell(0,0);
                NBTelement.BiomarkerType = cell(0,0);
            else %not a biomarker > switch
                NBTelement.isBiomarker = true;
                NBTelement.Biomarkers = {'Info'};
                NBTelement.BiomarkerType = {biomarkerClass};
            end
        end
        
        function [NewPoolID, NewKey] = nbt_LimitPool(NBTelement,UpPool, UpPoolKey, DataString)
            %% % first find DataString match => Pool of match keys
            if(~iscell(NBTelement.Data))
                if(ischar(DataString))
                    eval(['NewPool =' DataString ';']) ;
                else
                    NewPool = nbt_searchvector(NBTelement.Data, DataString);
                    if(isempty(NewPool)) %then probably DataString is a string and .Data is numeric
                        DataString = cellfun(@str2num,DataString);
                        NewPool = nbt_searchvector(NBTelement.Data, DataString);
                    end
                end
            else
                NewPool =[];
                if(~iscell(DataString))
                    if(isempty(strfind(DataString,'$')))
                        for mm=1:length(NBTelement.Data)
                            if(strcmp(nbt_cellc(NBTelement.Data,mm),DataString))
                                NewPool = [NewPool mm];
                            end
                        end
                    else
                        %implements $ and @ syntax ($ is data, @ is biomarker)
                        %first get parameter to text
                        [DataParaString, DataBiomarker] = strtok(DataString,'@');
                        while ~isempty(strfind(DataParaString,'$'))
                            [SplitA, SplitB] = strtok(DataParaString,'$');
                            DataParaString = [SplitA ' BiomarkerData ' SplitB(2:end)];
                        end
                        
                        for mm=1:length(NBTelement.Biomarkers)
                            if(strcmp(NBTelement.Biomarkers{mm,1}, DataBiomarker(2:end)))
                                BiomarkerIndex = mm;
                                break
                            end
                        end
                        for SubID = 1:size(NBTelement.Data,2)
                            BiomarkerData = NBTelement.Data{BiomarkerIndex,SubID};
                            eval(['tmp = find(' DataParaString ');'])
                            if(~isempty(tmp))
                                NewPool = [NewPool SubID];
                            end
                            clear tmp
                        end
                    end
                else %if DataString is a cell
                    for mm=1:length(NBTelement.Data)
                        for ll = 1:length(DataString)
                            if(strcmp(nbt_cellc(NBTelement.Data,mm),nbt_cellc(DataString,ll)))
                                NewPool = [NewPool mm];
                            end
                        end
                    end
                end
            end
            
            % find NewPoolIDs
            NewPoolID = [];
            for i=1:length(NewPool)
                NewPoolID = [NewPoolID; NBTelement.ID((strcmp(strtok(NBTelement.ID,'.'),int2str(NewPool(i)))))];
            end
            
            if(~isempty(UpPool))
                %%  % Match UpPoolKey and update NewKey i.e. step up.
                [tmpKey, KeepKey] = strtok(UpPoolKey,'.');
                TokenStep = 1;
                UplinkMissing = 0;
                while (str2double(tmpKey) ~= NBTelement.Uplink)
                    [tmpKey, KeepKey] = strtok(KeepKey,'.');
                    TokenStep = TokenStep + 1;
                    if(isempty(tmpKey))
                        %The uplink is not in the tree. We need to step up
                        %and find it.
                        UplinkMissing = 1;
                        TokenStep = TokenStep -1;
                        break;
                    end
                end
                NewKey = [int2str(NBTelement.ElementID) '.' tmpKey KeepKey];
                if(UplinkMissing)
                    NewKey = NBTelement.Key;
                end
                
                %% % update UpPool - strip off until NBTelement.UpLink match
                if(~UplinkMissing)
                    for i=1:(TokenStep-1)
                        [StripOff, UpPool] = strtok(UpPool,'.');
                    end
                    UpPool = nbt_TrimCellStr(UpPool);
                end
                
                %Avoid redundant UpPool.
                UpPool = unique(UpPool,'stable');
                
                %% % Match UpPool
                [StripOff, NewPoolIDstpup] = strtok(NewPoolID,'.');
                NewPoolIDstpup=nbt_TrimCellStr(NewPoolIDstpup);
                if(UplinkMissing == 1)
                    [tmpKey, TreeKey] = strtok(NBTelement.Key, '.');
                    while(isempty(strfind(TreeKey,UpPoolKey)))
                        [StripOff, UpPoolKey] = strtok(UpPoolKey,'.');
                        [StripOff, UpPool] = strtok(UpPool,'.');
                    end
                    UpPool=nbt_TrimCellStr(UpPool);
                    
                    uplinkstage = strfind(TreeKey,UpPoolKey);
                    uplinksteps = length(strfind(TreeKey(1:uplinkstage),'.')) -1;
                    for i=1:uplinksteps
                        [StripOff, NewPoolIDstpup] = strtok(NewPoolIDstpup,'.');
                    end
                    
                    NewPoolIDstpup=nbt_TrimCellStr(NewPoolIDstpup);
                end
                
                %Match pools
                [IncludeInPool NewPoolID] = nbt_MatchPools(UpPool,NewPoolIDstpup, NewPoolID);
                
                %% % Return NewPoolIDs
                tmp = cell(length(IncludeInPool),1);
                if(~isempty(IncludeInPool))
                    for i=1:length(IncludeInPool)
                        tmp{i,1} = NewPoolID{IncludeInPool(i),1};
                    end
                else
                    %error('No data')
                    tmp = cell(0,0);
                end
                
                NewPoolID = tmp;
            else
                NewKey = UpPoolKey;
            end
        end
    end
end



