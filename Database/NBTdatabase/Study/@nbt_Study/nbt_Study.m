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
           StudyObject.settings.visual.plotQuality = 2;
       end
   end
   
   methods (Static = true)
        listOfAvailbleTests = getStatisticsTests(index);       
   end
end