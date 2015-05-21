function Data=nbt_convertToSingle(Data)
if(iscell(Data))
    Data = cellfun(@single,Data,'UniformOutput',false);
else
    Data = single(Data);
end
end