
classdef nbt_comparebiomarkers < nbt_Stat
    properties
    end
    
    methods
        
        function obj = calculate(obj, StudyObj)
                                    
            nbt_compareBiomarkersPanel(obj, StudyObj);
            
        end
    end
   
end