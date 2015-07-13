classdef nbt_PLI < nbt_CrossChannelBiomarker
    properties
        pliVal
        Max
        Min
        Median
        Mean
        Std
        IQR
        Range        
    end
    properties (Constant)
        biomarkerType = {'nbt_CrossChannelBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker'};
        units = {' ',' ',' ',' ',' ',' ',' ',' '};
    end
    methods
        function BiomarkerObject = nbt_PLI(NumChannels)
            BiomarkerObject.pliVal = nan(NumChannels, NumChannels);
            BiomarkerObject.Max = nan(NumChannels,1);
            BiomarkerObject.Min = nan(NumChannels,1);
            BiomarkerObject.Median = nan(NumChannels,1);
            BiomarkerObject.Mean = nan(NumChannels,1);
            BiomarkerObject.Std = nan(NumChannels,1);
            BiomarkerObject.IQR = nan(NumChannels,1);
            BiomarkerObject.Range = nan(NumChannels,1);

            BiomarkerObject.primaryBiomarker = 'PLI';
            BiomarkerObject.biomarkers = {'pliVal','Max','Min','Median','Mean','Std','IQR','Range'};
        end
    end
end