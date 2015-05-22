function nbt_injectSubjectInfo(startpath)
nbt_fileLooper(startpath, 'mat' , 'info', @innerfunc, 0)
end

function innerfunc(fileName)
load(fileName, 'SubjectInfo')
if(~exist('SubjectInfo','var'))
   SubjectInfo = nbt_SubjectInfo; 
end
fidx = strfind(fileName,filesep);
[projectID,leftover] = strtok(fileName(fidx(end)+1:end),'.');
[subjectID,leftover] = strtok(leftover,'.');
subjectID = str2double(subjectID(2:end));
[dateRecord,leftover] = strtok(leftover,'.');
SubjectInfo.info.dateOfRecording = dateRecord;
[conditionID] = strtok(leftover,'.');
conditionID = strtok(conditionID,'_');
SubjectInfo.projectInfo = [ projectID '.mat'];
SubjectInfo.subjectID =  subjectID;
SubjectInfo.conditionID =  conditionID;
SubjectInfo.lastUpdate = datestr(now);
SubjectInfo.fileName =  fileName(fidx(end):end);
save(fileName,'SubjectInfo','-append');
end
