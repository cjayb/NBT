%nbt_Study is a collector object of the nbt_Stat and nbt_Group objects.
classdef nbt_Study
   properties
       data
       groups
       statAnalysis
       settings
   end
    
   methods
       function StudyObject = nbt_Study() 
           StudyObject.settings.visual.mcpCorrection = 'bino';
       end
   end
   
   methods (Static = true)
        listOfAvailbleTests = getStatisticsTests(index);       
   end
end