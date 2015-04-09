function fn=nbt_correctSubjectinfoNames(fn)

if(isempty(strfind(fn,'_info')))
   fn = [fn '_info']; 
end
end