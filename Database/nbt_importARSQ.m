function nbt_importARSQ(filename, SignalInfo, SaveDir, ARSQlanguage)
% nbt_importARSQ(filename, SubjectInfo, SaveDir, ARSQlanguage)

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

if ~exist('ARSQlanguage')
    ARSQlanguage = input('Choose your ARSQ language: EN/NL/LT/RU/DE/DK/IT/zh ','s');
end

if ~strcmp(ARSQlanguage,'EN')
    ARSQtemplate = importdata('ARSQ.xlsx');
    firstARSQDataRow = ARSQtemplate.textdata.Sheet1(1,:);

    switch ARSQlanguage
        case 'EN'
            ARSQlanguage = 'English (EN)';
        case 'NL'
            ARSQlanguage = 'Dutch (NL)';
        case 'LT'
            ARSQlanguage = 'Lithuanian (LT)';    
        case 'RU'
            ARSQlanguage = 'Russian (RU)';    
        case 'DE'
            ARSQlanguage = 'German (DE)';    
        case 'DK'
            ARSQlanguage = 'Danish (DK)';
        case 'IT'
            ARSQlanguage = 'Italian (IT)';
        case 'zh'
            ARSQlanguage = 'Chinese (zh)';
    end

    language_index = find(strcmp(firstARSQDataRow,ARSQlanguage));
    
    ARSQfactors.arsqLabels = ARSQtemplate.textdata.Sheet1(2:end-2,language_index);
    
end

ARSQ_subset = setdiff(ARSQfactors.arsqLabels,ARSQ.Questions);
ARSQ_superset = setdiff(ARSQ.Questions,ARSQfactors.arsqLabels);

if ~isempty(ARSQ_subset) % questions missing from the ARSQ template
    disp('Some items from the ARSQ template are missing')
end

sortedAnswers = nan(length(ARSQfactors.arsqLabels),1);
sortedQuestions = cell(length(ARSQfactors.arsqLabels),1);
for i=1:length(ARSQfactors.arsqLabels)
    index_question = find(strcmp(ARSQfactors.arsqLabels{i}, ARSQ.Questions));
    if ~isempty(index_question)&&(length(index_question)==1)
%         disp(['"' ARSQ.Questions{i} '" is not a question from the ARSQ template.'])
%         
%     else
    sortedAnswers(i) = ARSQ.Answers(index_question);
    sortedQuestions{i} = ARSQ.Questions{index_question};
     end
end

% add extra questions at the end
l=length(sortedAnswers);
if ~isempty(ARSQ_superset)
    for i=1:length(ARSQ_superset)
        index_question = find(strcmp(ARSQ_superset{i}, ARSQ.Questions));
        sortedAnswers(l+i) = ARSQ.Answers(index_question);
        sortedQuestions{l+i} = ARSQ.Questions{index_question};        
    end
end

ARSQ.Questions = sortedQuestions;
ARSQ.Answers = sortedAnswers;

ARSQ.qVersion = nbt_getHash(ARSQ.Questions);
ARSQ = nbt_UpdateBiomarkerInfo(ARSQ, SignalInfo);
%eval([BiomarkerName ' = nbt_UpdateBiomarkerInfo(' BiomarkerName ', SignalInfo);']);
nbt_SaveClearObject('ARSQ', SignalInfo, SaveDir)

end