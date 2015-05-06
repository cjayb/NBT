%Copyright (C) 2010 Simon-Shlomo Poil
function [Data, Pool, PoolKey, Units]=nbt_returnData(NBTelement,Pool,PoolKey, SubBiomarker)
error(nargchk(3,4,nargin));
if(isempty(Pool))
    Data = [];
    Pool = [];
    PoolKey = [];
    return
end

%match Key with Poolkey


%Match PoolKey
KeyToMatch = NBTelement.Key;
DataPool = NBTelement.ID;
%First prepare to match, i.e. get same key length
%step up ?
while(length(strfind(KeyToMatch,'.')) > length(strfind(PoolKey,'.')))
    [StripOff, KeyToMatch] = strtok(KeyToMatch,'.');
    KeyToMatch = KeyToMatch(2:end);
    [StripOff, DataPool] = strtok(DataPool,'.');
    DataPool = nbt_TrimCellStr(DataPool);
    
end
% step down
while (length(strfind(KeyToMatch,'.')) < length(strfind(PoolKey,'.')))
    [StripOff, PoolKey] = strtok(PoolKey,'.');
    PoolKey = PoolKey(2:end);
    [StripOff, Pool] = strtok(Pool,'.');
    Pool=nbt_TrimCellStr(Pool);
end

%Do they Keys match? step up if not
while(~strcmp(KeyToMatch,PoolKey))
    [StripOff, PoolKey] = strtok(PoolKey,'.');
    PoolKey = PoolKey(2:end);
    [StripOff, Pool] = strtok(Pool,'.');
    Pool= nbt_TrimCellStr(Pool);
    [StripOff, KeyToMatch] = strtok(KeyToMatch,'.');
    KeyToMatch = KeyToMatch(2:end);
    [StripOff, DataPool] = strtok(DataPool,'.');
    DataPool = nbt_TrimCellStr(DataPool);
end

%Return Data
DataID = NBTelement.ID;
[IncludePool DataID] = nbt_MatchPools(Pool,DataPool, DataID);

if(~exist('SubBiomarker','var'))
    if(iscell(NBTelement.Data))
        Data = NBTelement.Data(:, (str2double(strtok(DataID(IncludePool(:)),'.'))));
    else
        Data = NBTelement.Data((str2double(strtok(DataID(IncludePool),'.'))));
    end
    Units = NBTelement.BiomarkerUnit;
else
    for mm=1:length(NBTelement.Biomarkers)
        if(strcmp(NBTelement.Biomarkers{mm}, SubBiomarker))
            for i=1:length(IncludePool)
            Data{i,1} =  NBTelement.Data{mm,(str2double(strtok(DataID(IncludePool(i)),'.')))};
            if (~isempty(NBTelement.BiomarkerUnit))
                Units = NBTelement.BiomarkerUnit{mm};
            else
               Units = [];
            end
            end
            break
        end
    end
end

Pool = DataID(IncludePool);
PoolKey = NBTelement.Key;
if(isempty(IncludePool))
   Data = [];
   Pool = [];
   Units = [];
end

end