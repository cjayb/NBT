% Copyright (C) 2009 Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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

function AmplitudeCorrObject = nbt_doAmplitudeCorr(Signal, SignalInfo)

AmplitudeCorrObject = nbt_AmplitudeCorr(size(Signal,2));
Signal = nbt_RemoveIntervals(Signal,SignalInfo);

MarkerValues = AmplitudeCorrObject.MarkerValues;
for i=1:size(Signal(:,:),2)-1
    tic
    disp(i)
    [VecCorr]=corr(Signal(:,i),Signal(:,i+1:end),'type','spearman'); 
    MarkerValues(i,i+1:end) = VecCorr;
    toc
end


MarkerValues  = triu(MarkerValues,1) + triu(MarkerValues, 1);
for i=1:length(MarkerValues)
    %single index attempts
    AmplitudeCorrObject.MaxCorr(i) = max(MarkerValues(MarkerValues(:,i)~=1,i));
    AmplitudeCorrObject.MinCorr(i) = min(MarkerValues(:,i));
    AmplitudeCorrObject.MedianCorr(i) = nanmedian(MarkerValues(:,i));
    AmplitudeCorrObject.MeanCorr(i) = nanmean(MarkerValues(:,i));
    % AmplitudeCorrObject.StdCorr(i) = std(VecCorr);
    AmplitudeCorrObject.StdCorr(i) = sqrt(nanvar(MarkerValues(:,i)));
    AmplitudeCorrObject.IQRCorr(i) = iqr(MarkerValues(:,i));
    AmplitudeCorrObject.RangeCorr(i) = range(MarkerValues(:,i));
end
    
 AmplitudeCorrObject.MarkerValues = MarkerValues;

    AmplitudeCorrObject = nbt_UpdateBiomarkerInfo(AmplitudeCorrObject, SignalInfo);    
end
