%The method defines new groups. If called with empty input the
%defineGroupGUI is called.
function GrpObj = defineGroup(GrpObj)

if(isempty(GrpObj))
    GrpObj = nbt_Group;
    GUIswitch = 1;
end
%First we load information about the content of the database
[InfoCell, BioCell] = nbt_getSubjectInfo;

if(GUIswitch)
    GrpObj = defineSubjectGroupGUI(GrpObj, InfoCell, BioCell);
end


end