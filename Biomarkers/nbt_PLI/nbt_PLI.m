classdef nbt_PLI < nbt_CrossChannelBiomarker
    properties
        pliVal
        Median
        Mean 
        IQR
        Std
    end
    properties (Constant)
        biomarkerType = {'nbt_CrossChannelBiomarker','nbt_CrossChannelBiomarker','nbt_CrossChannelBiomarker','nbt_CrossChannelBiomarker','nbt_CrossChannelBiomarker'};
        units = {' ',' ',' ',' ',' '};
    end
    methods
        function BiomarkerObject = nbt_PLI(NumChannels)
            BiomarkerObject.pliVal = nan(NumChannels, NumChannels);
            BiomarkerObject.Median = nan(NumChannels);
            BiomarkerObject.Mean = nan(NumChannels);
            BiomarkerObject.IQR = nan(NumChannels);
            BiomarkerObject.Std = nan(NumChannels);
            BiomarkerObject.primaryBiomarker = 'PLI';
            BiomarkerObject.biomarkers = {'pliVal'};
        end
    end
end

