classdef nbt_DiffGroup < nbt_Group
    properties
        groupDifference % [group1 group2] if it is a difference group group1-group2
        groupDifferenceType % subtraction, absolute difference, L2 difference...
    end    
end

