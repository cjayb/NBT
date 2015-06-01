%Copyright (C) 2010 Simon-Shlomo Poil
function [Data, Pool, PoolKey, Units, metaInfo]=nbt_returnData(NBTelement,Pool,PoolKey, SubBiomarker, Pool2, PoolKey2, DiffFun)
narginchk(3,7);
if(isempty(Pool))
    Data = [];
    Pool = [];
    PoolKey = [];
    return
end

if(exist('SubBiomarker','var'))
    if(isempty(SubBiomarker))
        clear SubBiomarker;
    end
end
if(nargin > 4)
    calcDifferenceGroup = true;
    DiffFun = nbt_getDiffFun(DiffFun); %get difference function
else
    calcDifferenceGroup = false;
end

if(calcDifferenceGroup)
    [IncludePool, DataID] = findIncludePool(Pool, PoolKey);
    [IncludePool2, DataID2] = findIncludePool(Pool2, PoolKey2);
    fetchDataDiff;
else
    [IncludePool, DataID] = findIncludePool(Pool, PoolKey);
    fetchData;
end

Pool = DataID(IncludePool);
PoolKey = NBTelement.Key;
if(isempty(IncludePool))
    Data = [];
    Pool = [];
    Units = [];
end

%nested functions part
    function [IncludePool, DataID] = findIncludePool(Pool, PoolKey)
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
        [IncludePool, DataID] = nbt_MatchPools(Pool,DataPool, DataID);
    end

    function fetchData
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
                    Data = cell(length(IncludePool),1);
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
        metaInfo = NBTelement.BiomarkerMetaInfo;
    end

    function fetchDataDiff
        if(~exist('SubBiomarker','var'))
            error('Differences not supported without a subBiomarker argument');
        else
            for mm=1:length(NBTelement.Biomarkers)
                if(strcmp(NBTelement.Biomarkers{mm}, SubBiomarker))
                    Data = cell(length(IncludePool),1);
                    for i=1:length(IncludePool)
                        Data{i,1} = DiffFun(NBTelement.Data{mm,(str2double(strtok(DataID(IncludePool(i)),'.')))},NBTelement.Data{mm,(str2double(strtok(DataID(IncludePool2(i)),'.')))});
                        if (~isempty(NBTelement.BiomarkerUnit))
                            Units = NBTelement.BiomarkerUnit{mm};
                        else
                            Units = [];
                        end
                    end
                    break
                end
            end
            metaInfo = NBTelement.BiomarkerMetaInfo;
        end
    end
end


