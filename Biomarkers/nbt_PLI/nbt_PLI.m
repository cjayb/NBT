classdef nbt_PLI < nbt_CrossChannelBiomarker
    properties
        pliVal
        Median
        Mean 
        IQR
        Std
    end
    properties (Constant)
        biomarkerType = {'nbt_CrossChannelBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker'};
        units = {' ',' ',' ',' ',' '};
    end
    methods
        function BiomarkerObject = nbt_PLI(NumChannels)
            BiomarkerObject.pliVal = nan(NumChannels, NumChannels);
            BiomarkerObject.Median = nan(NumChannels,1);
            BiomarkerObject.Mean = nan(NumChannels,1);
            BiomarkerObject.IQR = nan(NumChannels,1);
            BiomarkerObject.Std = nan(NumChannels,1);
            BiomarkerObject.primaryBiomarker = 'PLI';
            BiomarkerObject.biomarkers = {'pliVal'};
        end
    end
end

