classdef nbt_biomarkerCurve < nbt_PairedStat
    properties      
    end 
    
    methods
        function obj = nbt_biomarkerCurve(obj)
            obj.testName = 'biomarker curve';
        end
               
        function obj = calculate(obj, StudyObj) 
            
            n_groups = length(obj.groups);
            
            for n_group = 1:length(obj.groups)
                
                Data_groups{n_group} = StudyObj.groups{obj.groups(n_group)}.getData(obj);
                
            end
            
            biom_names = obj.getBiomarkerNames;
            
            for bID=1:size(Data_groups{1}.dataStore,1)               
                
                DataGrpBiom = cell(1,n_groups);
                
                for n_group = 1:length(obj.groups)
                    
                    DataGrp = Data_groups{n_group};
                    DataGrpBiom{n_group} = nanmean(DataGrp{bID,1},1);
                    n_subjects(n_group) = size(DataGrp{1,1},2);
                    
                end
                
                min_subjects = min(n_subjects);
                DataGrMat = [];
                DataGrMat2 = [];
                
                for n_group = 1:length(obj.groups)
                    
                    DatGrB = DataGrpBiom{n_group};
                    DataGrMat(:,n_group) = DatGrB(1:min_subjects);
                    % DataGrMat2 = [DataGrMat2 DatGrB(1:min_subjects)];
                    
                end
                
                
                for i=1:n_groups
                    groupNames{i}=StudyObj.groups{i}.groupName;
                end
                
                figure
                subplot(2,1,1)
                boxplot(DataGrMat,'notch','on','Label',groupNames)
                
                title(biom_names(bID),'interpreter','none')
                xlabel('Group number')
                ylabel('Biomarker value')
                
                subplot(2,1,2)
                boxplot(DataGrMat,'plotstyle','compact','Label',groupNames)
                
                title(biom_names(bID),'interpreter','none')
                xlabel('Group number')
                ylabel('Biomarker value')
                
                %     %plot only means
                %     figure
                %     means = cellfun(@mean,DataGrpBiom);
                %     plot(means,'m*')
                %     title(['Group means for ' bioms_name(bioms_ind(bID))],'interpreter','none')
                %     xlabel('Group number')
                %     ylabel('Biomarker value')
                %     ax = gca;
                %     set(ax,'XTickLabel', groupNames)
                
            end
            
        end
    end
end

