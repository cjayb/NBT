% nbt_doAmpDist - 
%
% Usage:
%   AmpDistObject = nbt_doAmpDist(Signal,InfoObject)
%
% Inputs:
%   Signal
%   InfoObject
%
% Outputs:
%    
%
% Example:
%    
%
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by "your name" (2010), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) <year>  <Main Author>  (Neuronal Oscillations and Cognition group, 
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
% -------------------------------------------------------------------------


function AmpDistObject= nbt_doAmpDist(Signal,InfoObject)
%%   give information to the user	
disp(' ')
disp('Command window code:')
disp(['AmpDistObject = nbt_doAmpDist(Signal,SignalInfo,FrequencyBand)'])
disp(' ')
disp(['Computing Amplitude distribution for ',InfoObject.subjectInfo(1:end-9)])

%% remove artifact intervals	

Signal = nbt_RemoveIntervals(Signal,InfoObject);

%% Initialize the biomarker object

AmpDistObject = nbt_ampDist(size(Signal,2));
%% get info from InfoObject
AmpDistObject = nbt_UpdateBiomarkerInfo(AmpDistObject, InfoObject);
%% Compute markervalues. Add here your algorithm to compute the biomarker
for ChId = setdiff(1:(size(Signal,2)), InfoObject.nonEEGch) % loop over channels
    AmpDistObject.Kurtosis(ChId) = kurtosis(Signal(:,ChId));
    AmpDistObject.Skewness(ChId) = skewness(Signal(:,ChId));
    AmpDistObject.Iqr(ChId) = iqr(Signal(:,ChId));
    AmpDistObject.Median(ChId) = median(Signal(:,ChId));
    AmpDistObject.Range(ChId) = range(Signal(:,ChId));
    AmpDistObject.Cov(ChId) = std(Signal(:,ChId))/median(Signal(:,ChId));
end
end