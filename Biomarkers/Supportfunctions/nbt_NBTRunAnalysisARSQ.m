
function nbt_NBTRunAnalysisARSQ() 

    %--- init Setup

    SignalInfoName = input('SignalInfo name (e.g. RawSignalInfo) ','s');
    if(isempty(SignalInfoName))
       SignalInfoName = input('SignalInfo name (e.g. RawSignalInfo) ','s');
    end

    % specify folder containing files
    LoadDir = uigetdir('C:\','Select folder with NBT signals');
    if (isempty(LoadDir))
        LoadDir = uigetdir('C:\','Select folder with NBT signals');
    end

    SaveDir = LoadDir;
    if (isempty(SaveDir))
        SaveDir = LoadDir;
    end 
    
    ARSQlanguage = input('Choose your ARSQ language: EN/NL/LT/RU/DE/DK/IT/zh ','s');

    d = dir([LoadDir '/*_info.mat']);

    for j=1:length(d)

        load(d(j).name)

%         nbt_importARSQ(d(j).name(1:end-9), SubjectInfo, pwd, ARSQlanguage)
%         nbt_importARSQ(SignalInfo.subjectInfo(1:end-5), SignalInfo, SaveDir, 'EN')
%         nbt_importARSQ(Planar1SignalInfo.subjectInfo(1:end-5), Planar1SignalInfo, pwd, ARSQlanguage)

        eval([ 'nbt_importARSQ(' SignalInfoName '.subjectInfo(1:end-5),' SignalInfoName ', pwd, ARSQlanguage)' ]) 

    end

end