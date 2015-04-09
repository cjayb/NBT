
%  EEG=nbt_NBTtoEEG(Signal, SignalInfo, SignalPath)
%  convert NBT Signal into EEG struct (in workspace)
%
%  Usage:
%  EEG=nbt_NBTtoEEG(Signal, SignalInfo, SignalPath)
%
% Inputs:
%   Signal
%   SignalInfo
%   SignalPath
%
% Output:
%   EEG
%
% See also:
%   nbt_EEGtoNBT

%--------------------------------------------------------------------------
% Copyright (C) 2008  Neuronal Oscillations and Cognition group,
% Department of Integrative Neurophysiology, Center for Neurogenomics and
% Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
%--------------------------------------------------------------------------


function EEG=nbt_NBTtoEEG(Signal, SignalInfo, SignalPath, SubjectInfo)
narginchk(3,4);
try
    if(~isempty(SignalInfo.interface.EEG))
        EEG = SignalInfo.interface.EEG;
    else
        EEG = eeg_emptyset;
    end
catch
    EEG = eeg_emptyset;
end
EEG.data = Signal(:,:)';
EEG.srate = SignalInfo.convertedSamplingFrequency;
EEG.setname = SignalInfo.subjectInfo;

EEG.pnts = size(EEG.data,2);
SignalInfo.interface.EEG=[];
EEG.NBTinfo = SignalInfo;

%Remove noisy intervals
if(isfield(SignalInfo.interface,'noisey_intervals'))
    EEG = eeg_eegrej(EEG,SignalInfo.interface.noisey_intervals);
    SignalInfo.interface.noisey_intervals = [];
    %eval(['save(' ' ''' SignalPath SignalInfo.file_name '_info.mat'' , ''SignalInfo'')' ])
end


EEG.NBTinfo = SignalInfo;
if(exist('SubjectInfo','var'))
    EEG.NBTSubjectInfo = SubjectInfo;
else
    EEG.NBTSubjectInfo = [];
end
EEG = eeg_checkset(EEG);
end

