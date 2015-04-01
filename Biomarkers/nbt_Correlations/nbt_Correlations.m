classdef nbt_Correlations < nbt_CrossChannelBiomarker  % define here the name of the new object, here we choose nbt_Biomarker_template
    properties
        % add here the fields that are specific for your biomarker.
        %See the definition of nbt_Biomarker for fields that are allready there. For example:
        correlation
        pValues
    end
    methods
        % Now follows the definition of the function that makes a biomarker
        % of the type "nbt_Biomarker_template". The name of this function should alway be
        % the same as the name of the new biomarker object, in this example nbt_Biomarker_template
        % The inputs contain the information you want to add to the biomarker object :
        function BiomarkerObject =nbt_Correlations(nChannels)
            % assign values that each biomarker object has, for example:
            BiomarkerObject.correlation = nan(nChannels, nChannels);
            BiomarkerObject.pValues = nan(nChannels, nChannels);
            
            BiomarkerObject.Biomarkers = {'correlations'};
        end
    end
    
end

