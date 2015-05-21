function DataObj = getData_NBTelement(GrpObj,StatObj, DataObj)
global NBTstudy
%In this case we load the data directly from the NBTelements in base.
%We loop over DataObj.biomarkers and generate a cell
numBiomarkers       = length(DataObj.biomarkers);

if isempty(GrpObj.groupDifference) % regular group
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
                            [DataObj.dataStore{bId,1}, ~, ~, DataObj.units{bId,1}] = evalin('base',['nbt_returnData(' DataObj.biomarkers{bId} ', tmpPool{' num2str(bId) '}, tmpPoolKey{' num2str(bId) '},' '''' DataObj.subBiomarkers{bId} '''' ');']);
                        end
                        evalin('base','clear tmpPool');
                        evalin('base','clear tmpPoolKey')
                    case 2 % difference group
                        assignin('base', 'tmpPool', DataObj.pool)
                        assignin('base', 'tmpPoolKey', DataObj.poolKey)
                        assignin('base', 'tmpPool2', DataObj2.pool)
                        assignin('base', 'tmpPoolKey2', DataObj2.poolKey)
                        for bId = 1:numBiomarkers
                            [DataObj.dataStore{bId,1}, ~, ~, DataObj.units{bId,1}] = evalin('base',['nbt_returnData(' DataObj.biomarkers{bId} ', tmpPool{' num2str(bId) '}, tmpPoolKey{' num2str(bId) '},' '''' DataObj.subBiomarkers{bId} '''' ', tmpPool2{' num2str(bId) '}, tmpPoolKey2{' num2str(bId) '},' ''''  GrpObj.groupDifferenceType '''' ');']);
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
                        DataObj=returnDatafromFile(DataObj, DataObj2);
                        evalin('base','clear tmpPool');
                        evalin('base','clear tmpPoolKey')
                        evalin('base','clear tmpPool2');
                        evalin('base','clear tmpPoolKey2')
                end
        end
        
        
        for bID = 1:numBiomarkers
            if ~strcmp(DataObj.classes{bID},'nbt_QBiomarker')
                if (StatObj.channelsRegionsSwitch == 2) % regions
                    regions = GrpObj.listRegData;
                    DataMat = DataObj{bID,1}; % n_chans x n_subjects
                    RegData = [];
                    for j=1:length(regions)
                        RegData = [RegData; nanmean(DataMat(regions(j).reg.channel_nr,:),1)];
                    end
                    n_subjects = size(RegData,2);
                    Regs = cell(n_subjects,1);
                    for kk=1:n_subjects
                        Regs{kk} = RegData(:,kk);
                    end
                    DataObj.dataStore{bID} = Regs;
                end
            end
        end
    end
end


function DataObj=returnDatafromFile(DataObj,DataObj2)
narginchk(1,2)

disp('break')
%First we construct the file names to load

%Then we load first file and find the name of the biomarker to load 
% using the unique identifiers

%Then we start loading analysis files and check uniqueIDs
%if unique IDs do not match we load the full file and search
%

end


