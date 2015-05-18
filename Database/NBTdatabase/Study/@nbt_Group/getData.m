function  DataObj = getData(GrpObj,StatObj)
    %Get data loads the data from a Database depending on the settings in the
    %Group Object and the Statistics Object.
    narginchk(1,2);

    global NBTstudy
    try
        NBTstudy = evalin('base','NBTstudy');
    catch
        evalin('base','global NBTstudy');
        evalin('base','NBTstudy = nbt_Study;');
    end


    %grpNumber refers to the ordering in the StatObj
    grpNumber = GrpObj.grpNumber;

    if ~isempty(StatObj.data)
        DataObj = StatObj.data{grpNumber};
    else
        %%% Get the data
        DataObj = nbt_Data;

        if ~exist('StatObj','var')
            for i=1:length(GrpObj.biomarkerList)
                [DataObj.biomarkers{i}, DataObj.biomarkerIdentifiers{i}, DataObj.subBiomarkers{i}, DataObj.classes{i}, DataObj.units{i}] = nbt_parseBiomarkerIdentifiers(GrpObj.biomarkerList{i});
            end
        else
            grpNumber = find(ismember(StatObj.groups, GrpObj.grpNumber)==1);
            DataObj.biomarkers = StatObj.group{grpNumber}.biomarkers;
            DataObj.subBiomarkers = StatObj.group{grpNumber}.subBiomarkers;
            DataObj.biomarkerIdentifiers = StatObj.group{grpNumber}.biomarkerIdentifiers;
            if(isfield(StatObj.group{grpNumber},'biomarkerIndex'))
                DataObj.biomarkerIndex = StatObj.group{grpNumber}.biomarkerIndex;
            end
            DataObj.classes = StatObj.group{grpNumber}.classes;
        end

        numBiomarkers       = length(DataObj.biomarkers);
        DataObj.dataStore   = cell(numBiomarkers,1);
        DataObj.pool        = cell(numBiomarkers,1);
        DataObj.poolKey     = cell(numBiomarkers,1);

        switch GrpObj.databaseType
            %switch database type
            case 'NBTelement'
                %In this case we load the data directly from the NBTelements in base.
                %We loop over DataObj.biomarkers and generate a cell
                for bID=1:numBiomarkers

                    if isempty(GrpObj.groupDifference) % regular group
                        DataObj = createDataObj(DataObj,bID,GrpObj,StatObj.channelsRegionsSwitch);
                    else
                        DataObj = createDataObj(DataObj,bID,NBTstudy.groups{GrpObj.groupDifference(1)},StatObj.channelsRegionsSwitch);
                        DataObj2 = createDataObj(DataObj,bID,NBTstudy.groups{GrpObj.groupDifference(2)},StatObj.channelsRegionsSwitch);
                        d1 = DataObj.dataStore{bID};
                        d2 = DataObj2.dataStore{bID};
                        for k=1:size(d1)
                            switch NBTstudy.groups{end}.groupDifferenceType
                                case 'regular'
                                    d1{k} = d1{k}-d2{k};
                                case 'absolute'
                                    d1{k} = abs(d1{k}-d2{k}); % abs difference
                                case 'squared'
                                    d1{k} = (d1{k}-d2{k}).^2; % square difference
                            end
                        end
                        DataObj.dataStore{bID} = d1;

                        %                DataObj.dataStore = cellfun(@minus, DataObj.dataStore{1}, DataObj2.dataStore{1},'Un',0);
                        %                 for k=1:size(DataObj.dataStore,1)
                        %                     DataObj.dataStore{k} = num2cell(DataObj.dataStore{k}');
                        %                 end
                        DataObj.subjectList = [DataObj.subjectList; DataObj2.subjectList];
                        DataObj.pool = [DataObj.pool; DataObj2.pool];
                        DataObj.poolKey = [DataObj.poolKey; DataObj2.poolKey];
                    end

                end
            case 'File'
        end

       if isempty(GrpObj.groupDifference) % regular group
           DataObj.numSubjects = length(DataObj.subjectList{1,1}); %we assume there not different number of subjects per biomarker!
       else
           DataObj.numSubjects = length(DataObj2.subjectList{1,1});
       end
        DataObj.numBiomarkers = size(DataObj.dataStore,1);
        % Call outputformating here >
    end

    function DataObj = createDataObj(DataObj,bID,GrpObj,ChansOrRegs)
        
        biomarker = DataObj.biomarkers{bID};
        subBiomarker = DataObj.subBiomarkers{bID};
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
        NBTelementCall = [NBTelementCall '},' ''''  subBiomarker '''' ');'];
        [DataObj.dataStore{bID,1}, DataObj.pool{bID,1},  DataObj.poolKey{bID,1}, DataObj.units{bID,1}] = evalin('base', NBTelementCall);
        snb = strfind(NBTelementCall,',');
        subNBTelementCall = NBTelementCall(snb(1):snb(end)-1);
            try
                [DataObj.subjectList{bID,1}] = evalin('base', ['nbt_GetData(Subject' subNBTelementCall ');']);
            catch me
                %Only one Subject?
               disp('Assuming only One subject?');
               [DataObj.subjectList{bID,1}] = evalin('base', 'constant{nbt_searchvector(constant , {''Subject''}),2};');

            end

            if ~strcmp(DataObj.classes{bID},'nbt_QBiomarker')
                if (ChansOrRegs == 2) % regions
                    n_chans = size(GrpObj.chanLocs,2);
                    regions = GrpObj.listRegData;
                    DataMat = DataObj{bID,1}; % n_chans x n_subjects
                    RegData = [];
                    for j=1:length(regions)
                        RegData = [RegData; nanmean(DataMat(regions(j).reg.channel_nr,:),1)];    
                    end
                    n_subjects = size(RegData,2);
                    Regs = cell(n_subjects,1);
                    for k=1:n_subjects
                        Regs{k} = RegData(:,k);
                    end
                    DataObj.dataStore{bID} = Regs;
                end
            end
                
    end
end
