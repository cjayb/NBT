function nbt_importMFF(startpath)

nbt_fileLooper(startpath,'.mff', 'signal', @innerLoop, 0, 1)

end

function innerLoop(fileName)
pathIdx = strfind(fileName,filesep);
fileName = fileName(pathIdx(end)+1:end);
NBT(import(physioset.import.mff,fileName),1);
end
