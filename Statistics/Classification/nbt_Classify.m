function [ClassificationStatObj]=nbt_Classify(ClassificationStatObj, StudyObj)
%Get data
n_groups = length(ClassificationStatObj.groups);
DataMatrix = []; % n_sub x (n_freq_bands*n_channels)
Outcome = [];

% if (ClassificationStatObj.channelsRegionsSwitch == 2) % regions
% n_chans = size(StudyObj.groups{1}.chanLocs,2);
% n_bioms = size(DataMatrix,2)/n_chans;
% load default_regions19
% NewDataMat = [];
% 
% for i=1:n_bioms
%     DataMat = DataMatrix(:,(i-1)*n_chans+1:n_chans*i);
%     for j=1:length(reg)
%         NewDataMat = [NewDataMat nanmean(DataMat(:,reg(j).reg.channel_nr),2)];    
%     end
% end
% 
% end

for j=1:n_groups
    Data_groups{j} = StudyObj.groups{ClassificationStatObj.groups(j)}.getData(ClassificationStatObj);
    %if (Data_groups{j}.numSubjects == size(Data_groups{j}(),1)) % global biomarker
        DataMatrix = [DataMatrix; Data_groups{j}()];
%     else % biomarker per frequency band, Data_groups{j}() of size (n_subjects*n_freq_bands) x n_channels
%         n_freq_bands = size(Data_groups{j}(),1)/Data_groups{j}.numSubjects;
%         DataMat = Data_groups{j}();
%         for k=1:Data_groups{j}.numSubjects
%             sub_k = DataMat(n_freq_bands*(k-1)+1:n_freq_bands*k,:);
%             sub_k_row = reshape(sub_k',1,size(sub_k,1)*size(sub_k,2));
%             DataMatrix = [DataMatrix; sub_k_row];
%         end
%     end
    Outcome = [Outcome; (j-1).*ones(length(Data_groups{j}.subjectList{1,1}),1)];
end

% clear DataMatrix
% clear Outcome
% load DataMatrixCorr
% load Outcome

%following should be removed in later versions and be set before the call
%of nbt_Classify
if isempty(ClassificationStatObj.nCrossVals) 
    ClassificationStatObj.nCrossVals = 100; 
end
NCrossVals = ClassificationStatObj.nCrossVals;
% temp=Data_groups{1};
if (ClassificationStatObj.channelsRegionsSwitch == 2) % regions
    ClassificationStatObj.regions = 1:size(Data_groups{1}{1,1},1);
else
    ClassificationStatObj.channels = 1:size(Data_groups{1}{1,1},1);
end
warning('Now just using all channels - .channels should be set properly')
% ClassificationStatObj.classificationType = 'crossValidate';
% Type = 'crossValidate';

ClassificationStatObj.classificationType = 'validate';
Type = 'validate';

ClassificationStatObj.uniqueBiomarkers = size(Data_groups{1}.biomarkers,2);

if ~isempty(ClassificationStatObj.dimensionReduction)

    switch ClassificationStatObj.dimensionReduction
        case 'PCA'
            
            [pc,score,latent] = princomp(DataMatrix);
            tmp=cumsum(latent);
            nr = find(tmp/tmp(end)>0.95,1);
            DataMatrix = score(:,1:nr);
            
            ClassificationStatObj.removeFeaturesType = [];
            
        case 'PLS'
            
%             n_comps = floor(size(DataMatrix,2)/2);
%             %n_comps = 10;
%             [XL,yl,XS,YS,beta,PCTVAR] = plsregress(DataMatrix,Outcome,n_comps);
%             plot(1:n_comps,cumsum(100*PCTVAR(2,:)),'-bo');
%             tmp=cumsum(PCTVAR(2,:)); % PCTVAR - 1st row: % variance explained in X, 2nd row Y (labels)
%             nr = find(tmp/tmp(end)>0.90,1);
%             [XL,yl,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(DataMatrix,Outcome,nr);
%             yfit = [ones(size(DataMatrix,1),1) DataMatrix]*beta;
%             DataMatrix = XS;
%             plot(Outcome,yfit,'o')
%             TSS = sum((Outcome-mean(Outcome)).^2);
%             RSS = sum((Outcome-yfit).^2);
%             Rsquared = 1 - RSS/TSS
            
            ClassificationStatObj.removeFeaturesType{1,2} = 'PLS';
            
        case 'ICA'
            % DataMatrix = fastica(DataMatrix'); % from FastICA package
              DataMatrix(find(isnan(DataMatrix)))=0;
              [E, D] = pcamat(DataMatrix);
              [whitesig, whiteningMatrix, dewhiteningMatrix] = whitenv(DataMatrix, E, D);
              [A, W] = fpica(whitesig, whiteningMatrix, dewhiteningMatrix); % A mixing matrix, W inverse
              %[icasig, A2, W2] = fastica(DataMatrix);
              %[icasig] = fastica(W);
%             pop_runica(DataMatrix, 'icatype','jader')
%             edit nbt_AutoRejectICA.m
%             edit nbt_filterbeforeICA.m
        
        case 'LDA'
              linclass = fitcdiscr(DataMatrix,Outcome,'CrossVal','on');
              % linclass = fitcdiscr(DataMatrix(1:52,:),Outcome,'CrossVal','on');
              % klase = predict(linclass,DataMatrix(1,:));

    end
    
end
    
% n_group1=size(BCell{1},2); % no of subjects in the first group
% n_group2=size(BCell{2},2); % no of subjects in the second group

% Outcome = [zeros(1,n_group1) ones(1,n_group2)]'; % n x 1

%% Set up parameters && remove NaN biomarkers
% It's possible to treat the NaN's in another way; interpolate them with EM
% algorithms, set them to 0, etc. Now, we remove ...
% the entire biomarker if it contains any missing data.
%[~,Y]=find(isnan(DataMatrix)==1);
%Y=unique(Y);
%DataMatrix=DataMatrix(:,setdiff(1:size(DataMatrix,2),Y));
%DataMatrix(1:92,:) = DataMatrix(1:92,:)-DataMatrix(93:end,:);
%DataMatrix(93:end,:) = -1.*DataMatrix(1:92,:);
%DataMatrix = sign(DataMatrix).*log10(abs(DataMatrix));


% [c, Sample, l] = princomp(DataMatrix);
% tmp=cumsum(l);
% nr = find(tmp/tmp(end)>0.999,1)
% DataMatrix = Sample(:,1:nr);
% ChannelsToUse =[];

ClassificationStatObj.realOutcome = Outcome;

%save DataMatrix DataMatrix %sorry Sonja :(
%save Outcome Outcome  %also not saving s further down


Bioms=NaN(size(DataMatrix,2),NCrossVals);
ClassificationStatObj.modelVars=cell(NCrossVals,1);
%% Divide into Train and test set
switch lower(Type)
    case 'crossvalidate'
        % Type CrossValidate
        tic
        disp('Cross validation needs work')
        %   DataMatrix = abs(DataMatrix);
        DataMatrix = nanzscore(DataMatrix);
                
        modelVars = cell(1, NCrossVals);
        if(ClassificationStatObj.statOptions.UseParallel)
            parfor i=1:NCrossVals
                disp(i)
                [FP(i), TP(i), FN(i), TN(i), SE(i), SP(i), PP(i), NN(i), LP(i), LN(i), MM(i), AUC(i), H(i), ACC(i), modelVars{1,i}] = runClassification(DataMatrix,Outcome,ClassificationStatObj);
            end
        else
            for i=1:NCrossVals % also potential parametere!
                disp(i)
                tic
                [FP(i), TP(i), FN(i), TN(i), SE(i), SP(i), PP(i), NN(i), LP(i), LN(i), MM(i), AUC(i), H(i), ACC(i), modelVars{1,i}] = runClassification(DataMatrix,Outcome,ClassificationStatObj);
                toc
            end
        end
        disp('CrossValidate:done')
        toc
    case 'validate'
        tic
        % Type Validate
        TestLimit = floor(size(DataMatrix,1)*1/3); %a potential parameter!
        [ TrainMatrix,  TestMatrix, TrainOutcome, TestOutcome] = ...
            nbt_RandomSubsampler( DataMatrix,Outcome,TestLimit,'stratified');
        %We use a stratified sample to preserve the class balance.
        %% Feature selction - we first prune the biomarkers given to the classsification algorithm
        % [TrainMatrix, BiomsToUse] = nbt_RemoveFeatures( TrainMatrix,TrainOutcome,'ttest2',ChannelsToUse, size(BCell{1},3));       
        
        % call nbt_TrainClassifier
        [ClassificationStatObj] = nbt_TrainClassifier(TrainMatrix,TrainOutcome, ClassificationStatObj);
        
        if(size(BiomsToUse,2) ==1 && size(BCell{1},3) ~= 1)
            TestMatrix = TestMatrix(:,BiomsToUse{1,1});
        else
            NewTestMatrix = nan(size(TestMatrix,1),size(BCell{1},3));
            for ii=1:size(BCell{1},3)
                NewTestMatrix(:,ii) = nanmedian(TestMatrix(:,BiomsToUse{1,ii}),2);
            end
            TestMatrix = NewTestMatrix;
            clear NewTestMatrix;
        end
        % call nbt_TestClassifier
        [pp, ClassificationStatObj] = nbt_UseClassifier(TestMatrix, ClassificationStatObj);
        %eval outcome
        [FP, TP, FN, TN, SE, SP, PP, NN, LP, LN, MM, ACC, AUC, H_measure] = nbt_evalOutcome(pp, TestOutcome);
        toc
    case 'train'
        % Type Train
        ClassificationStatObj = nbt_TrainClassifier(DataMatrix, Outcome, ClassificationStatObj);
    case 'use'
        % Type Use
        [pp, ClassificationStatObj] = nbt_UseClassifier(DataMatrix, ClassificationStatObj);
        %eval outcome
        [FP, TP, FN, TN, SE, SP, PP, NN, LP, LN, MM, ACC] = nbt_evalOutcome(pp, TestOutcome);
    otherwise
        error('The specified Type is not known - Please use either CrossValidate, Validate, Train, or Use')
end

%update s
ClassificationStatObj.outcomeEval.FalsePositive =  FP;
ClassificationStatObj.outcomeEval.TruePositive =  TP;
ClassificationStatObj.outcomeEval.FalseNegative =  FN;
ClassificationStatObj.outcomeEval.TrueNegative =  TN;
ClassificationStatObj.outcomeEval.Sensitivity =  SE;
ClassificationStatObj.outcomeEval.Specificity =  SP;
ClassificationStatObj.outcomeEval.Accuracy =  ACC;
ClassificationStatObj.outcomeEval.PositivePredictiveValue  =  PP;
ClassificationStatObj.outcomeEval.NegativePredictiveValue =  NN;
ClassificationStatObj.outcomeEval.LikelihoodRatioPos =  LP;
ClassificationStatObj.outcomeEval.LikelihoodRatioNeg  =  LN;
ClassificationStatObj.outcomeEval.MatthewCorr =  MM;
ClassificationStatObj.outcomeEval.AUC = AUC;
ClassificationStatObj.modelVarsStore = modelVars;

figure('Name','Classification performance')
subplot(2,2,1)
boxplot(ACC)
set(gca,'YLim',[0.5 1])
title('Accuracy')

subplot(2,2,2)
boxplot(SE)
set(gca,'YLim',[0.5 1])
title('Sensitivity (SE)')

subplot(2,2,3)
boxplot(SP)
set(gca,'YLim',[0.5 1])
title('Specificity (SP)')

subplot(2,2,4)
boxplot(PP)
set(gca,'YLim',[0.5 1])
title('Precision (PP)')

%save s s

%                 s.BaselineSE=BaselineSE;
%                 s.BaselineSP=BaselineSP;
%                 s.BaselineAUC=BaselineAUC;
%                 s.ESE=ESE;
%                 s.ESP=ESP;
%                 s.EAUC=EAUC;
%                 s.HAE=HAE;
%                 s.HE=HE;


end

function  [FP, TP, FN, TN, SE, SP, PP, NN, LP, LN, MM, AUC, H, ACC, modelVars] = runClassification(DataMatrix,Outcome,ClassificationStatObj)
[ TrainMatrix,  TestMatrix, TrainOutcome, TestOutcome] = nbt_RandomSubsampler(DataMatrix, Outcome,ClassificationStatObj.subSampleType,ClassificationStatObj.subSampleLimit,ClassificationStatObj.subSampleStratification);
if (ClassificationStatObj.channelsRegionsSwitch == 1) % using channels, not regions
    [TrainMatrix, BiomsToUse] = nbt_RemoveFeatures(TrainMatrix, TrainOutcome,ClassificationStatObj.removeFeaturesType{1,1}, ClassificationStatObj.channels, ClassificationStatObj.uniqueBiomarkers);

    NewTestMatrix = nan(size(TestMatrix,1),size(TrainMatrix,2));
    for ii=1:size(TrainMatrix,2)
        NewTestMatrix(:,ii) = nanmedian(TestMatrix(:,BiomsToUse{1,ii}),2);
    end
    TestMatrix = NewTestMatrix;
    clear NewTestMatrix;
end

%clear NaNs
if(sum(sum(isnan(TrainMatrix))))
    idxNotNaN = find(0==sum(isnan(TrainMatrix)));
    TrainMatrix = TrainMatrix(:,idxNotNaN);
    TestMatrix = TestMatrix(:,idxNotNaN);
end
if(sum(sum(isnan(TestMatrix))))
    idxNotNaN = find(0==sum(isnan(TestMatrix)));
    TrainMatrix = TrainMatrix(:,idxNotNaN);
    TestMatrix = TestMatrix(:,idxNotNaN);
end


if(~isempty(ClassificationStatObj.removeFeaturesType{1,2}))
    [TrainMatrix, BiomsToUse] = nbt_RemoveFeatures(TrainMatrix, TrainOutcome,ClassificationStatObj.removeFeaturesType{1,2}, ClassificationStatObj.channels, ClassificationStatObj.uniqueBiomarkers);
    
    NewTestMatrix = nan(size(TestMatrix,1),size(TrainMatrix,2));
    for ii=1:size(TrainMatrix,2)
        NewTestMatrix(:,ii) = nanmedian(TestMatrix(:,BiomsToUse{1,ii}),2);
    end
    TestMatrix = NewTestMatrix;
    clear NewTestMatrix;
end



%end
if(ClassificationStatObj.balanceClasses)
    [TrainMatrix, TrainOutcome] = nbt_balanceClasses(TrainMatrix, TrainOutcome,0);
end

[ClassificationStatObj] = nbt_TrainClassifier(TrainMatrix,TrainOutcome, ClassificationStatObj);
[pp, ClassificationStatObj ] = nbt_UseClassifier(TestMatrix, ClassificationStatObj);
[FP, TP, FN, TN, SE, SP, PP, NN, LP, LN, MM, ACC, AUC, H] = nbt_evalOutcome(pp, TestOutcome);
modelVars = ClassificationStatObj.modelVars;
end
