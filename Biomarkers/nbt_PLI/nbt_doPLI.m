% Phase lag index
% Copyright (C) 2014  Simon-Shlomo Poil
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

function PLIobject = nbt_doPLI(Signal, SignalInfo, FrequencyBand, interval, filterorder)
    %%% Initialize the PLI biomarker object
    nChannels = size(Signal(:,:),2);
    PLIobject = nbt_PLI(nChannels);
    
    %%% Remove artifact intervals
    Signal = nbt_RemoveIntervals(Signal,SignalInfo);
    
    %%% Get the signal for the specified interval
    Fs = SignalInfo.convertedSamplingFrequency;
    if ~isempty(interval)
        if interval(1) == 0
            Signal = Signal(1:interval(2)*Fs,:);
        else
            Signal = Signal(interval(1)*Fs:interval(2)*Fs,:);
        end
    end
    
    %%% The signal length must be at least 3 times the filter order
    if exist('filterorder', 'var')
        if filterorder >= size(Signal,1)/(3*2)
            error('The signal length must be at least 3 times the filter order')
        end
    else
        filterorder = 2/FrequencyBand(1);
    end
    
    %%% Filter the signal for the selected frequency band
    disp('Zero-Phase Filtering and Hilbert Transform...')
    b1 = fir1(floor(filterorder*Fs),[FrequencyBand(1) FrequencyBand(2)]/(Fs/2));
    for k = 1 : nChannels
        FilteredSignal(:,k) = filtfilt(b1,1,double(Signal(:,k)));
    end
    
    %%% Do Hilbert transform and compute the phase of the signal
    phaseSignal = angle(hilbert(FilteredSignal));
    
    %%% Calculate the Phase Lag Index
    for i = 1 : (nChannels-1)
        for m = (i+1) : nChannels
            PLIobject.pliVal(i,m) = abs(mean(sign(phaseSignal(:,i)-phaseSignal(:,m))));
        end
    end
    
    pli = PLIobject.pliVal;
    pli = triu(pli);
    pli = pli+pli';
    pli(eye(size(pli))~=0)=1;
    PLIobject.pliVal = pli;
    
    for i = 1 : nChannels
        pli_chan = pli(i,:);
        PLIobject.Max(i) = max(pli_chan(pli_chan ~= 1));
        PLIobject.Min(i) = min(pli_chan(pli_chan ~= 1));
        PLIobject.Median(i) = nanmedian(pli_chan(pli_chan ~= 1));
        PLIobject.Mean(i) = nanmean(pli_chan(pli_chan ~= 1));
        PLIobject.Std(i) = sqrt(nanvar((pli_chan(pli_chan ~= 1))));
        PLIobject.IQR(i) = iqr(pli_chan(pli_chan ~= 1));
        PLIobject.Range(i) = range(pli_chan(pli_chan ~= 1));
    end
    
    %%% Save the frequency range
    SignalInfo.frequencyRange = FrequencyBand;
    
    %%% Update the biomarker info
    PLIobject = nbt_UpdateBiomarkerInfo(PLIobject, SignalInfo);
end