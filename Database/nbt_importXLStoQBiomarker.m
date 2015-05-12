function nbt_importXLStoQBiomarker(startpath,XLSfileName, subjectIDcolumn)

%First we load the xls file
[dummy, dummy, rawXLS] = xlsread(XLSfileName);

%generate SubjectID index
ii = 1;
SubjectIDList = cell(size(rawXLS,1)-1,1);
for i=2:size(rawXLS,1)
    SubjectIDList{ii} = rawXLS{i,subjectIDcolumn};
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
subjectIndex = nbt_searchvector(SubjectIDList,{fileNameID})+1;

%% Insert 'parameters' and values
for m=1:length(QIndex)
    bvalBiomarker.parameter{m,1} = rawXLS{1,QIndex(m)};
    bvalBiomarker.values(m) = rawXLS{subjectIndex,QIndex(m)};
end
bvalBiomarker.qVersion = nbt_getHash(bvalBiomarker.parameter);
bvalBiomarker=nbt_UpdateBiomarkerInfo(bvalBiomarker, [fileNameID '_info']);
save(fileName,'bvalBiomarker','-append');
end
end