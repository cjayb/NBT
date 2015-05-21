function fileName=nbt_extractFilename(filePathName,removeUnderscore)
narginchk(1,2)
if(~exist('removeUnderscore','var'))
    removeUnderscore = 1;
end
idx = strfind(filePathName,filesep);
fileName = filePathName(idx(end)+1:end);

if(removeUnderscore)
   idx = strfind(fileName,'_');
   fileName = fileName(1:idx(end)-1);
end


end