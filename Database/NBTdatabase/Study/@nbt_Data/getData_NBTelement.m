function DataObj = getData_NBTelement(DataObj,GrpObj,StatObj)
global NBTstudy
%In this case we load the data directly from the NBTelements in base.
%We loop over DataObj.biomarkers and generate a cell
numBiomarkers       = length(DataObj.biomarkers);

if ~isa(GrpObj,'nbt_DiffGroup') % regular group
    DataObj = prepareDataObj(DataObj,GrpObj);
    DataObj = fetchDataObj(DataObj);
else
    DataObj = prepareDataObj(DataObj,NBTstudy.groups{GrpObj.groupDifference(1)});
    DataObj2.biomarkers = DataObj.biomarkers;
    DataObj2.biomarkerIdentifiers = DataObj.biomarkerIdentifiers;
    DataObj2.subBiomarkers = DataObj.subBiomarkers;
    DataObj2.classes = DataObj.classes;
    DataObj2 = prepareDataObj(DataObj2,NBTstudy.groups{GrpObj.groupDifference(2)});
    DataObj  = fetchDataObj(DataObj,DataObj2);
end

    function DataObj = prepareDataObj(DataObj,GrpObj)
        for bID=1:numBiomarkers
            biomarker = DataObj.biomarkers{bID};
            %            NBTelementCall = generateNBTelementCall(GrpObj);
            %then we generate the NBTelement call.
            NBTelementCall = ['nbt_GetData(' biomarker ',{'] ;
            %loop over Group parameters
            if (~isempty(GrpObj.parameters))
                groupParameters = fields(GrpObj.parameters);
                for gP = 1:length(groupParameters)
                    NBTelementCall = [NBTelementCall groupParameters{gP} ',{' ];
                    for gPP = 1:length(GrpObj.parameters.(groupParameters{gP}))-1
                        NBTelementCall = [NBTelementCall '''' GrpObj.parameters.(groupParameters{gP}){gPP} ''','];
                    end
                    gPP = length(GrpObj.parameters.(groupParameters{gP}));
                    NBTelementCall = [NBTelementCall '''' GrpObj.parameters.(groupParameters{gP}){gPP} '''};'];
                end
            end
            %then we loop over biomarker identifiers -
            % should be stored as a cell in a cell
            
            bIdentifiers = DataObj.biomarkerIdentifiers{bID};
            
            if(~isempty(bIdentifiers))
                % we need to add biomarker identifiers
                for bIdent = 1:size(bIdentifiers,1)
                    
                    if(ischar(bIdentifiers{bIdent,2} ))
                        if strcmp(bIdentifiers{bIdent,1},'Signals')
                            NBTelementCall = [NBTelementCall  bIdentifiers{bIdent,1} ',' '''' bIdentifiers{bIdent,2} '''' ';'];
                        else
                            NBTelementCall = [NBTelementCall  biomarker '_' bIdentifiers{bIdent,1} ',' '''' bIdentifiers{bIdent,2} '''' ';'];
                        end
                    else
                        NBTelementCall = [NBTelementCall  biomarker '_' bIdentifiers{bIdent,1} ',' num2str(bIdentifiers{bIdent,2}) ';'];
                    end
                end
            end
            NBTelementCall = NBTelementCall(1:end-1); % to remove ';'
            %layz eval
            NBTelementCall = [NBTelementCall '},[],1);'];
            snb = strfind(NBTelementCall,',');
            subNBTelementCall = NBTelementCall(snb(1):snb(end-1)-1);
            [DataObj.dataStore{bID,1}, DataObj.pool{bID,1},  DataObj.poolKey{bID,1}] = evalin('base', NBTelementCall);
            
            try
                [DataObj.subjectList{bID,1}] = evalin('base', ['nbt_GetData(Subject' subNBTelementCall ');']);
            catch me
                %Only one Subject?
                disp('Assuming only One subject?');
                [DataObj.subjectList{bID,1}] = evalin('base', 'constant{nbt_searchvector(constant , {''Subject''}),2};');
            end
        end
    end

    function DataObj = fetchDataObj(DataObj,DataObj2)
        narginchk(1,2) %if we have two DataObjecs we have difference Group
        switch GrpObj.databaseType
            case 'NBTelement'
                switch nargin
                    case 1 % normal group
                        assignin('base', 'tmpPool', DataObj.pool)
                        assignin('base', 'tmpPoolKey', DataObj.poolKey)
                        for bId = 1:numBiomarkers
                            [DataObj.dataStore{bId,1}, ~, ~, DataObj.units{bId,1}, DataObj.biomarkerMetaInfo{bId,1}] = evalin('base',['nbt_returnData(' DataObj.biomarkers{bId} ', tmpPool{' num2str(bId) '}, tmpPoolKey{' num2str(bId) '},' '''' DataObj.subBiomarkers{bId} '''' ');']);
                        end
                        evalin('base','clear tmpPool');
                        evalin('base','clear tmpPoolKey')
                    case 2 % difference group
                        assignin('base', 'tmpPool', DataObj.pool)
                        assignin('base', 'tmpPoolKey', DataObj.poolKey)
                        assignin('base', 'tmpPool2', DataObj2.pool)
                        assignin('base', 'tmpPoolKey2', DataObj2.poolKey)
                        for bId = 1:numBiomarkers
                            [DataObj.dataStore{bId,1}, ~, ~, DataObj.units{bId,1}, DataObj.biomarkerMetaInfo{bId,1}] = evalin('base',['nbt_returnData(' DataObj.biomarkers{bId} ', tmpPool{' num2str(bId) '}, tmpPoolKey{' num2str(bId) '},' '''' DataObj.subBiomarkers{bId} '''' ', tmpPool2{' num2str(bId) '}, tmpPoolKey2{' num2str(bId) '},' ''''  GrpObj.groupDifferenceType '''' ');']);
                        end
                        evalin('base','clear tmpPool');
                        evalin('base','clear tmpPoolKey')
                        evalin('base','clear tmpPool2');
                        evalin('base','clear tmpPoolKey2')
                end
            case 'File'
                switch nargin
                    case 1 % normal group
                        assignin('base', 'tmpPool', DataObj.pool)
                        assignin('base', 'tmpPoolKey', DataObj.poolKey)
                        DataObj=returnDatafromFile(DataObj);
                        evalin('base','clear tmpPool');
                        evalin('base','clear tmpPoolKey')
                    case 2 % difference group
                        assignin('base', 'tmpPool', DataObj.pool)
                        assignin('base', 'tmpPoolKey', DataObj.poolKey)
                        assignin('base', 'tmpPool2', DataObj2.pool)
                        assignin('base', 'tmpPoolKey2', DataObj2.poolKey)
                        DataObj=returnDatafromFile(DataObj, DataObj2, GrpObj.groupDifferenceType);
                        evalin('base','clear tmpPool');
                        evalin('base','clear tmpPoolKey')
                        evalin('base','clear tmpPool2');
                        evalin('base','clear tmpPoolKey2')
                end
        end
        
        
        for bID = 1:numBiomarkers
            if ~strcmp(DataObj.classes{bID},'nbt_QBiomarker')
                if (StatObj.channelsRegionsSwitch == 2) % regions
                 DataObj.dataStore{bID} = cellfun(@calcRegions,DataObj.dataStore{bID},'UniformOutput',0);
                end
            end
        end
    end

    function newData=calcRegions(data)
         regions = GrpObj.listRegData;
         for rID=1:length(regions)
             newData(rID,:) = nanmean(data(regions(rID).reg.channel_nr,:));
         end
    end

end


function DataObj=returnDatafromFile(DataObj,DataObj2, DiffFun)
narginchk(1,3)

if(nargin == 1)
    DataObj = loadData(DataObj);
else
    DiffFunH = nbt_getDiffFun(DiffFun);
    DataObj = loadData(DataObj);
    DataObj2 = loadData(DataObj2);
    for bId = 1:length(DataObj.biomarkers) 
            DataObj.dataStore{bId,1} = cellfun(DiffFunH, DataObj.dataStore{bId,1},DataObj2.dataStore{bId,1},'UniformOutPut',false);
    end
end
    function DataObj=loadData(DataObj)
        %% First we construct the file names to load
        %projectIds
        ProjectIDs = evalin('base',['nbt_returnData(Project, tmpPool{1},tmpPoolKey{1});']);
        %SubjectIds
        SubjectIDs = evalin('base',['nbt_returnData(Subject, tmpPool{1},tmpPoolKey{1});']);
        strToAdd = '0000';
        SubjectStrIDs = cell(length(SubjectIDs),1);
        for mm=1:length(SubjectIDs)
            SubStr = num2str(SubjectIDs(mm));
            lToAdd = 4 - length(SubStr);
            SubjectStrIDs{mm,1} =  ['S' strToAdd(1:lToAdd) SubStr];
        end
        %DateofRec
        try
            DateOfRec = evalin('base',['nbt_returnData(NBTe_dateOfRecording, tmpPool{1},tmpPoolKey{1});']);
        catch %in case no dates are given
            DateOfRec = 'yyyymmdd';
        end
        %ConditionIDs
        ConditionIDs = evalin('base',['nbt_returnData(Condition, tmpPool{1},tmpPoolKey{1});']);
        
        fileNames = strcat(ProjectIDs,'.',SubjectStrIDs','.',DateOfRec,'.',ConditionIDs,'_analysis.mat');
        
        %% Then we load first file and find the name of the biomarker to load
        % using the unique identifiers
        [DataObj,BiomarkerLoadName]=sandboxLoad(DataObj,fileNames{1,1},[]);
        %% Then we start loading analysis files and check uniqueIDs
        %if unique IDs do not match we load the full file and search
        %
        for fIdx = 2:length(fileNames)
            [DataObj]=sandboxLoad(DataObj,fileNames{fIdx},BiomarkerLoadName);
        end
    end
end


function ident=changeSignalsName(ident)
for i=1:size(ident,1)
    if(strcmp(ident{i,1},'Signals'))
        ident{i,1} = 'signalName';
    end
end
end



function [DataObj, BiomarkerLoadName] = sandboxLoad(DataObj,fileName,BiomarkerLoadName)
if(isempty(BiomarkerLoadName))
    %we need to identify the load name
    load(fileName)
    %We load each biomarker, and test conditions
    
    for bId = 1:length(DataObj.biomarkers)
        objectName = DataObj.biomarkers{bId};
        objectName = objectName(6:end);
        SearchList = nbt_ExtractObject(objectName);
        Identifiers = changeSignalsName(DataObj.biomarkerIdentifiers{bId});
        for lbId = 1:length(SearchList)
            ToTest = eval(SearchList{lbId});
            ok =1;
            for Iidx = 1:size(Identifiers,1)
                if(~strcmp(num2str(ToTest.(Identifiers{Iidx,1})),Identifiers{Iidx,2}))
                    ok = 0;
                    break;
                end
            end
            if(ok)
                BiomarkerLoadName{bId} = SearchList{lbId};
                break;
            end
        end
    end
else
    for bId = 1:length(DataObj.biomarkers)
        load(fileName,BiomarkerLoadName{bId})
    end
end
for bId = 1:length(DataObj.biomarkers)
    if(isempty(DataObj.dataStore{bId,1})) %we need to insert data at the right subject spot
        subjIdx = 1;
        DataObj.dataStore{bId,1} = cell(0,0);
    else
        subjIdx = length(DataObj.dataStore{bId,1})+1;
    end
    DataObj.dataStore{bId,1}{subjIdx,1} = eval([BiomarkerLoadName{bId} '.(DataObj.subBiomarkers{bId});']);
    if(size(DataObj.dataStore{bId,1}{subjIdx,1},2) > size(DataObj.dataStore{bId,1}{subjIdx,1},1)) %to fix bug with biomarkers with wrong dimension
        DataObj.dataStore{bId,1}{subjIdx,1} = DataObj.dataStore{bId,1}{subjIdx,1}';
    end
    DataObj.units{bId,1} = eval([BiomarkerLoadName{bId} '.units;']);
    DataObj.biomarkerMetaInfo{bId} = eval([BiomarkerLoadName{bId} '.biomarkerMetaInfo;']);
end
end

