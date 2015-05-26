function Data=nbt_convertToSingle(Data)
if(iscell(Data))
    if ~iscell(Data{1})
        Data = cellfun(@single,Data,'UniformOutput',false);
    else
       for j=1:length(Data)
         Data{j} = cellfun(@single,Data{j},'UniformOutput',false);  
       end
    end
else
    Data = single(Data);
end
end