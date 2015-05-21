% function StatObj = nbt_comparebiomarkers
classdef nbt_comparebiomarkers < nbt_Stat
    properties
    end
    
    methods
        %         function obj = nbt_ttest(obj)
        %             obj.testOptions.tail = 'both';
        %         end
        
        function obj = calculate(obj, StudyObj)
                        
            % global NBTstudy
            % biomarkerNames = get(findobj('Tag','ListBiomarker'),'String');
            % %biomarkerNames = StatObj.getBiomarkerNames;
            %
            % for i = 1:length(biomarkerNames)
            %     b(i) = strcmp(biomarkerNames{i},'rsq.Answers');
            % end
            
            % if nnz(b(i)) > 0
            %     %load rsq
            %     rs = load([G(1).fileslist(1).path '/' G(1).fileslist(1).name],'rsq');
            %     rsq = rs.rsq;
            % end
            
            nbt_compareBiomarkersPanel(obj, StudyObj);
            
            %Other Functions
            %nbt_compareBiomarkersGetSettings
            %nbt_compareBiomakersPlotTopos
            
        end
    end
   
end