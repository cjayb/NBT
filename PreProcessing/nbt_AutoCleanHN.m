% nbt_AutoClean(Signal,SignalInfo)
%
%
%
% Usage:
%
%
% Inputs:
%
%    
% Outputs:
%
% Example:
%
%
% References:
% 
% See also: 
%
  
%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2012), see NBT website for current
% email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2012 Simon-Shlomo Poil  
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
% ---------------------------------------------------------------------------------------

function [Signal, SignalInfo] = nbt_AutoCleanHN(Signal, SignalInfo, SignalPath, EyeCh , NonEEGCh)
narginchk(3,5)
% narginchk(3,3)

EyeCh = [8, 14, 21, 25, 125, 126, 127, 128];
NonEEGCh = [8, 14, 21, 25, 125, 126, 127, 128];

%    if(isempty(SignalInfo.nonEEGch))
%       SignalInfo.nonEEGch = input('Please specify Non-EEG channels: ');
%    end
% 
%    if(isempty(SignalInfo.eyeCh))
%      SignalInfo.eyeCh = input('Please specify eye channels: ');
%    end
%    
% if(~exist('NonEEGCh','var'))
%     NonEEGCh = SignalInfo.nonEEGch;
% end
% if(~exist('EyeCh','var'))
%     EyeCh = SignalInfo.eyeCh;
% end
   
% Protocol
%. 0. Ref-ref to Cz
%first we find Cz
cznotfound = true;
for CzID = 1:SignalInfo.interface.EEG.nbchan
    if(strcmpi(SignalInfo.interface.EEG.chanlocs(CzID).labels,'Cz'))
        cznotfound = false;
        break;
    end
end
if(cznotfound)
    CzID = input('Please specify Cz channel number');
end

% CzID = SignalInfo.interface.EEG.ref;

%Downsample to 250 Hz
%[Signal, SignalInfo] = nbt_EEGLABwrp(@pop_resample, Signal, SignalInfo, [], 0, 250);
%SignalInfo.convertedSamplingFrequency = 250;
%Re-reference to Cz
% [Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_ReRef, Signal,SignalInfo,SignalPath,[],0,CzID);
[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_ReRef, Signal,SignalInfo,SignalPath,[],CzID);
% 1. Filter Data
[Signal] = nbt_filter_fir(Signal,0.5,45,SignalInfo.convertedSamplingFrequency,2/0.5,1);
% 2. Mark Bad Channels
[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_FindBadChannels, Signal, SignalInfo, [] , 0, 's', NonEEGCh);
SignalInfo.badChannels(NonEEGCh) = 1;
% 3. Reject Transient artifacts
[Signal, SignalInfo] = nbt_AutoRejectTransient(Signal,SignalInfo,NonEEGCh);
% 4. Run ICA
[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_filterbeforeICA, Signal, SignalInfo, [], 0, '',4,-1);
% 5. Reject ICA compoents
[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_AutoRejectICA,Signal, SignalInfo, [],0, EyeCh,0);
% 6. Average Ref
[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_ReRef,Signal, SignalInfo, [],0,[]);
% nbt_SaveSignal(Signal, SignalInfo, SignalPath,1,'AutoICASignal')
nbt_SaveSignal(Signal, SignalInfo, SignalPath,1,'FSTR_CleanSignal')
end