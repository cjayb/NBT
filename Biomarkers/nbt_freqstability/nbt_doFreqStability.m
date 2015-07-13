function biomarkerObject=nbt_doFreqStability(MasterSignal, SignalInfo, LowFreq, HighFreq)


biomarkerObject = nbt_freqstability(size(MasterSignal,2));
MasterSignal = nbt_RemoveIntervals(MasterSignal,SignalInfo);

biomarkerObject = nbt_UpdateBiomarkerInfo(biomarkerObject, SignalInfo);

%Central Frequency in windows.
WindowSize  = SignalInfo.convertedSamplingFrequency*5;
CentralFreq = nan(floor(length(MasterSignal(:,:))/WindowSize),1);
for ChId=setdiff(1:size(MasterSignal(:,:),2), SignalInfo.nonEEGch)
    Interval = [1 WindowSize];
    for i=1:floor(length(MasterSignal(:,:))/WindowSize)
        Signal = MasterSignal(Interval(1):Interval(2),ChId);
        [p,f]=pwelch(Signal(:,1),hamming(2^9),0,2^9,SignalInfo.convertedSamplingFrequency);
        findex1 = find(f >= LowFreq,1);
        findex2 = find(f <= HighFreq,1,'last');
        CentralFreq(i) = sum(p(findex1:findex2).*f(findex1:findex2))/sum(p(findex1:findex2));
        Interval = Interval + WindowSize;
    end
    biomarkerObject.CentralFrqIQR(ChId) = iqr(CentralFreq);
    biomarkerObject.CentralFrqStd(ChId) = std(CentralFreq);
    biomarkerObject.CentralFrq(ChId) =  median(CentralFreq);
end

%TF-method
for ChId=setdiff(1:size(MasterSignal(:,:),2), SignalInfo.nonEEGch)
[W,p,s,coi] = nbt_wavelet33(MasterSignal(:,ChId),1/SignalInfo.convertedSamplingFrequency,1,0.1,1.033*LowFreq,1.033*HighFreq);
TF=sqrt(abs(W));
ff = nan(floor(length(TF)/WindowSize),1);
 Interval = [1 WindowSize];
for t=1:floor(length(TF)/WindowSize)
    [dummy ff(t)] = max(median(TF(:,Interval(1):Interval(2)),2));
    Interval = Interval + WindowSize;
end
biomarkerObject.TFiqr(ChId) = iqr(ff);
biomarkerObject.TFstd(ChId) = std(ff);
biomarkerObject.TFindx(ChId) = median(ff);
end

%phase crossing method
SignalPhase = angle(hilbert(nbt_filter_fir(MasterSignal,LowFreq,HighFreq,SignalInfo.convertedSamplingFrequency,2/LowFreq)));

for ChId=setdiff(1:size(SignalPhase,2), SignalInfo.nonEEGch)
    Interval = [1 WindowSize];
    for i=1:floor(length(SignalPhase)/WindowSize)
        Signal = SignalPhase(Interval(1):Interval(2),ChId);
        [pk,locs]= findpeaks(Signal);
        numpeaks(i) = length(locs)/length(Signal);
        abovezero(i) = sum(Signal>= 0)/length(Signal);
        Interval = Interval + WindowSize;
    end
    biomarkerObject.PhaseIQR(ChId) = iqr(abovezero);
    biomarkerObject.PhaseStd(ChId) = std(abovezero);
    biomarkerObject.PhaseA(ChId) =  median(abovezero);
    biomarkerObject.PhasePIQR(ChId) = iqr(numpeaks);
    biomarkerObject.PhaseP(ChId) = median(numpeaks);
    biomarkerObject.PhasePStd(ChId) = std(numpeaks);
end
SignalInfo.frequencyRange = [LowFreq HighFreq];
biomarkerObject=nbt_UpdateBiomarkerInfo(biomarkerObject, SignalInfo);
end