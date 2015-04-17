
function nbt_NBTRunAnalysisARSQ2(varargin)

script = NBTwrapper();
nbt_fileLooper(script,'RawSignal',pwd,pwd)
end


function NBTfunction_handle = NBTwrapper()

    function NBTscript(Signal, SignalInfo, SaveDir)
          
          nbt_importARSQ(SignalInfo.subjectInfo(1:end-5), SignalInfo, SaveDir, 'EN')
         
    end

NBTfunction_handle = @NBTscript;
end


function ICASignalInfo=nbt_LoadNewChanloc()
load NewChanloc.mat
end
