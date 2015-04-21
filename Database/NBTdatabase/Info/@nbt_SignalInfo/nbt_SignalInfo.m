%% SignalInfo object class constructor
% SignalInfo  = nbt_SignalInfo
%
% See also:
%   nbt_CreateInfoObject

%--------------------------------------------------------------------------
% Copyright (C) 2014  Simon-Shlomo Poil
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
%--------------------------------------------------------------------------


classdef nbt_SignalInfo
    properties
        subjectInfo                 %Pointer to SubjectInfo file (typical the same file)
        signalName                  %The name of the signal
        signalID                    %A unique ID genearated by nbt_makeNBTDID;
        signalSHA256                %The SHA256 hash of the Signal
        signalOrigin                % Filename (path) of the raw signal or previous signal RawSignal> CleanSignal >ICASignal.
        researcherID                % Researcher ID
        signalType                  % EEG or other type of Signal
        signalLink                  % To link to planar signals in MEG
        signalUnit                  % The unit of the signal, the signal should scaled to this unit during import (default: microvolts for EEG signals)
        frequencyRange              %If the signal has be filtered the frequencyRange in [lp hp] format
        filterSettings              % Struct with filtersettings.
        cleaningSettings            % Struct with cleaning settings
        timeOfRecording             % time and date of recording in YYYYMMDD-HHMMSS format.
        originalSamplingFrequency   %The recorded sampling frequency
        notes                       %For additional notes about the signal
        badChannels                 %Logical list of bad channels 1 for bad, 0 for good.
        nonEEGch                    % List of non EEG channels
        eyeCh                       % List of Eye channels
        reference                   % Reference channel
        lastUpdate                  % When the Signal was saved
        log                         % For log of changes to the signal
        interface                   %A struct with info relevant for interfacing with other toolboxes 
        nbtVersion                  % The NBT version using nbt_getVersion
        listOfBiomarkers 
    end
    
    properties(Dependent)
        convertedSamplingFrequency
    end
    
    properties(Access=private)
       privconverted_sample_frequency 
    end
    
    methods
        function SignalInfo = nbt_SignalInfo
            if(isempty(SignalInfo.nbtVersion))
                SignalInfo.nbtVersion = nbt_getVersion;
            end
            if(isempty(SignalInfo.signalID))
                SignalInfo.signalID = nbt_MakeNBTDID;
            end
            SignalInfo.lastUpdate = datestr(now);
        end
        
        %we support only setting .convertedSamplingFrequency
        function obj = set.convertedSamplingFrequency(obj, value)
                if(isempty(obj.originalSamplingFrequency))
                    obj.originalSamplingFrequency = value;
                end
                obj.privconverted_sample_frequency = value;
        end
        
        function v = get.convertedSamplingFrequency(obj)
            v = obj.privconverted_sample_frequency;
        end
        
        function Biomarker = SetBadChannelsToNaN(Info,Biomarker)
            Biomarker(:,find(Info.badChannels)) = nan(size(Biomarker,1),length(find(Info.badChannels)));
        end 
        
        function yesno = checkHash(SignalInfo, Signal)
            yesno = false;
            if(~isempty(SignalInfo.signalSHA256))
                yesno = strcmp(nbt_getHash(single(Signal)),SignalInfo.signalSHA256);
            end
        end
        
        function check(SignalInfo, RawSignalInfo, fileName, SignalName) %function to check the format of the SignalInfo
      
        % check subjectInfo
            pathIdx = strfind(fileName,filesep);
           fileName = fileName(pathIdx(end)+1:end);
           nbt_stringCheck(SignalInfo.subjectInfo,fileName(1:end-9), 'SignalInfo: subjectInfo not correct')
        %signalName
        nbt_stringCheck(SignalInfo.signalName,SignalName,'SignalInfo: signalName not correct')
        %NBTDID 
        nbt_stringCheck(SignalInfo.signalID,RawSignalInfo.signalID, 'SignalInfo: signalID not correct')
        
        %sampling frequency
        if(isempty(SignalInfo.convertedSamplingFrequency))
           error('SignalInfo: Sampling frequency missing') 
        end
        end
    end
end