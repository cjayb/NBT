function nbt_doCSD(Signal, SignalInfo, SignalPath, SubjectInfo, autosave)
    [CSDSignal, CSDSignalInfo, ~, ~] = nbt_computeSurfaceLaplacian(Signal, SignalInfo, SignalPath, SubjectInfo, autosave, order, m, lambda)
    
    nbt_SaveSignal(CSDSignal, CSDSignalInfo, SignalPath, 1, 'CSDSignal', SubjectInfo);
end