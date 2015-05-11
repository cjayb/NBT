classdef nbt_ttest < nbt_PairedStat
    properties      
    end 
    
    methods
        function obj = nbt_ttest(obj)
            obj.testOptions.tail = 'both';
            obj.groupStatHandle = @nanmean;
            obj.testName = 'paired t-test';
        end
        
        
        function obj = calculate(obj, StudyObj)
            %Get data
            Data1 = StudyObj.groups{obj.groups(1)}.getData(obj); %with parameters);
            Data2 = StudyObj.groups{obj.groups(2)}.getData(obj); %with parameters);
            %add test of same subjects
            
            %Perform test
            sigBios = 0;
            ccBios = 0;
            qBios = 0;
            
            for bID=1:size(Data1.dataStore,1)
                
                try
                    sigBios = sigBios + 1;
                    %       [D1, D2]=nbt_MatchVectors(Data1{bID,1}, Data2{bID,1}, getSubjectList(Data1,bID), getSubjectList(Data2,bID), 0, 0);
                    [~, obj.pValues{sigBios},~,obj.statStruct{sigBios,1}] = ttest(Data1{bID,1}',Data2{bID,1}','tail',  obj.testOptions.tail);
                catch me
                    disp(['Failed - ' num2str(bID) ' ' obj.group{1}.biomarkers{bID} '.' obj.group{1}.subBiomarkers{bID}  ' class ' obj.group{1}.classes{bID}]);
                end
            end
        end
    end
end

