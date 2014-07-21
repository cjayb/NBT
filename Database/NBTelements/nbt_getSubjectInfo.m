% This method returns an InfoCell which, e.g., can be used to fill the boxes in the
% defineGroup GUI.
function [InfoCell, BioCell] = nbt_getSubjectInfo
%First we determine which database is used.
%Any Elements loaded?
s = evalin('base', 'whos');
k = 0;
for i = 1:length(s)
    if strcmp(s(i).class,'nbt_NBTelement');
        k= k+1;
        flds{k} = s(i).name;
    end
end
if k==0
    try
        evalin('base', 'load(''NBTelementBase.mat'')');
    catch % in the case the NBTelement database does not exist
        nbt_importGroupInfos(pwd);
        nbt_pruneElementTree;
        evalin('base', 'load(''NBTelementBase.mat'')');
    end
    s = whos('-file','NBTelementBase.mat');
    for i = 1:length(s)
        flds{i} = s(i).name;
    end
end

for i = 1:length(flds)
    index(i) = evalin('base',[flds{i} '.ElementID';]);
end

[~, inds] = sort(index);

%InfoCell = cell(length(inds),2);
k = 0;
n = 0;
for i = 1:length(inds)
    bios = evalin('base',[flds{inds(i)} '.Biomarkers';]);
    if isempty(bios);
        k= k+1;
        InfoCell{k,1} = flds{inds(i)};
        InfoCell{k,2} = evalin('base',[flds{inds(i)} '.Data';]);
    else
        for j = 1:length(bios)
            n = n+1;
            BioCell{n} = [flds{inds(i)} '.' bios{j}];
        end
    end
    
end


end