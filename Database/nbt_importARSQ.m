function nbt_importARSQ(filename, SignalInfo, SaveDir)

ARSQData = importdata([filename '.csv']);

%% Populate the ARSQ biomarker

ARSQ = nbt_ARSQ( size(ARSQData.textdata,2));
%Questions
for i=1:(size(ARSQData.textdata,2))
    IndQ=strfind(ARSQData.textdata{i,1},'"');
    ARSQ.Questions{i,1} = ARSQData.textdata{i,1}(IndQ(1)+1:IndQ(2)-1);
end
%Answers 
for i=1:(size(ARSQData.textdata,2))
   ARSQ.Answers(i) = ARSQData.data(i)+1;
end


ARSQ.qVersion = nbt_getHash(ARSQ.Questions);
eval([BiomarkerName ' = nbt_UpdateBiomarkerInfo(' BiomarkerName ', SignalInfo);']);
nbt_SaveClearObject('ARSQ', SignalInfo, SaveDir)
end