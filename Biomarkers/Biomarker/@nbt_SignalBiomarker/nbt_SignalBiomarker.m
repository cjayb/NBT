% nbt_SignalBiomarker(NumChannels) - Creates a NBT Signal Biomarker object - this is the
% basic NBT biomarker object for signal biomarkers
%
% Usage:
%   >>  SignalBiomarker = nbt_SignalBiomarker(NumChannels);
%
% Inputs:
%   NumChannels -  Number of Channels
%
% Outputs:
%   SignalBiomarker     - SignalBiomarker object


%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2014), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2014 Simon-Shlomo Poil  (Neuronal Oscillations and Cognition group,
% Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research,
% Neuroscience Campus Amsterdam, VU University Amsterdam)
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
% -


classdef (Abstract) nbt_SignalBiomarker < nbt_CoreBiomarker
    properties
        numChannels % Number of channels.
        samplingFrequency   % The sampling frequency
        frequencyRange %Frequency range of processed signal [] means broadband.
        filterSettings % Defintion of filter settings applied to the signal.
        signalName % Name of the signal used to compute the biomaker
        signalID %signalDID of the signal used to compute the biomakrer
    end
    methods
        function BiomarkerObject = nbt_SignalBiomarker()
            % no content.
        end
        
        function biomarkerObject=nbt_UpdateBiomarkerInfo(biomarkerObject, SignalInfo)
            biomarkerObject.lastUpdate = datestr(now);
            biomarkerObject.nbtVersion = nbt_getVersion;
            biomarkerObject.signalID = SignalInfo.signalID;
            biomarkerObject.signalName =  SignalInfo.signalName;
            biomarkerObject.subjectInfo = SignalInfo.subjectInfo;
            biomarkerObject.samplingFrequency = SignalInfo.convertedSamplingFrequency;
            if isempty(biomarkerObject.frequencyRange)
                biomarkerObject.frequencyRange = SignalInfo.frequencyRange;
            end
            biomarkerObject.filterSettings = SignalInfo.filterSettings;
            
            %set Badchannels to NaN
            if(~isempty(SignalInfo.badChannels))
                for i=1:length(biomarkerObject.biomarkers)
                    eval(['biomarker=biomarkerObject.' biomarkerObject.biomarkers{1,i} ';']);
                    if(iscell(biomarker))
                        for m=1:length(biomarker)
                            if(~iscell(biomarker{m,1}))
                                biomarker{m,1}(find(SignalInfo.badChannels)) = NaN;
                            else
                                for mm=1:length(biomarker{m,1})
                                    biomarker{m,1}{mm,1}(find(SignalInfo.badChannels)) = NaN;
                                end
                            end
                        end
                    else
                        biomarker(find(SignalInfo.badChannels)) = NaN;
                    end
                    eval(['biomarkerObject.' biomarkerObject.biomarkers{1,i} '=biomarker;']);
                end
            end
        end
        
        
        function BiomarkerObject = setUniqueIdentifiers(BiomarkerObject)
            BiomarkerObject.uniqueIdentifiers = {'frequencyRange'}; %This is the default for Signal biomarkers
        end
        
        
        function BiomarkerObject = convertBiomarker(BiomarkerObject,subjectInfo)
            try
                BiomarkerObject.markerValues = BiomarkerObject.MarkerValues; % the biomarker values
            catch
                if(~isempty(BiomarkerObject.MarkerValues))
                   error('You need to define a markerValues field in your biomarker to convert it from the old format') 
                end
            end
            BiomarkerObject.numChannels  = BiomarkerObject.NumChannels; % number of channels
            BiomarkerObject.samplingFrequency = BiomarkerObject.Fs; % The sampling frequency
            BiomarkerObject.lastUpdate = BiomarkerObject.DateLastUpdate; %last date this biomarker was updated
            BiomarkerObject.primaryBiomarker = BiomarkerObject.PrimaryBiomarker; % the primary biomarker to use in scripts
            BiomarkerObject.biomarkers = BiomarkerObject.Biomarkers; % list of all biomarkers in the object
            BiomarkerObject.researcherID = BiomarkerObject.ReseacherID; % ID of the Reseacher or script that made the last update
            BiomarkerObject.frequencyRange = BiomarkerObject.FrequencyRange; %Frequency range of processed signal [] means broadband.
            BiomarkerObject.signalName = BiomarkerObject.SignalName; % Name of the signal used to compute the biomaker
            BiomarkerObject.signalID = BiomarkerObject.NBTDID; %NBTDID of the signal used to compute the biomakrer
            BiomarkerObject.nbtVersion = BiomarkerObject.NBTversion;
            BiomarkerObject.subjectInfo = subjectInfo(1:end-13);
            BiomarkerObject = setUniqueIdentifiers(BiomarkerObject);
            
           % if isempty(BiomarkerObject.frequencyRange)
                
            
        end 
    end % end methods
end
