function nbt_stringCheck(string1,string2,errormsg)
if(~strcmp(string1,string2))
   error(errormsg)
end
end