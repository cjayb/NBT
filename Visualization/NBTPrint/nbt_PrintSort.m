function order = nbt_PrintSort(biomarkers)%, Delta, Theta, Alpha, Beta, Gamma, groupName)
    %% This function sorts the shit
    biomarkerOrder = {
        'amplitude_1_4_Hz_Normalized.Channels';
        'amplitude_8_13_Hz_Normalized.Channels';
        'amplitude_13_30_Hz_Normalized.Channels';
        'amplitude_30_45_Hz_Normalized.Channels';
        
        'amplitude_1_4_Hz.Channels';
        'amplitude_4_8_Hz.Channels';
        'amplitude_8_13_Hz.Channels';
        'amplitude_13_30_Hz.Channels';
        'amplitude_30_45_Hz.Channels';
        
        'DFA_delta.MarkerValues';
        'DFA_theta.MarkerValues';
        'DFA_alpha.MarkerValues';
        'DFA_beta.MarkerValues';
        'DFA_gamma.MarkerValues';

        'OscB_delta.CumulativeLifetime';
        'OscB_theta.CumulativeLifetime';
        'OscB_alpha.CumulativeLifetime';
        'OscB_beta.CumulativeLifetime';
        'OscB_gamma.CumulativeLifetime';
        
        'OscB_delta.CumulativeSize';
        'OscB_theta.CumulativeSize';
        'OscB_alpha.CumulativeSize';
        'OscB_beta.CumulativeSize';
        'OscB_gamma.CumulativeSize';
        'NBTe_nbt_DFA';
    };

    nBioms = size(biomarkers,1);
    
    for biomarker = 1 : nBioms
        order(biomarker) = find(ismember(biomarkerOrder,biomarkers(biomarker)));
    end
% 
%     %% Plot unknown biomarkers at the end
%     rest = setdiff([1 : nBioms],order);
%     order = [order rest];
end