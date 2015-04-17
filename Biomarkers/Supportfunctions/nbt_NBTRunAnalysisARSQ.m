
function nbt_NBTRunAnalysisARSQ(startpath) 

    d = dir([startpath '/*_info.mat']);
    
    ARSQlanguage = input('Choose your ARSQ language: EN/NL/LT/RU/DE/DK/IT/zh ','s');

    for j=1:length(d)

        load(d(j).name)

%         nbt_importARSQ(d(j).name(1:end-9), SubjectInfo, pwd, ARSQlanguage)
%         nbt_importARSQ(SignalInfo.subjectInfo(1:end-5), SignalInfo, SaveDir, 'EN')
        nbt_importARSQ(Planar1SignalInfo.subjectInfo(1:end-5), Planar1SignalInfo, pwd, ARSQlanguage)

    end

end