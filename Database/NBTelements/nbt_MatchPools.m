% Copyright (C) 2010 Simon-Shlomo Poil
function [IncludePool DownStreamPool] = nbt_MatchPools(PoolOne,PoolTwo, DownStreamPool)
IncludePool = [];
if(strcmp(PoolOne{1,1},'[]'))
    IncludePool = 1:length(PoolTwo);
elseif(strcmp(PoolTwo{1,1},'[]') & (length(PoolTwo) == 1)) %means we need to restrict a downstreamPool with [] syntax
    IncludePool = 1:length(PoolOne);
    DownStreamPool = strtok(DownStreamPool,'.');
    t=0;
    for u = 1:length(DownStreamPool)
        for i = 1:length(PoolOne)
            t = t+1;
            NewDownStreamPool{t,1} = [DownStreamPool{u,1} '.' PoolOne{i,1}];
        end
    end
    DownStreamPool = NewDownStreamPool;
else
    %first we check for any [] syntax
    if ((sum(cellfun('isempty',strfind(PoolTwo,'[]'))) == 0) ~= 0)
        [PoolTwo, PoolOne] = AllSyntaxCutOut(PoolTwo, PoolOne);
    end
    if ((sum(cellfun('isempty',strfind(PoolOne,'[]'))) == 0) ~= 0)
        [PoolOne, PoolTwo] = AllSyntaxCutOut(PoolOne, PoolTwo);
    end
    for i=1:length(PoolOne)
        IncludePool = [IncludePool; find(strcmp(PoolTwo,PoolOne{i,1}))];
    end
end
end

function [PoolOne, PoolTwo] = AllSyntaxCutOut(PoolOne, PoolTwo)
AllIndex = find(cellfun('isempty',strfind(PoolOne,'[]')) == 0);
for AllId = 1:length(AllIndex)
    dotIndex = strfind(PoolOne{AllId,1},'.');
    AllSpot  = strfind(PoolOne{AllId,1},'[]');
    if(isempty(AllSpot))
        continue
    end
    for AllSpotIndex =1:length(AllSpot)
        BelowDots = find(dotIndex < AllSpot(AllSpotIndex));
        AboveDots = find(dotIndex > AllSpot(AllSpotIndex));
        
        for mm = 1:size(PoolOne,1)
            PoolOne{mm,1} = CutOutString(PoolOne{mm,1});
        end
        for mm = 1:size(PoolTwo,1)
            PoolTwo{mm,1} = CutOutString(PoolTwo{mm,1});
        end
        PoolOne = nbt_TrimCellStr(PoolOne);
        PoolTwo = nbt_TrimCellStr(PoolTwo);
    end
end

%% nested functions part for AllSyntaxCutOut
    function CutString = CutOutString(CutString)
        if(isempty(AboveDots))
            CutString = CutString(1:BelowDots(end));
        elseif(isempty(BelowDots))
            CutString = CutString(AboveDots(1):end);
        else
            CutString = CutString([1:BelowDots(end) (AboveDots(1)+1):end]);
        end
    end
end