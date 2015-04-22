function nbt_runImportARSQ(ARSQlanguage, LoadDir, SaveDir)
narginchk(0,3)
%default questions
if(nargin == 0)
    ARSQlanguage = input('Choose your ARSQ language: EN/NL/LT/RU/DE/DK/IT/zh ','s');
    LoadDir = uigetdir('C:\','Select folder with CSV files');
    SaveDir = uigetdir('C:\','Select folder with NBT signals');
end
%loop over csv files
nbt_fileLooper(LoadDir, '.csv','signal',@innerLoop,0);

%nested function
    function innerLoop(fileName)
        nbt_importARSQ(fileName, SaveDir, ARSQlanguage)
    end
end

