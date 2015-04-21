function nbt_checkFiles(startpath)
%Output some info
nbt_fileStat(startpath)

% Check Info files
nbt_fileLooper(startpath,'.mat','info', @innerLoopInfo,0)
% Check Analysis files

% Check Signal files
nbt_fileLooper(startpath,'.mat','signal', @innerLoopSignal,0)

disp('No errors found')
end

function innerLoopInfo(fileName)
load(fileName)
% check SubjectInfo
check(SubjectInfo,fileName)

% check SignalInfo
s = whos;
for i=1:length(s)
    if(~isempty(strfind(s(i).name,'Signal')))
        eval(['check(' s(i).name ', RawSignalInfo, fileName, ''' s(i).name(1:end-4) ''')'])
    end
end
end

function innerLoopSignal(fileName)
disp(fileName)
load(fileName)
load([fileName(1:end-4) '_info.mat'])

%we just checking SHA256 hash
s = whos;
for i=1:length(s)
    if(~isempty(strfind(s(i).name,'SignalInfo')))
        eval(['hasHash = ~isempty(' s(i).name '.signalSHA256);'])
        if(hasHash)
            eval(['yesno = checkHash(' s(i).name ',' s(i).name(1:end-4) ');'])
            if(~yesno)
                error('Signal: SHA256 hash not correct')
            end
        end
    end
end
end