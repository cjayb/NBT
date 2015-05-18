function nbt_importXLStoQBiomarker(startpath,XLSfileName, subjectIDcolumn, matchIndex)

%First we load the xls file
[dummy, dummy, rawXLS] = xlsread(XLSfileName);

%generate SubjectID index
ii = 1;
SubjectIDList = cell(size(rawXLS,1)-1,1);
for i=2:size(rawXLS,1)
    SubjectIDList{ii} = cutString(rawXLS{i,subjectIDcolumn},matchIndex);
    ii = ii+1;
end
% Index of columns to add
QIndex = nbt_negSearchVector(1:size(rawXLS,2),subjectIDcolumn);

%loop innerLoop
nbt_fileLooper(startpath,'.mat', 'analysis', @innerLoop, 0, 0)

%% nested function
function innerLoop(fileName)
bvalBiomarker = nbt_bval(size(rawXLS,2)-1);

%% Match subject with xls
fileNameID = nbt_extractFilename(fileName);
fileNameID = cutString(fileNameID,matchIndex);
subjectIndex = nbt_searchvector(SubjectIDList,{fileNameID})+1;
if(isempty(subjectIndex))
    warning([fileNameID ' is missing in the xls file'])
    return
end
    
%% Insert 'parameters' and values
for m=1:length(QIndex)
    bvalBiomarker.parameter{m,1} = rawXLS{1,QIndex(m)};
    valueToInsert = rawXLS{subjectIndex,QIndex(m)};
    if(isnumeric(valueToInsert))
        bvalBiomarker.values(m) = valueToInsert;
    else
        bvalBiomarker.values(m) = nan;
    end
end
bvalBiomarker.qVersion = nbt_getHash(bvalBiomarker.parameter);
bvalBiomarker=nbt_UpdateBiomarkerInfo(bvalBiomarker, [fileNameID '_info']);
save(fileName,'bvalBiomarker','-append');
end
end

function string=cutString(string,index)
StrIdx = strfind(string,'.');
string = string(1:StrIdx(index));
end


