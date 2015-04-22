% [Signal, Info] = nbt_EEGlab2NBTsignal(EEG,saveflag)
% Will convert EEGLAB dataset to NBTsignal
%
% Usage:
%  [Signal, Info]= EEGlab2NBTsignal(EEG,saveflag)
% or
% [Signal, Info]= EEGlab2NBTsignal(EEG)
%
% Inputs:
%   EEG : EEGLAB EEG structure
%   saveflag : if it is present and equal to 1; allow to save the NBT
%              Signal and Info files in the selected folder
% Outputs:
%  Saves two files: signal and info file
%
% See also:
%   nbt_NBTsignal2EEGlab

%--------------------------------------------------------------------------
% Copyright (C) 2008  Simon-Shlomo Poil
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

function [Signal,SignalInfo, SignalPath, SubjectInfo] = nbt_EEGlab2NBTsignal(EEG,saveflag)
 warning('Use nbt_EEGtoNBT')
[Signal, SignalInfo, SignalPath, SubjectInfo] = nbt_EEGtoNBT(EEG, [], [], []);
end
