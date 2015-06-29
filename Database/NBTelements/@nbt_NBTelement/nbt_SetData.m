% nbt_SetData() - Set data in NBTelement structure
%
% Usage:
%   >>  NBTelement = nbt_SetData(NBTelement, Data, JoinArray)
%
% Inputs:
%   NBTelement      - The NBTelement that should store the new data
%   Data            - The data
%   JoinArray       - Array that defines the relations to other NBTelements
%   the array is defined as {JointNBTelement, DataID};JoinNBTelement2, DataID2}
%   data id should follow columns
%
% Outputs:
%   NBTelement     - NBTelement with new data
%
% Example:
%
% See also:
% NBT_GETDATA, NBT_NBTELEMENT, NBT_CONNECTNBTELEMENTS, NBT_SEARCHSTRING

% Copyright (C) 2010 Simon-Shlomo Poil
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

function NBTelement = nbt_SetData(NBTelement, Data, JoinArray)


if isempty(Data)
    Data = {'nbt_empty'};
end
% if iscell(Data)
%     if isnan(Data{1})
%         Data = {'nbt_nan'};
%     end
% else
%     if isnan(Data)
%         Data = {'nbt_nan'};
%     end
% end


if(~isempty(JoinArray))
    %check UpKey
    UpKey =  [];
    if(JoinArray{1,1}.ElementID == NBTelement.ElementID)
        upKeystp = 2;
    else
        upKeystp = 1;
    end
    for i=upKeystp:size(JoinArray,1)
        UpKey = [UpKey '.' int2str(JoinArray{i,1}.ElementID)];
    end
    UpKey = nbt_TrimCellStr(UpKey);
    UpKey = [int2str(NBTelement.ElementID) '.' UpKey];
    if(strcmp(NBTelement.Key, UpKey))
        %find upID
        tmpUpID = cell(1,size(JoinArray,1));
        for i=1:size(JoinArray,1)
            if(~ischar(JoinArray{i,2}) && ~isempty(JoinArray{i,2}) && ~iscell(JoinArray{i,2}))
                tmpUpID{1,i} = nbt_searchvector(JoinArray{i,1}.Data, JoinArray{i,2});
            elseif(ischar(JoinArray{i,2}))
                tmpUpID{1,i} = find(strcmp(JoinArray{i,1}.Data,JoinArray{i,2}));
            elseif(iscell(JoinArray{i,2}))
                tmpUpID{1,i} =nbt_searchvector(JoinArray{i,1}.Data,JoinArray{i,2});
            elseif(isempty(JoinArray{i,2}))
                tmpUpID{1,i} = '[]' ;% cellfun(@str2double,JoinArray{i,1}.ID);
            end
            if(isempty(tmpUpID{1,i}))
                error('You should update top NBTelements first')
            end
            tmpUpIDSize(i) =  length(tmpUpID{1,i});
        end
        
        upID = cell(1,1);
        
        lastLevel = 1;
        for i = (size(JoinArray,1)):-1:1
            tmp = tmpUpID{1,i};
            upIDt = cell(1,1);
            uu =0;
            for mm = 1:lastLevel
                if(~ischar(tmp))
                    for ii=1:tmpUpIDSize(i)
                        uu = uu+1;
                        upIDt{uu,1} = [ int2str(tmp(ii)) '.' upID{mm,1} ] ;
                    end
                else
                    uu = uu+1;
                    upIDt{uu,1} = [ '[].' upID{mm,1} ];
                end
            end
            upID = upIDt;
            if(~ischar(tmp))
                lastLevel = length(tmp);
            else
                lastLevel = 1;
            end
        end
        upID = nbt_TrimCellStr(upID);
    else
        error('JoinArray not correct')
    end
else
    upID = cell(1,1);
end
if(isempty(upID))
    error('Uplinks do not exist')
end

%Find dublicated data or create newids
%but not if numeric cells
doDeDub = 1;
if(iscell(Data) & isnumeric(nbt_cellc(Data,1)));
    doDeDub = 0;
end
if(doDeDub)
    try
        NewIDs = nbt_searchvector(NBTelement.Data, Data);
        doAppend = 0;
        if(length(NewIDs) ~= length(Data))
            NewIDs = [];
        end
    catch
        NewIDs = [];
    end
else
    NewIDs = [];
end



if(isempty(NewIDs))
    doDeDub = 0;
    doAppend = 1;
    %find current ID
    if(~isempty(NBTelement.ID))
       % CurrentID =  max(str2double(strtok(NBTelement.ID,'.')));
       CurrentID = length(NBTelement.Data);
    else
        CurrentID = 0;
    end
    % make new IDs
    NewIDs = CurrentID + [1:size(Data,2)];
else %probably we do not need to do more
    if(size(upID,1) == 1 && isempty(upID{1,1}))
        return
    end
end
IDstep = length(NBTelement.ID);

tt = 0;

if(length(NewIDs) == 1)
    NewIDs = repmat(NewIDs,size(upID,1),1);
end

%for mm=1:length(upID)
try
    for i=1:length(NewIDs)
        tt = tt+1;
        if(~isempty(upID{1,1}))
            if(~strcmp(upID{1,1},'[]'))
                if(length(NewIDs) == length(upID))
                    upIDindex = i;
                else 
                    upIDindex = 1;
                end
                NBTelement.ID{IDstep+tt,1} = [int2str(NewIDs(i)) '.' upID{upIDindex,1}];
            else
                NBTelement.ID{IDstep+tt,1} = [int2str(NewIDs(i)) '.[]'];
            end
        else
            NBTelement.ID{IDstep+tt,1} = [int2str(NewIDs(i))];
        end
    end
