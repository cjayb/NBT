function nbt_runImportARSQ(startpath)
nbt_fileLooper(startpath,'.mat', 'info', @runimportARSQ, 0)
    function runimportARSQ(fileName)
        load(fileName,'RawSignalInfo')
        nbt_importARSQ(fileName(1:end-9), RawSignalInfo,startpath)
    end
end

