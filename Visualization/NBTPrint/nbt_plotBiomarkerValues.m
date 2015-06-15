function nbt_plotBiomarkerValues()
    electrodeData = get(gco,'UserData');
    electrodeName = electrodeData.electrodeName;
    biomarkerName = strrep(electrodeData.biomarkerName,'_',' ');
    
    biomTitle = [char(biomarkerName) ' for electrode ' char(electrodeName)];
       
    if size(electrodeData.electrodeValues,2) == 1
        % Now: No plot for 1 group.
    else
        electrodeValuesGrp1 = electrodeData.electrodeValues{1};
        electrodeValuesGrp2 = electrodeData.electrodeValues{2};
        nbt_plotBoxplots(electrodeValuesGrp1,electrodeValuesGrp2,biomarkerName,electrodeData.groupName{1},electrodeData.groupName{2},electrodeData.subjectList1,electrodeData.subjectList2,electrodeData.pValues,biomTitle);
    end
end