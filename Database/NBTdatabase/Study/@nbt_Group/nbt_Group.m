classdef nbt_Group %NBT GroupObject - contains group definitions + Database pointers.
    properties
        grpNumber
        databaseType %e.g. NBTelement, File
        databaseLocation %path to files 
        groupName
        fileList
        parameters %for additional search parameters.
        biomarkerList
        identList
        chanLocs
        ref
        listRegData
        DataObj
    end
    
    methods (Access = public)
        function GrpObj = nbt_Group %object contructor
            GrpObj.databaseType = 'NBTelement'; % 'NBTelement' or 'File'
            GrpObj.biomarkerList = [];
        end
                
        nbt_DataObject = getData(nbt_GroupObject, StatObj) %Returns a nbt_Data Object based on the GroupObject and additional parameters
        
       [InfoCell, BioCell, IdentCell,nbt_GroupObject, FileInfo]  = getSubjectInfo(nbt_GroupObject) %Returns a cell with information about the database.
       nbt_GroupObject = generateFileList(nbt_GroupObject, FileInfo);
       [FileInfo, nbt_GroupObject] = getFileInfo(nbt_GroupObject);
       nbt_GroupObject = defineSubjectGroupGUI(nbt_GroupObject, InfoCell, BioCell, IdentCell);
    end 
    
    methods (Static = true)
        nbt_GroupObject = defineGroup(GrpObj) %Returns a group object based on selections (e.g., from the GUI) 
    end
    
    
end