catch
    error('NBTELEMENT:missing Data', 'You are trying to add Data to upstream element items that do not exist')
end
%end
NBTelement.ID = nbt_TrimCellStr(NBTelement.ID);

%append data
if(doAppend)
    if(~iscell(Data))
        if(size(Data,2)>1)
            NBTelement.Data(:,(IDstep+1):((IDstep)+length(NewIDs))) = Data;
            NBTelement=nbt_PruneData(NBTelement);
        else
            if(IDstep ~=0)
                if iscell(NBTelement.Data)
                    NBTelement.Data(end+1) = {Data};
                else
                    NBTelement.Data(end+1) = Data;
                end
            else
                NBTelement.Data(1) = Data;
            end
            NBTelement=nbt_PruneData(NBTelement);
        end
    else
        if(isempty(NBTelement.Data))
            NBTelement.Data = Data;
        else
            NBTelement.Data = [NBTelement.Data, Data];
        end
    end
end
if(doDeDub)
    %NBTelement=nbt_FindDublicatedIDs(NBTelement);
    NBTelement.ID = unique(NBTelement.ID);
end
end


%% Sub-functions
function NBTelement=nbt_FindDublicatedIDs(NBTelement)
chDone =0;
IDs = NBTelement.ID;
for iii=1:size(NBTelement.ID,1)
    pDub=nbt_searchvector(NBTelement.ID,NBTelement.ID(iii,1));
    if (length(pDub) >1)
        chDone = 1;
        for m=2:length(pDub)
            IDs{pDub(m),1} =[];
        end
        
    end
end
if(chDone)
    NBTelement.ID = cell(1,1);
    tt = 0;
    for mm=1:length(IDs)
        if(~isempty(IDs{mm,1}))
            tt = tt +1;
            NBTelement.ID{tt,1} = IDs{mm,1};
        end
    end
end
end



function NBTelement=nbt_PruneData(NBTelement)
% in progress
DataTmp = NBTelement.Data;
StoreData = NBTelement;
NewData = [];
if(~iscell(DataTmp))
    %case of numeric
    DataTmp = NBTelement.Data;
    
    
    if (length(unique(DataTmp)) < length(DataTmp)) 
        for i=1:length(NBTelement.Data)
            pDub = find(DataTmp == NBTelement.Data(i));
            
            if(length(pDub) > 1)
                DataTmp(pDub(2:end)) = nan;
                NewData(pDub(1)) = DataTmp(pDub(1));
                NBTelement=nbt_rePlaceIDs(NBTelement,pDub);
            end
        end
        
        NBTelement.Data = NewData;
        NBTelement = nbt_collapseDataAndID(NBTelement);

    end

    
    
    
end
%case of string
end

function NBTelement=nbt_rePlaceIDs(NBTelement,pDub)
[ID UpIds] = strtok(NBTelement.ID,'.');
pDubb = cell(length(pDub),1);
for m=1:length(pDub)
    pDubb{m,1} = int2str(pDub(m));
end
keepID = nbt_searchvector(ID, pDubb);
UpIdsKeep = UpIds(keepID);
UpIdsKeep = nbt_TrimCellStr(UpIdsKeep);
for i=1:length(keepID)
    NBTelement.ID{keepID(i),1} = nbt_TrimCellStr([int2str(pDub(1)) '.' UpIdsKeep{i,1}]);
end
end

function NBTelement = collapseData(NBTelement, DataTmp)
[oldID, UpIds] = strtok(NBTelement.ID,'.');
newID = oldID;
newID(find(isnan(DataTmp),1,'first'):(length(oldID)-1))=oldID(find(isnan(DataTmp),1,'first')+1:end)-1;
DataTmp(find(isnan(DataTmp),1,'first'):(length(oldID)-1))=DataTmp(find(isnan(DataTmp),1,'first')+1:end)-1;
end

function NBTelement = nbt_collapseDataAndID(NBTelement)
%NBTelement = nbt_FindDublicatedIDs(NBTelement);
NBTelement.ID = unique(NBTelement.ID);
[oldID, UpIds] = strtok(NBTelement.ID,'.');

[NewID, dummy, OldIDindex] = unique(str2double(oldID));
DiffIndex = diff((NewID));
if ~isempty(DiffIndex)
    %update Data field
    NewData = NBTelement.Data(:,1:find(DiffIndex > 1,1,'first'));
    
    while(sum(DiffIndex) > length(DiffIndex))
        IndexToMove = find(DiffIndex > 1,1,'first')+1;
        tmp = NewID(IndexToMove);
        NewID(IndexToMove) = NewID(IndexToMove-1) + 1;
        NewData(:,NewID(IndexToMove)) = NBTelement.Data(:,tmp);
        DiffIndex = diff((NewID));
    end
    NewNewID = nan(length(OldIDindex),1);
    for m=1:length(OldIDindex)
        NewNewID(m) = NewID(OldIDindex(m));
    end
    NBTelement.ID = cell(0,0);
    for m=1:length(NewNewID)
        NBTelement.ID{m,1} = [num2str(NewNewID(m))  UpIds{m,1}];
    end
    NBTelement.ID = nbt_TrimCellStr(NBTelement.ID);
    NBTelement.Data = NewData;
end
end
