close(findobj('Tag','EEGLAB'))
if(exist('EEG','var'))
    if(~isempty(EEG.data))
        disp('Converting EEG set to NBT format...')
        [Signal, SignalInfo, SignalPath, SubjectInfo] = nbt_EEGtoNBT(EEG, [], [], []);
    end
end

%clean up from EEGlab
clear ALLCOM ALLEEG CURRENTSET CURRENTSTUDY EEG LASTCOM STUDY

nbt_gui

