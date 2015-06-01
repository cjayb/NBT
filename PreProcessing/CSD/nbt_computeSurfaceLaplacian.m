function [CSDSignal, CSDSignalInfo, G, H] = nbt_computeSurfaceLaplacian(Signal, SignalInfo, SignalPath, SubjectInfo, autosave, order, m, lambda)
    if (nargin < 1); error('No Signal found.'); end;
    if (nargin < 2); error('No SignalInfo found.'); end;
    if (nargin < 3); error('No SubjectInfo found.'); end;
    if (nargin < 4); SignalPath = pwd; end;
    if (nargin < 5); autosave = 0; end;
    
    % Get the number of channels
    chanLocs = SignalInfo.interface.EEG.chanlocs;
    nChannels = length(chanLocs);
    
    if (nargin < 6)
        if nChannels > 100
            order = 40;
        else
            order = 20;
        end
    end
    
    if (nargin < 7)
        if nChannels > 100
            m = 3;
        else
            m = 4;
        end
    end
    
    if (nargin < 8); lambda = 1e-5; end;
    
    
    % 1. Convert electrode coordinates to cartesian using sph2cart
    for i = 1 : nChannels
        Theta(i) = (pi/180) * chanLocs(i).theta;
        Phi(i) = (pi/180) * chanLocs(i).sph_phi;
    end
    [X,Y,Z]     = sph2cart(Theta,Phi,1.0);
    
    % 2. Calculate the cos distance between all electrodes E and F
    % (Equation 4)
    cosdist = zeros(nChannels);
    for E = 1 : nChannels
        for F = 1 : nChannels
            cosdist(E,F) = 1 - (((X(E) - X(F))^2 + (Y(E) - Y(F))^2 + (Z(E) - Z(F))^2) / 2);
        end
    end
    
    % 3. Calculate G and H matrices
    % (Equations 3 and 6 respectively)
    G = 0;
    H = 0;
    legendrePol = zeros(order, nChannels, nChannels);
    for n = 1 : order
        temp = legendre(n,cosdist);
        legendrePol(n,:,:) = temp(1,:,:);
        
        G = G + (((2*n + 1) .* legendrePol(n,:,:)) / ((n * n + n)^m));
        H = H + ( ((-2.0*n-1.0) * legendrePol(n,:,:)) / ((n*n+n)^(m-1)) );
    end
    G = (1/(4*pi)) * squeeze(G);
    H = (1/(4*pi)) * -1 * squeeze(H);
    
    % 4. Smooth G using lambda (add to the diagonal elements of G)
    G = G + eye(nChannels) * lambda;
    
    % 5. Compute the inverse of G
    Ginv = inv(G);
    
    % 6. Compute the sum per row
    rowSum = sum(Ginv);
    
    % 7. Smooth the data
    smoothedData = Signal / G;
    
    % 8. Compute the C vector
    C = smoothedData - (sum(smoothedData,2)/sum(rowSum))*rowSum;

    % 9. Compute surface Laplacian
    CSDSignal = C * H;
    
    %%% Set the SignalInfo
    CSDSignalInfo = SignalInfo;
    CSDSignalInfo.signalName = 'CSDSignal';
    CSDSignalInfo.signalType = 'CSDSignal';
    CSDSignalInfo.filterSettings = struct('LegendreOrder', order, 'splineFlexibility', m, 'smoothingConstant', lambda);
    
    %%% Save the signal?
    if autosave == 1
        nbt_SaveSignal(CSDSignal, CSDSignalInfo, SignalPath, 1, 'CSDSignal', SubjectInfo);
    else
        nbt_SaveSignal(CSDSignal, CSDSignalInfo, SignalPath, 0, 'CSDSignal', SubjectInfo);
    end
end