classdef nbt_ttest < nbt_PairedStat
    properties
    end
    
    methods
        function obj = nbt_ttest(obj)
            obj.testOptions.tail = 'both';
        end
        
        
        function obj = calculate(obj, StudyObj)
            %Get data
            Data1 = StudyObj.groups{obj.groups(1)}.getData({obj,1}); %with parameters);
            Data2 = StudyObj.groups{obj.groups(2)}.getData({obj,2}); %with parameters);
            %add test of same subjects
            
            %Perform test
            sigBios = 0;
            ccBios = 0;
            qBios = 0;
            
            for bID=1:size(Data1.dataStore,1)
                switch (obj.group{1}.classes{bID})
                    case 'nbt_SignalBiomarker'
                        try
                            sigBios = sigBios + 1;
                            [D1, D2]=nbt_MatchVectors(Data1{bID,1}, Data2{bID,1}, getSubjectList(Data1,bID), getSubjectList(Data2,bID), 0, 0);
                            [~, obj.sigPValues(:,sigBios)] = ttest(D1',D2','tail',  obj.testOptions.tail);
                        catch me
                            disp(['Failed - ' num2str(bID) ' ' obj.group{1}.biomarkers{bID} '.' obj.group{1}.subBiomarkers{bID}  ' class ' obj.group{1}.classes{bID}]);
                        end
                    case 'nbt_CrossChannelBiomarker'
                       try
                        ccBios = ccBios + 1;
                       
                       [D1, D2]=nbt_MatchVectors(Data1{bID,1}, Data2{bID,1}, getSubjectList(Data1,bID), getSubjectList(Data2,bID), 0, 0);
                       [~, obj.ccPValues(:,ccBios)] = ttest(D1',D2','tail',  obj.testOptions.tail);
                       catch me
                             disp(['Failed - ' num2str(bID) ' ' obj.group{1}.biomarkers{bID} '.' obj.group{1}.subBiomarkers{bID}  ' class ' obj.group{1}.classes{bID}]);
                       end
                       
                    case 'nbt_QBiomarker'
                        qBios = qBios + 1;
                        [D1, D2]=nbt_MatchVectors(Data1{bID,1}, Data2{bID,1}, getSubjectList(Data1,bID), getSubjectList(Data2,bID), 0, 0);
                        [~, obj.qPValues(:,qBios)] = ttest(D1',D2','tail',  obj.testOptions.tail);
                end
                %[~, obj.qPValues(:,qBios), ~, obj.statStruct{bID,1}] = ttest(D1',D2','tail',  obj.testOptions.tail);
                
            end
            %options
            
        end
    end
    
end

