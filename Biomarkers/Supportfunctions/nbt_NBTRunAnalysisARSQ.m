
function nbt_NBTRunAnalysisARSQ(varargin)

script = NBTwrapper();
nbt_NBTcompute(script,'Planar1Signal',pwd,pwd)
end


function NBTfunction_handle = NBTwrapper()

    function NBTscript(Signal, SignalInfo, SaveDir)
          
          nbt_importARSQ(SignalInfo.subjectInfo(1:end-5), SignalInfo, SaveDir, 'DK')
         
    end

NBTfunction_handle = @NBTscript;
end


function ICASignalInfo=nbt_LoadNewChanloc()
load NewChanloc.mat
end
