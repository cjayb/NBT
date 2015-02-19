function nbt_SaveSignal(Signal, SignalInfo, directoryname,auto,SignalName)
narginchk(2, 5)
if(~exist('auto','var'))
    auto = 0;
end
if(auto == 0)
    AskA = input('Do you want to save this Signal? ([Y]es/[N]o)','s');
    if(strcmpi(AskA,'y'))
        auto = 1;
    end
end
if(auto ==1)
    
    %--- make NBTSignal files
    if(~exist('SignalName','var'))
        name = input('Name of NBT Signal? (should contain the word Signal) ','s'); % e.g. RawSignal, CleanSignal
    else
        name = SignalName;
    end
    SignalInfo.signalName = name;
    SignalInfo.signalSHA256 = nbt_getHash(Signal);
    eval(['[',name,'Info]=SignalInfo;']);
    fn=SignalInfo.subjectInfo;

    if(isempty(directoryname))
        disp('select directory to save NBT file')
        directoryname = uigetdir('select directory to save NBT file');
    end
    d = dir(directoryname);
    
    present=0;
    for i=1:length(d)
        if strcmp(d(i).name,[fn,'_info.mat'])
            present=1;
        end
    end
    disp('saving...')
    if present
        try
            save([directoryname filesep fn '_info.mat'],[name 'Info'],'-append')
        catch
            save([directoryname filesep fn '_info.mat'],[name 'Info'])
        end
        
        if(~isempty(Signal))
            eval(['[',name,']=Signal;']);
            
            try
                save([directoryname filesep fn '.mat'],name,'-append')
            catch
                save([directoryname filesep fn '.mat'],name)
            end
        end
    else
        OptionSave = input(['A file named' fn '_info.mat does not exist in this directory. Do you want create a new file? [[Y]es [N]o]'],'s'); % e.g. RawSignal, CleanSigna
        if strcmp(OptionSave(1),'Y') || strcmp(OptionSave(1),'y')
            save([directoryname filesep fn '_info.mat'],[name 'Info'])
            save([directoryname filesep fn '.mat'],name)
        end
    end
    
    disp('NBT signal saved')
end
end