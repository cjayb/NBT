function nbt_doCSD(Signal,SignalInfo,SignalName, SignalInfoName, SignalPath)
    [CSDSignal, CSDSignalInfo] = nbt_CSD(Signal,SignalInfo);
    
    save(fullfile('..',SignalPath,SignalName),'CSDSignal')
    save(fullfile('..',SignalPath,SignalInfoName),'CSDSignalInfo');
    % Does not work: nbt_SaveSignal(CSDSignal, CSDSignalInfo, SignalPath, 1, 'CSDSignal');
end