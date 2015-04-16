% This method returns an InfoCell which, e.g., can be used to fill the boxes in the
% defineGroup GUI.
function [InfoCell, BioCell, IdentCell,GrpObj, FileInfo] = getSubjectInfo(GrpObj)
IdentCell = cell(0,0);
%First we determine which database is used.
switch GrpObj.databaseType
    case 'NBTelement' %NBTelement database in base.
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
                disp('Loading NBTelementBase.mat...please wait...')
                evalin('base', 'load(''NBTelementBase.mat'')');
            catch % in the case the NBTelement database does not exist
                disp('NBTeleementBase.mat not found...generating...')
                disp('NBT: Assuming your data is in current directory: importing from current directory')
                nbt_importGroupInfos(pwd); %import data to NBTelements
                nbt_pruneElementTree;      %prune elements with only one level
                evalin('base', 'load(''NBTelementBase.mat'')');
            end
            s = whos('-file','NBTelementBase.mat');
            m = 1;
            for i = 1:length(s)
                if(strcmp(s(i).class, 'nbt_NBTelement'))
                    flds{m} = s(i).name;
                    m = m+1;
                end
            end
        end
        index = zeros(length(flds),1);
        for i = 1:length(flds)
            index(i) = evalin('base',[flds{i} '.ElementID';]);
        end
        
        [~, inds] = sort(index);
        
        %InfoCell = cell(length(inds),2);
        k = 0;
        n = 0;
        m = 0;
        for i = 1:length(inds)
            if evalin('base',[flds{inds(i)} '.Identifier';])
                m= m+1;
                IdentCell{m,1} = flds{inds(i)};
                IdentCell{m,2} = evalin('base',[flds{inds(i)} '.Data;']);
            else
                isBiomarker = evalin('base',[flds{inds(i)} '.isBiomarker;']);
                bios = evalin('base',[flds{inds(i)} '.Biomarkers;']);
                if ~isBiomarker;
                    k= k+1;
                    InfoCell{k,1} = flds{inds(i)};
                    InfoCell{k,2} = evalin('base',[flds{inds(i)} '.Data';]);
                else
                    %Its a biomarker
                    
                    %work out how many unique identifiers the biomarker has
                    identStore = [];
                    parent = evalin('base',[flds{inds(i)} '.Uplink']);
                    parent = find(index==parent);
                    while evalin('base',[flds{parent} '.Identifier == 1'])
                        identStore = [identStore; parent];
                        parent = evalin('base',[flds{parent} '.Uplink']);
                        parent = find(index==parent);
                    end
                    noIdents = length(identStore);
                    
                    if noIdents >0
                        %work out how many unique biomarkers there, by
                        %looking at the ids
                        ids = evalin('base',[flds{identStore(1)} '.ID']);
                        idsStore = zeros(length(ids),length(identStore));
                        for id = 1:length(ids)
                          %  stt = strsplit(ids{id},'.');
                          [stt, idKeep] = strtok(ids{id},'.');
                            for j = 1:length(identStore)
                                idsStore(id,j) = str2num(stt);
                                [stt, idKeep] = strtok(idKeep,'.');
                            end
                        end
                        uniqueIds = unique(idsStore,'rows');
                        
                        %Get names of identifiers
                        nameIdent = [];
                        for a = 1:noIdents
                                 tmp = flds{identStore(a)};
                                 if(~strcmp('Signals',tmp))
                                    nameIdent{a} = tmp(length(flds{inds(i)}) + 1:end);
                                 else
                                     nameIdent{a} = '_Signals';
                                 end
                        end
                        
                        %construct overall biomarkers
                        for j = 1:size(uniqueIds,1)
                            nm = [flds{inds(i)} '{'];
                            for a = 1:noIdents
                                nm = [nm nameIdent{a} '_' evalin('base',[flds{identStore(a)} '.Data{' num2str(uniqueIds(j,a))  '};'])];
                            end
                            
                            for k = 1:length(bios)
                                n = n+1;
                                BioCell{n} = [nm '}.' bios{k}];
                            end
                        end
                    else
                        for j = 1:length(bios)
                            n = n+1;
                            BioCell{n} = [flds{inds(i)} '.' bios{j}];
                        end
                    end   
                end
            end
        end
    case 'File' %File based database.
        disp('This part does not work yet')
        [FileInfo, GrpObj] = getFileInfo(GrpObj);
        readconditions = unique(FileInfo(:,2));
        readproject = unique(FileInfo(:,3));
        readsubject = unique(FileInfo(:,4));
        readdate = unique(FileInfo(:,5));
        
        temp=FileInfo(:,6);
        emptyCells = cellfun(@isempty,temp);
        temp(emptyCells) = [];
        readgender=unique(temp);
        
        temp=FileInfo(:,7);
        emptyCells = cellfun(@isempty,temp);
        temp(emptyCells) = [];
        readage=unique(cell2mat((temp)));
        [biomarker_objects,biomarkers] = nbt_extractBiomarkers([GrpObj.databaseLocation filesep FileInfo{1,1}]);
        
end

end