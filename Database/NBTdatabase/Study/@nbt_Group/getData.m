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
            %switch database type - for clarity this switch is still here.
            case 'NBTelement'
               DataObj = getData_NBTelement(GrpObj, StatObj, DataObj);
            case 'File'
               DataObj = getData_NBTelement(GrpObj, StatObj, DataObj);
        end

        DataObj.numSubjects = length(DataObj.subjectList{1,1}); %we assume there not different number of subjects per biomarker!
        DataObj.numBiomarkers = size(DataObj.dataStore,1);
        % Call outputformating here >
    end
end
