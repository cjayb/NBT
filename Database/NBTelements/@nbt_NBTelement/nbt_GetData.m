% nbt_GetData() - Extract data from NBTelement database
%
% Usage:
%   >>  [Data, Pool] = nbt_GetData(NBTelement, Parameters);
%
% Inputs:
%   NBTelement     - NBTelement from where the data should be extracted
%   Parameters     - cell array with { NBTelement1, DataString1;
%   NBTelement2, DataString2; etc. }, where DataString1 impose limits on
%   NBTelement1.
%
% Outputs:
%   Data     - The data
%    Pool     - Pool of IDs
%
% Example:
% We have an NBTelement structure consisting of Biomarker, Biomarker2 and
% Condition. We want values from Biomarker where Biomarker2 is equal to 4
% and Condition is ECR2:
%[Data, Pool] = GetData(Biomarker, {Biomarker2,'find(NBTelement.Data == ...
%4)';Condition,'find(strcmp(NBTelement.Data,''ECR2''))'});
%
% e.g. if Biomarker2 data is in a cell {'8  13'} and you want the subBiomarker
%'markerValues
%[Data, Pool] = nbt_GetData(Biomarkers, {Biomarker2,'8  13'}, 'markerValues');
% See also:
%   NBT_SETDATA, NBT_NBTELEMENT, NBT_CONNECTNBTELEMENTS, NBT_SEARCHSTRING

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

function [Data, Pool, PoolKey, Units] = nbt_GetData(NBTelement, Parameters, SubBiomarker,lazySwitch)
narginchk(2,4);
if(~exist('lazySwitch','var'))
   lazySwitch = 0; 
end

%% First find structure.
StructureTable = cell(1,1);
% Find main branch
MainBranch = [];
Keyy = NBTelement.Key;
[KeyToken Keyy] = strtok(Keyy,'.');
dummy = [1];
while (~isempty(Keyy))
    MainBranch = [MainBranch; str2double(KeyToken)];
    [KeyToken, Keyy] = strtok(Keyy,'.');
end
MainBranch = [MainBranch; str2double(KeyToken)];
MainBranch = flipud(MainBranch);
MainBranch = unique(MainBranch);

% Find links to main branch
tmpBranch = [];
for mm=1:size(Parameters,1)
    Keyy = Parameters{mm,1}.Key;
    KeyToken = strtok(Keyy,'.');
    dummy = [1];
    while (~isempty(Keyy))
        tmpBranch = [tmpBranch str2double(KeyToken)];
        [KeyToken, Keyy] = strtok(Keyy,'.');
    end
    tmpBranch = [tmpBranch str2double(KeyToken)];
    tmpBranch = unique(tmpBranch);
    StructPlace = nbt_searchvector(MainBranch, tmpBranch);
    StructPlace = StructPlace(end);
    tmpBranch = [];
    try
        StructureTable{StructPlace,1}= [StructureTable{StructPlace,1} mm];
    catch
        StructureTable{StructPlace,1} = mm;
    end
end

Pool = [];
stepdown = 1;
while(isempty(StructureTable{stepdown,1}))
    stepdown = stepdown+1;
end
PoolKey = Parameters{StructureTable{stepdown,1}(1),1}.Key;
%Limit pool on highest element etc.
StopLoop = 0;
for i=stepdown:size(StructureTable,1)
    if(~isempty(StructureTable{i,1}))
        index = StructureTable{i,1};
        for ii=1:length(index)
            if(isempty(Parameters{index(ii),2})) % implement [] operator
                Pool = Parameters{index(ii),1}.ID;
                PoolKey = Parameters{index(ii),1}.Key;
            else
                [Pool, PoolKey] = nbt_LimitPool(Parameters{index(ii),1}, Pool, PoolKey, Parameters{index(ii),2});
                if(isempty(Pool))
                    StopLoop = 1;
                    break;
                end
            end
        end
    end
    if(StopLoop==1)
        break;
    end
end

if(isempty(Pool))
    warning('NBTelement:No data found for these parameters')
    Pool = [];
    Data = [];
    PoolKey = [];
    Units = [];
    return
end



%Return Data
if(lazySwitch)
    Data = [];
else
    isSubBiomarker = 0;
    if(exist('SubBiomarker','var'))
        if(~isempty(SubBiomarker))
            isSubBiomarker = 1;
        end
    end
    if(isSubBiomarker)
        [Data, Pool, PoolKey, Units]=nbt_returnData(NBTelement,Pool,PoolKey, SubBiomarker);
    else
        [Data, Pool, PoolKey, Units]=nbt_returnData(NBTelement,Pool,PoolKey);
    end
end

