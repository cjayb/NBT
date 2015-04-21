function nbt_fileLooper(startpath,fileExt, fileType, funchandle, enterSubDir)
d = dir (startpath);
for j=3:length(d)
    if (d(j).isdir )
        if (enterSubDir)
            nbt_fileLooper([startpath filesep d(j).name ]);
        end
    else
        ext = strfind(d(j).name, fileExt);
        typef = [];
        if(~isempty(fileType))
            if(~strcmp(fileType,'signal'))
                typef  = strfind(d(j).name, fileType);
            else
                typeI = strfind(d(j).name, 'info');
                typeA = strfind(d(j).name, 'analysis');
                if(isempty(typeI) && isempty(typeA))
                    typef = 1;
                end
            end
        else
            typef = 1;
        end
        
        if (~isempty(ext)  && ~isempty(typef) && ~strcmp(d(j).name,'NBTelementBase.mat'))
            funchandle([startpath  filesep d(j).name]);
        end
    end
end
end