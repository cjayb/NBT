% Copyright (C) 2009  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
%
% Part of the Neurophysiological Biomarker Toolbox (NBT)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% See Readme.txt for additional copyright information.
%

% ChangeLog - see version control log for details
% <date> - Version <#> - <text>

classdef nbt_AmplitudeCorr < nbt_CrossChannelBiomarker
    properties
        AmpCorr
        Max
        Min
        Median
        Mean
        Std
        IQR
        Range
    end
    properties (Constant)
        biomarkerType = {'nbt_CrossChannelBiomarker','nbt_SignalBiomarker', 'nbt_SignalBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker','nbt_SignalBiomarker'};
        units = {' ',' ',' ',' ',' ',' ',' ',' '};
    end
    methods
        function BiomarkerObject = nbt_AmplitudeCorr(NumChannels)
            if nargin == 0
                NumChannels = 1;
            end
            BiomarkerObject.AmpCorr = nan(NumChannels,NumChannels);
            BiomarkerObject.Max = nan(NumChannels,1);
            BiomarkerObject.Min = nan(NumChannels,1);
            BiomarkerObject.Median = nan(NumChannels,1);
            BiomarkerObject.Mean = nan(NumChannels,1);
            BiomarkerObject.Std = nan(NumChannels,1);
            BiomarkerObject.IQR = nan(NumChannels,1);
            BiomarkerObject.Range = nan(NumChannels,1);
            BiomarkerObject.lastUpdate = datestr(now);
            BiomarkerObject.primaryBiomarker = 'AmpCorr';
            BiomarkerObject.biomarkers ={'AmpCorr','Max', 'Min','Median','Mean','Std','IQR','Range'};
            BiomarkerObject = setUniqueIdentifiers(BiomarkerObject);
        end
        
        function BiomarkerObject = setUniqueIdentifiers(BiomarkerObject)
            BiomarkerObject.uniqueIdentifiers = {'frequencyRange'};
        end
        
        function Output=nbt_GetAmplitudeCorr(AmpCorrObject,SubjectRange, ChId1, ChId2)
            % Output=GetAmplitudeCorr(AmpCorrObject,SubjectRange, ChId1, ChId2)
            %
            % Extracts amplitude correlation values from the AmpCorrObject
            %
            % See also AmplitudeCorr, DoAmplitudeCorr
            Output =[];
            for i = SubjectRange
                temp = AmpCorrObject.AmpCorr{i,1};
                Output = [Output temp(ChId1,ChId2)];
            end
            
        end
    end
end

