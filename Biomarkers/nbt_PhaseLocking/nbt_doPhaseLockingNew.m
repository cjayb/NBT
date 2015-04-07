function PhaseLockingObject = nbt_doPhaseLocking(Signal,SignalInfo,freqBand,interval,filterOrder,nPermutations,indexPhase)
    % Check input
    narginchk(5,7);

    % Get length of signal, number of channels and sampling frequency
    signalLength = size(Signal(:,:),1);
    nChannels = size(Signal(:,:),2);
    samplingFrequency = SignalInfo.convertedSamplingFrequency;
    
    % Set nPermutations
    if ~exist('nPermutations', 'var') | isempty(nPermutations)
        nPermutations = 0;
    end
    
    % Set the interval for the signal
    if exist('interval', 'var')
        if ~isempty(interval)
            if interval(1) == 0
                Signal = Signal(1 : interval(2) * samplingFrequency, :);
            else
                Signal = Signal(interval(1) * samplingFrequency : interval(2) * samplingFrequency, :);
            end
        end
    end
    
    % Set n and m
    if ~exist('indexPhase', 'var')
        n = 1;
        m = 1;
    else
        n = indexPhase(1);
        m = indexPhase(2);
    end
    
    % Initialize the phase-locking object
    PhaseLockingObject = nbt_PhaseLocking(signalLength, nChannels, nPermutations);
    
    % Set filter order
    if ~exist('filterOrder', 'var')
        PhaseLockingObject.filterOrder = 2 / freqBand(1);
    else
        PhaseLockingObject.filterOrder = filterOrder;
    end
    
    % Start communication with user
    disp(' ')
    disp('Command window code:')
    disp(['PhaseLockingObject = nbt_doPhaseLocking(Signal,SignalInfo,FrequencyBand,interval,filterorder)'])
    disp(' ')

    disp(['Computing Phase Locking for ',SignalInfo.subjectInfo(1:end-9)])

    % Remove artifactual intervals	
    Signal = nbt_RemoveIntervals(Signal,SignalInfo);
    
    % Set the FIR filter
    filter = fir1(floor(PhaseLockingObject.filterOrder * samplingFrequency),[freqBand(1) freqBand(2)]/(samplingFrequency/2));
    
    % Filter the signal
    disp('Zero-Phase Filtering and Hilbert Transform...')
    FilteredSignal = zeros(signalLength,nChannels);
    for channel = 1 : nChannels
        FilteredSignal(:,channel) = filtfilt(filter, 1, double(Signal(:,channel)));
    end
    
    % Apply Hilbert transform
    Signal = hilbert(FilteredSignal);
    
    % Cut of edges because of ringing effect
    perc10w = floor(signalLength*0.1);
    Signal = Signal(perc10w:end-perc10w,:);
    
    % Cut the signal into nPermutations + 1 pieces of 1 second
    % Set the windowlength (nSeconds * samplingFrequency)
    windowLength = 1 * samplingFrequency;
    
    % Initialize storing the windows
    phaseWindows = zeros(windowLength,nChannels,nPermutations + 1);
    
    % Set lower and upper bound for first window
    lowerBound = 1;
    upperBound = windowLength;
    
    % Unwrap the signal for all windows
    for permutation = 1 : nPermutations + 1
        disp(permutation)
        phaseWindows(:,:,permutation) = unwrap(angle(Signal(lowerBound:upperBound,:)));
        lowerBound = upperBound + 1;
        upperBound = upperBound + windowLength;
    end
     
    % Compute phase-locking value    
    for channel1 = 1 : (nChannels - 1)
        for channel2 = channel1 + 1 : nChannels
            disp(['channels(', num2str(channel1), ',' num2str(channel2), ')']);
            
            % Compute PLV on the first window in phaseWindows
            phase1 = phaseWindows(:,channel1,1);
            phase2 = phaseWindows(:,channel2,1);
            
            RP=n*phase1-m*phase2;
            PhaseLockingObject.PLV(channel1,channel2)=abs(sum(exp(1i*RP)))/length(RP);
            
            % Compute the indices based on Shannon entropy, based on the
            % conditional probability and based on the intensity of the
            % first Fourier mode of the distribution
            [PhaseLockingObject.IndexE(channel1,channel2), PhaseLockingObject.IndexCP(channel1,channel2), PhaseLockingObject.IndexF(channel1,channel2)] = nbt_n_m_detection(phase1,phase2,n,m);
            
            if nPermutations == 0
                % Compute surrogate PLV's using all other windows in
                % phaseWindows

                % Take a random permutation of all windows, excluding the first
                % window, which we use for computing the true PLV
                permutedWindows = randperm(nPermutations);
                for permutation = 1 : nPermutations
                    phaseSurrogate = phaseWindows(:,channel2,permutedWindows(permutation),1);
                    RP=n*phase1-m*phaseSurrogate;
                    PhaseLockingObject.surrogatePLV(channel1,channel2,permutation) = abs(sum(exp(1i*RP)))/length(RP);
                end
            end
        end
    end
    
    % Store information in the phase-locking object
    PhaseLockingObject.ratio = [n m];
    PhaseLockingObject.instantPhase = phaseWindows(:,:,1);
    PhaseLockingObject.interval = [];
    
    % Store information in the signal info
    SignalInfo.frequencyRange = freqBand;
    
    % Update biomarker objects using the biomarker template
    PhaseLockingObject = nbt_UpdateBiomarkerInfo(PhaseLockingObject, SignalInfo);
end