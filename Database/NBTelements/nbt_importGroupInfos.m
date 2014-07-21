%  Copyright (C) 2010: Simon-Shlomo Poil
function nbt_importGroupInfos(startpath)
if(~exist('startpath','var'))
    startpath = uigetdir(pwd,'Select folder with NBT analysis files');
end

%SubjectInfo properties
%projectInfo
%researcherID
%subjectID
%conditionID
%lastUpdate
%listOfBiomarkers

% load('NBTelementBase.mat')
%NBTelement structure

Project = nbt_NBTelement(1,'1',[]);
Subject = nbt_NBTelement(2, '2.1',1);
Condition = nbt_NBTelement(3,'3.2.1',2);
Signals = nbt_NBTelement(4,'4.3.2.1',3);

% could include last Update

NextID = 5;

%determine tree
FileList = nbt_ExtractTree(startpath,'mat','analysis');

for i=1:length(FileList)
    load(FileList{1,i}) %load analysis file
    clear SubjectInfo;
    load([ FileList{1,i}(1:end-12) 'info.mat']) % load info file
    
    signalFields = nbt_extractSignals([ FileList{1,i}(1:end-12) 'info.mat']);
    subjectFields = fields(SubjectInfo.info);
    subjectBiomarkerFields = SubjectInfo.listOfBiomarkers;
    
    for m=1:length(subjectFields)
        % create NBTelement, unless it exists
        NBTelementName = subjectFields{m};
        eval(['NBTelementClass = class(SubjectInfo.info.' NBTelementName ');']);
        eval(['NBTelementData = SubjectInfo.info.' NBTelementName ';']);
        
        
        addflag = ~exist(NBTelementName,'var');
        if(addflag)
            eval([NBTelementName '= nbt_NBTelement(' int2str(NextID) ',''' int2str(NextID) '.3.2.1'', 3);']);
            NextID = NextID + 1;
        end
        
        Project = nbt_SetData(Project, {SubjectInfo.projectInfo(1:end-4)}, []);
        Subject = nbt_SetData(Subject, SubjectInfo.subjectID, {Project, SubjectInfo.projectInfo(1:end-4)});
        Condition = nbt_SetData(Condition, {SubjectInfo.conditionID}, {Subject, SubjectInfo.subjectID; Project, SubjectInfo.projectInfo(1:end-4)});
        
        if strcmp(NBTelementClass,'char')
            eval([NBTelementName '= nbt_SetData(' NBTelementName ', {NBTelementData}, {Condition, SubjectInfo.conditionID; Subject, SubjectInfo.subjectID; Project, SubjectInfo.projectInfo(1:end-4)});']);
        else
            eval([NBTelementName '= nbt_SetData(' NBTelementName ', NBTelementData, {Condition, SubjectInfo.conditionID; Subject, SubjectInfo.subjectID; Project, SubjectInfo.projectInfo(1:end-4)});']);
        end
        
    end
    
    for m = 1:length(subjectBiomarkerFields)
        
        
        eval(['NBTelementName = class(' subjectBiomarkerFields{m} ');']);
          
        
        addflag = ~exist(NBTelementName,'var');
        if addflag
            eval([NBTelementName '= nbt_NBTelement(' int2str(NextID) ',''' int2str(NextID) '.3.2.1'', 3);'])
            NextID = NextID + 1;
        end
        %Create the Data cell
        
        eval(['NumBiomarkers = length(' subjectBiomarkerFields{m} '.biomarkers);']);
        if(NumBiomarkers ~=0)
            for dd = 1:NumBiomarkers
                eval( ['DataString = nbt_cellc(' subjectBiomarkerFields{m} '.biomarkers,dd);']);
                eval(['Data{dd,1} = ' subjectBiomarkerFields{m} '.' DataString ';']);
                eval([NBTelementName '.Biomarkers{ dd ,1} = DataString; '])
            end
            eval([NBTelementName ' = nbt_SetData(' NBTelementName ', Data, {Condition, SubjectInfo.conditionID; Subject, SubjectInfo.subjectID;Project, SubjectInfo.projectInfo(1:end-4)});']);
            
            clear Data
        end
    end
    
    
    for mm = 1:length(signalFields)
        Signals = nbt_SetData(Signals,{signalFields{mm}},{Condition, SubjectInfo.conditionID; Subject, SubjectInfo.subjectID; Project, SubjectInfo.projectInfo(1:end-4)});
        BiomarkerList = eval([signalFields{mm} 'Info.listOfBiomarkers']);
        for m = 1:length(BiomarkerList)
            % create NBTelement, unless it exists
            eval(['NBTelementName = class(' BiomarkerList{m} ');']);
        
            NumIdentifiers  = eval([BiomarkerList{m} '.uniqueIdentifiers;']);
            
            connector = Signals;
            connectorKeys = 'Signals,signalFields{mm};Condition, SubjectInfo.conditionID; Subject, SubjectInfo.subjectID; Project, SubjectInfo.projectInfo(1:end-4)';
            for ni = 1:length(NumIdentifiers)    
                addflag = ~exist(NumIdentifiers{ni},'var');
                if(addflag)
                    eval([NumIdentifiers{ni} '= nbt_NBTelement(' int2str(NextID) ',''' int2str(NextID) '.' connector.Key ''', ' num2str(connector.ElementID) ');'])    
                    eval([NumIdentifiers{ni} '.Identifier = true;']);
                     NextID = NextID + 1;
                end
                
                eval(['connector = ' NumIdentifiers{ni} ';']);
                
                connectorValue = {num2str(eval([BiomarkerList{m} '.' NumIdentifiers{ni}]))};
                oldValue{ni} = num2str(eval([BiomarkerList{m} '.' NumIdentifiers{ni}]));
                
                newStuff = eval(['''' NumIdentifiers{ni} ', oldValue{' num2str(ni) '}''']);
                
                    
                eval([NumIdentifiers{ni} '= nbt_SetData(' NumIdentifiers{ni} ', connectorValue ,{' connectorKeys '});']);
                
                
                connectorKeys = [newStuff, ';' ,  connectorKeys];
                
            end
            
            
            addflag = ~exist(NBTelementName,'var');
            if(addflag)
                eval([NBTelementName '= nbt_NBTelement(' int2str(NextID) ',''' int2str(NextID)  '.' connector.Key '''  , ' num2str(connector.ElementID) ');'])    
                NextID = NextID + 1;
            end
            
            %Create the Data cell
            eval(['NumBiomarkers = length(' BiomarkerList{m} '.biomarkers);']);
            if(NumBiomarkers ~=0)
                for dd = 1:NumBiomarkers
                    eval( ['DataString = nbt_cellc(' BiomarkerList{m} '.biomarkers,dd);']);
                    eval(['Data{dd,1} = ' BiomarkerList{m} '.' DataString ';']);
                    eval([NBTelementName '.Biomarkers{ dd ,1} = DataString; '])
                end
                
                eval([NBTelementName ' = nbt_SetData(' NBTelementName ', Data, {' connectorKeys '});']);
                
                
                clear Data
            end
        end
    end
end

s = whos;
for ii=1:length(s)
    if(~strcmp(s(ii).class,'nbt_NBTelement') && ~strcmp(s(ii).name,'s'))
        clear([s(ii).name])
    end
end
clear s
clear ii


save NBTelementBase.mat
disp('NBTelements imported')
disp('NBTelementBase.mat saved in')
disp(pwd)
end