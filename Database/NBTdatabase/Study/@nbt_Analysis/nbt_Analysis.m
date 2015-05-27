classdef nbt_Analysis < handle
    
    properties
        groupStatHandle % e.g. @nanmedian or @median to produce group statistics.
        groups
        group %
        %group{x}.biomarkers
        %group{x}.subBiomarkers
        %group{x}.biomarkerIdentifiers
        %group{x}.class
        %biomarkerIdentifiers = cell(1,1);
        %subBiomarkers
        channels
        regions
        channelsRegionsSwitch
        uniqueBiomarkers
        data
    end
    
    methods
        function obj = nbt_Analysis()
        end
        
        function biomarkerNames = getBiomarkerNames(StatObj)
            for m=1:length(StatObj.group{1}.biomarkers)
                prefixIdx = strfind(StatObj.group{1}.biomarkers{m},'_');
                prefixIdx = prefixIdx(end);
                identFlag = true;
                for identLoop = 1:size(StatObj.group{1}.biomarkerIdentifiers{m},1)
                    if(strcmp(StatObj.group{1}.biomarkerIdentifiers{m}{identLoop},'frequencyRange'))
                        biomarkerNames{m} = [StatObj.group{1}.biomarkers{m}(prefixIdx+1:end) '.' StatObj.group{1}.subBiomarkers{m} ' : ' StatObj.group{1}.biomarkerIdentifiers{m}{identLoop,2}];
                        identFlag = false;
                    end
                end
                if(identFlag)
                    biomarkerNames{m} = [StatObj.group{1}.biomarkers{m}(prefixIdx+1:end) '.' StatObj.group{1}.subBiomarkers{m}];
                end
                biomarkerNames{m} = strrep(biomarkerNames{m},'_','.');
            end
        end
       
        plot(AnalysisObj);
        
    end   
end

