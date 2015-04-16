
function nbt_NBTRunAnalysisARSQ(varargin)

script = NBTwrapper();
nbt_NBTcompute(script,'RawSignal',pwd,pwd)
end


function NBTfunction_handle = NBTwrapper()

    function NBTscript(Signal, SignalInfo, SaveDir)
          
          nbt_importARSQ(SignalInfo.subjectInfo, SignalInfo, SaveDir, 'EN')
         
    end

NBTfunction_handle = @NBTscript;
end


function ICASignalInfo=nbt_LoadNewChanloc()
load NewChanloc.mat
end
