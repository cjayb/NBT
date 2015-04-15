function nbt_importARSQ(filename, SignalInfo, SaveDir)

ARSQData = importdata([filename '.csv']);

%% Populate the ARSQ biomarker

ARSQ = nbt_ARSQ( size(ARSQData.textdata,2));
%Questions
for i=1:(size(ARSQData.textdata,2))
    IndQ=strfind(ARSQData.textdata{i,1},'"');
    IndDot=strfind(ARSQData.textdata{i,1},'.');
    if ~isempty(IndDot) % get rid of the dot at the end of the statement to make it compatible for sorting the questions later
        ARSQ.Questions{i,1} = ARSQData.textdata{i,1}(IndQ(1)+1:IndQ(2)-2);
    else
    ARSQ.Questions{i,1} = ARSQData.textdata{i,1}(IndQ(1)+1:IndQ(2)-1);
    end
end
%Answers 
for i=1:(size(ARSQData.textdata,2))
   ARSQ.Answers(i) = ARSQData.data(i)+1;
end

% reorder the questions (and answers) for computing the factors
load ARSQfactors
sortedAnswers = nan(length(ARSQ.Answers),1);
sortedQuestions = cell(length(ARSQ.Answers),1);
for i=1:length(ARSQ.Questions)
    index_question = find(strcmp(ARSQfactors.arsqLabels, ARSQ.Questions{i}));
    if isempty(index_question)
        disp(ARSQ.Questions{i})
    else
    sortedAnswers(index_question) = ARSQ.Answers(i);
    sortedQuestions{index_question} = ARSQ.Questions{i};
    end
end

ARSQ.Questions = sortedQuestions;
ARSQ.Answers = sortedAnswers;

ARSQ.qVersion = nbt_getHash(ARSQ.Questions);
ARSQ = nbt_UpdateBiomarkerInfo(ARSQ, SignalInfo);
%eval([BiomarkerName ' = nbt_UpdateBiomarkerInfo(' BiomarkerName ', SignalInfo);']);
nbt_SaveClearObject('ARSQ', SignalInfo, SaveDir)

end