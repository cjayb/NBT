%This function removes NBTelements with only one level.
function nbt_pruneElementTree

elements = load('NBTelementBase.mat');
flds = fields(elements);
level = zeros(length(flds),1);
for i = 1:length(flds)
    keys(i).k = eval(['elements.' flds{i} '.Key;']);
    level(i) = length(strfind(keys(i).k,'.'));
    ids(i) = eval(['elements.' flds{i} '.ElementID;']);
end

maxLevel = max(level);
pruned = 0;
for i = maxLevel:-1:0
    leaves = find(level==i);
    for j = 1:length(leaves)
        leaf = leaves(j);
        leafTypes(leaf) = eval(['length(elements.' flds{leaf} '.Data);']);
        isBiomarker = eval(['elements.' flds{leaf} '.isBiomarker;']);
        if leafTypes(leaf) > 1 || isBiomarker
            disp(['keeping node ' flds{leaf}]);
        else
            disp(['pruning node ' flds{leaf}]);
            pruned = pruned+1;
            elements.constant{pruned,1} = flds{leaf};
            elements.constant{pruned,2} = eval(['elements.' flds{leaf} '.Data;']);
            
            childs = eval(['elements.' flds{leaf} '.Children;']);
            if length(childs) < 1
                disp(['      node ' flds{leaf} ' has no Children']);
                parent = eval(['elements.' flds{leaf} '.Uplink;']);
                parentName = ['elements.' flds{find(ids==parent)}];
                id = eval(['elements.' flds{leaf} '.ElementID;']);
                eval([parentName '.Children = ' parentName '.Children(' parentName '.Children ~= id);']);
                elements = rmfield(elements,flds{leaf});
            else
                disp(['      node ' flds{leaf} ' has  Children']);
                
                parent = eval(['elements.' flds{leaf} '.Uplink;']);
                if isempty(parent)
                    disp(['      node ' flds{leaf} ' has no parent']);
                else
                    parentName = ['elements.' flds{find(ids==parent)}];
                    for k = 1:length(childs)
                        child = childs(k);
                        childName = ['elements.' flds{find(ids==child)}];
                        eval([parentName '.Children = [' parentName '.Children; ' childName '.ElementID];'])
                        eval([childName '.Uplink = parent;']);
                        elements = removeID(elements,ids, flds, childName,ids(leaf));
                    end
                    id = eval(['elements.' flds{leaf} '.ElementID;']);
                    eval([parentName '.Children = ' parentName '.Children(' parentName '.Children ~= id);']);
                    elements = rmfield(elements,flds{leaf});
                end
            end
        end
    end
end

save('NBTelementBase.mat','-struct','elements','-v7.3');

end
function elements = removeID(elements,ids, flds, childName, ID)
grandChilds = eval([childName '.Children;']);

if ~isempty(grandChilds)
    for gc = 1:length(grandChilds)
        grandChildName = ['elements.' flds{find(ids==grandChilds(gc))}];
        elements = removeID(elements, ids, flds, grandChildName, ID);
    end
end
kys = eval([childName '.Key;']);
place = strfind(kys,num2str(ID));
if(isempty(place)) % nothing to remove
    return
end
place = place(end); %Hack for double digit numbers
indPlace = strfind(kys,'.');
indd = max(find(indPlace<place));

oldIDs = eval([childName '.ID;']);
for ii = 1:length(oldIDs)
    st = oldIDs{ii};
    iid = strfind(st,'.');
    if indd == length(iid)
        st = st(1:iid(indd)-1);
    else
        st = [st(1:iid(indd)-1) st(iid(indd+1):end)];
    end
    oldIDs{ii} = st;
end
hck = length(num2str(ID));
kys = kys([1:place-2 place+hck:end]);
eval([childName '.Key = kys;']);
eval([childName '.ID = oldIDs;']);

end
