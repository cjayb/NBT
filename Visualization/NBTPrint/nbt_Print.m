    function nbt_Print(NBTstudy,groups)
    %%% Check whether the input is valid
    checkInput();
    
    %% Display the NBT Print visualization window
    %% NBT Print visualization options
    dataType = '';
    VIZ_LAYOUT = '';
    VIZ_SIG = '';
    waitfor(VizQuerry);
    
    %%% Select Signal
    signal = input('For which signal do you want to plot the biomarkers? (Example: Signal, ICASignal, CSDSignal) ','s');
        
    %%% If the user wants to print raw biomarker values, then we get the
    %%% subject number from the command line
    if strcmp(dataType,'raw')
        subjectNumber = input('Specify the number of the subject');
    else
        subjectNumber = [];
    end
    
    %%% Get the number of groups
    nGroups = size(groups,2);
    
    %%% Extract the biomarkers
    if nGroups == 1
        % Check whether the group is a difference group
        if strcmp(NBTstudy.groups{groups(1)}.groupType,'difference')
            % Set the groupType for plotting later on
            groupType = 'difference';
            
            % Compute the difference
            groups = NBTstudy.groups{groups(1)}.groupDifference;
            [Group1, Group2, signalBiomarkers, crossChannelBiomarkers] = extractBiomarkers(NBTstudy,groups);
        else
            % It's a single group
            % Set the groupType for plotting later on
            groupType = 'single';
            
            Group1 = NBTstudy.groups{groups(1)};
            AnalysisObjGrp1 = nbt_generateBiomarkerList(NBTstudy,signal,groups);
            DataObj = getData(Group1,AnalysisObjGrp1);

            % Get the biomarker values from the data object
            [signalBiomarkers, crossChannelBiomarkers] = getBiomarkerValues(DataObj,subjectNumber);
        end
    elseif nGroups == 2
        % Set the groupType for plotting later on
        groupType = 'difference';        
        
        % Check whether the first group is a difference group
        if strcmp(NBTstudy.groups{groups(1)}.groupType,'difference')
            
            groups1 = NBTstudy.groups{groups(1)}.groupDifference;
            
            [Group1, Group2, signalBiomarkersGrp1, crossChannelBiomarkersGrp1] = extractBiomarkers(NBTstudy,groups1);
        else
            Group1 = NBTstudy.groups{groups(1)};
            AnalysisObjGrp1 = nbt_generateBiomarkerList(NBTstudy,signal,groups(1));
            DataObjGrp1 = getData(Group1,AnalysisObjGrp1);
            
            [signalBiomarkersGrp1, crossChannelBiomarkersGrp1] = getBiomarkerValues(DataObjGrp1,subjectNumber);
        end
        
        % Check whether the second group is a difference group
        if strcmp(NBTstudy.groups{groups(2)}.groupType,'difference')
            groups2 = NBTstudy.groups{groups(2)}.groupDifference;
            
            [Group1, Group2, signalBiomarkersGrp2, crossChannelBiomarkersGrp2] = extractBiomarkers(NBTstudy,groups2);
        else
            Group2 = NBTstudy.groups{groups(2)};
            AnalysisObjGrp2 = nbt_generateBiomarkerList(NBTstudy,signal,groups(2));
            DataObjGrp2 = getData(Group2,AnalysisObjGrp2);
            
            [signalBiomarkersGrp2, crossChannelBiomarkersGrp2] = getBiomarkerValues(DataObjGrp2,subjectNumber);
        end
        
        % Extract group2 from group1
        signalBiomarkers = signalBiomarkersGrp1 - signalBiomarkersGrp2;
        crossChannelBiomarkers = crossChannelBiomarkersGrp1 - crossChannelBiomarkersGrp2;
    end
    
    % Get the fixed-order biomarker index and the units from the AnalysisObj
    biomarkerIndex = AnalysisObjGrp1.group{1}.biomarkerIndex;
    units = AnalysisObjGrp1.group{1}.units;

    switch VIZ_LAYOUT
        case 'dflt'
             omega=50;%max amount of defined biomarkers UPDATE from nbt_PrintSort
        case 'cstm'
    end
    switch VIZ_SIG
        case 'all'
            %%% Show all channels
            disp('You chose to show all channels, not running statistics');
            
            %%% No statistics, no significance mask or threshold
            significanceMask = cell(nBioms,nChannels);
            sigThresh = 0;
        case 'sig'
            %%% We only run statistics if the user wants to show
            %%% significant channels
            
            %%% Run statistics?
            disp('You chose to show significant channels only');
            runStats = input('Run statistics (1) or use statistics from NBTstudy object (2)?');

            if runStats == 1
%                 %%% Run the statistics, will be stored in:
%                 %%% NBTstudy.statAnalysis{end}
                statTestList = NBTstudy.getStatisticsTests(0);
                for mm=1:size(statTestList,2)
                    disp([int2str(mm) ':' statTestList{1,mm}])
                end
                statTestIdx = input('Please select test above ');
                S = NBTstudy.getStatisticsTests(statTestIdx);
                                
                S.groups = groups;

%                 disp('Biomarkers')
                bioms_name = AnalysisObjGrp1.group{1}.originalBiomNames;
%                 ll=0;
%                 for mm=1:length(bioms_name)
%                     disp([int2str(mm) ':' bioms_name{1,mm} ])
%                     ll=ll+1;
%                     if(ll ==20)
%                         input('More (press enter)');
%                         ll = 0;
%                     end
%                 end
%                 bioms_ind = input('Please select biomarkers above ');
                %%% Compute the statistics for all biomarkers
                bioms_ind = 1:nBioms;
                
                for gp = 1:length(S.groups)
                    for i = 1:length(bioms_ind)
                        [S.group{gp}.biomarkers{i}, S.group{gp}.biomarkerIdentifiers{i}, S.group{gp}.subBiomarkers{i}, S.group{gp}.classes{i}, S.group{gp}.units{i}] = nbt_parseBiomarkerIdentifiers(bioms_name{bioms_ind(i)});
                    end
                end
                
%                 S.data{1} = DataObjGrp1;
%                 S.data{2} = DataObjGrp2;

                
                %%% As soon as the statistics function can differentiate
                %%% between the different types of biomarkers the code
                %%% below can be uncommented
%                 S.group{1} = AnalysisObjGrp1.group{1};
%                 S.group{2} = AnalysisObjGrp2.group{2};
                

%                 S.group{1}.biomarkers = AnalysisObjGrp1.group{1}.biomarkers;
%                 S.group{1}.biomarkerIdentifiers = AnalysisObjGrp1.group{1}.biomarkerIdentifiers;
%                 S.group{1}.subBiomarkers = AnalysisObjGrp1.group{1}.subBiomarkers;
%                 S.group{1}.units = AnalysisObjGrp1.group{1}.units;
%                 S.group{1}.classes = AnalysisObjGrp1.group{1}.classes;
%                 
%                 S.group{2}.biomarkers = AnalysisObjGrp2.group{1}.biomarkers;
%                 S.group{2}.biomarkerIdentifiers = AnalysisObjGrp2.group{1}.biomarkerIdentifiers;
%                 S.group{2}.subBiomarkers = AnalysisObjGrp2.group{1}.subBiomarkers;
%                 S.group{2}.units = AnalysisObjGrp2.group{1}.units;
%                 S.group{2}.classes = AnalysisObjGrp2.group{1}.classes;

                S = S.calculate(NBTstudy);

                NBTstudy.statAnalysis{length(NBTstudy.statAnalysis)+1} = S;
                
                %%% Get the pValues
                pValues = NBTstudy.statAnalysis{end}.pValues;
                
                %%% Multiple comparisons
                multiComp = input('Correct for multiple comparisons? (no / fdr / bonfi / holm) ','s');
                
                if strcmp(multiComp,'fdr')
                    q = input('Specify the desired false discovery rate: (default = 0.05) ');
                end
                
                for biomID = 1 : nBioms
                    biomID
                    if ismember(biomID,bioms_ind)
                        if find(isnan(pValues{biomID}))
                            significanceMask{biomID} = [];
                        else
                            
                            biomIndex = find(ismember(bioms_ind,biomID));
                            if strcmp(multiComp,'fdr')
                                [significanceMask{biomID}, ~] = nbt_MCcorrect(pValues{biomID},multiComp,q);
                            else
                                [significanceMask{biomID}, ~] = nbt_MCcorrect(pValues{biomID},multiComp);
                            end
                        end
                    end
                end
                
                %%% Change the string for fdr
                if strcmp(multiComp,'fdr')
                    multiComp = ['fdr(', num2str(q), ')'];
                end
                
                %%% Adjust the string for fdr for plotting
%                 if strcomp(multiComp,'fdr')
%                     multiComp = [multiComp '(' 
                
                disp('Statistics done.')
            elseif runStats == 2
%                 %%% Use previously computed statistics
%                 disp('Which statistics object do you want to choose from NBTstudy.statAnalysis?');
%                 selectStats = input('Statistics object: ');
%                 
%                 %%% Get the pValues
%                 pValues = NBTstudy.statAnalysis{selectStats}.pValues;
%                 
%                 %%% Statistics threshold
%                 sigThresh = input('Significance threshold? (0.05)');
% 
%                 %%% Set the significant channels
%                 significanceMask = zeros(nBioms,nChannels);
%                 for biomID = 1 : nBioms
%                     biomIndex = find(ismember(bioms_ind,biomID));
%                     if find(pValues(:,biomIndex)' <= sigThresh)
%                         significanceMask(biomID,:) = pValues(:,biomIndex)' <= sigThresh;
%                     end
%                 end
            end
    end
    
    disp('Specify plot quality:');
    plotQual = input('1: low (fast / analysis), 2: high (slow / print), 3: very high (very slow / final print) ');

    chanChanThreshold = input('Specify chan x chan threshold: ');
        
    %%% Get the channel locations from one of the two groups
    chanLocs = Group1.chanLocs;
    chanLocs = verifyChanLocs(chanLocs);
    
    if nBioms < 25
        perPage = nBioms;
    else
        perPage = 25;
    end
    
    %%% Temp nBioms = 50
    nBioms = 50;
    
    %%% Set maximum number of columns on the topoplot, fixed (5) for
    %%% nbt_Print and other NBT visualization tools
    maxColumns = 5;
    nPages=ceil(nBioms/25);
    fgh=[];
    for page = 1 : 1%nPages
        %% Generates a new figure for each page defined by iotta
        switch dataType
            case {'mean' 'raw'}
                if nGroups > 1 % there are two groups
                    fgh(page)=figure('name',['Mean of  ', char(Group2.groupName), '-', char(Group1.groupName)],'NumberTitle','off');
                else
                    fgh(page)=figure('name',['Mean of  ',char(Group1.groupName)],'NumberTitle','off');
                end
                hold on;
        end      
        
        xSize = 27;
        ySize = 19.;
        xLeft = (30-xSize)/2; yTop = (21-ySize)/2;
        set(gcf,'PaperPosition',[xLeft yTop xSize ySize]);
        set(gcf,'Position',[0 0 xSize*50 ySize*50]);
        set(gcf, 'PaperOrientation', 'landscape');
        
        
        if plotQual == 2
            set(gcf,'Renderer','painters');
            circgrid = 300;
            %% SECTION TITLE
            % DESCRIPTIVE TEXT
            
            gridscale = 100;
        elseif plotQual == 3
            set(gcf,'Renderer','painters');
            circgrid = 1000;
            gridscale = 300;
        else
            circgrid = 100;
            gridscale = 32;           
        end
        
        upperBound = page * perPage;
        if upperBound > nBioms
            upperBound = nBioms;
        end
        
        crossChans = [21:25,36:40,41:45,46:50];
        for i = page * perPage - perPage + 1 : upperBound    
            subax = subaxis(6, maxColumns, 6+mod(i-1,25), 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
            axis off;
            
            if biomarkerIndex(i) ~= 0
                cbType = '';
                if ismember(i,crossChans)
                    biomarkerValues = nanmean(crossChannelBiomarkers(:,:,biomarkerIndex(i)),3);
                else
                    biomarkerValues = signalBiomarkers(biomarkerIndex(i),:);
                end
                
                if strcmp(groupType,'single')
                    Red_cbrewer5colors = load('Red_cbrewer5colors','Red_cbrewer5colors');
                    Red_cbrewer5colors = Red_cbrewer5colors.Red_cbrewer5colors;
                    colormap(Red_cbrewer5colors);

                    cmin = min(biomarkerValues);
                    cmax = max(biomarkerValues);
                elseif strcmp(groupType,'difference')
                    climit = max(abs(biomarkerValues)); %colorbar limit
                    if(length(find(biomarkerValues>=0)) == length(biomarkerValues(~isnan(biomarkerValues))))  % only positive values
                        Red_cbrewer5colors = load('Red_cbrewer5colors','Red_cbrewer5colors');
                        Red_cbrewer5colors = Red_cbrewer5colors.Red_cbrewer5colors;
                        colormap(Red_cbrewer5colors);

                        cmin = 0;
                        cmax = climit;
                    elseif(length(find(biomarkerValues<=0)) == length(biomarkerValues(~isnan(biomarkerValues)))) % only negative values
                        Blue_cbrewer5colors = load('Blue_cbrewer5colors','Blue_cbrewer5colors');
                        Blue_cbrewer5colors = Blue_cbrewer5colors.Blue_cbrewer5colors;
                        colormap(Blue_cbrewer5colors);

                        cmin = -1*climit;
                        cmax = 0;
                    else
                        RedBlue_cbrewer10colors = load('RedBlue_cbrewer10colors','RedBlue_cbrewer10colors');
                        RedBlue_cbrewer10colors = RedBlue_cbrewer10colors.RedBlue_cbrewer10colors;
                        
                        RedBlue_cbrewercolors = [RedBlue_cbrewer10colors(1:3,:); [1 1 1]; RedBlue_cbrewer10colors(8:10,:)];
                                            
                        cmin = -1*climit;
                        cmax = climit;
                        colormap(RedBlue_cbrewercolors);
                        cbType = 'diff';
                    end
                end
                
                
                %%% Plot topoplotConnect for CrossChannelBiomarkers
                if ismember(i,crossChans)
                    topoHandle = nbt_topoplotConnect(NBTstudy,biomarkerValues,chanChanThreshold);
                    nbt_plotColorbar(i, chanChanThreshold, 1, 6, units, maxColumns, 'normal');
                    
                    %%% Set the menu for the topoplot
                    subaxMenu = uicontextmenu;
                    set(topoHandle,'uicontextmenu',subaxMenu);
                    uimenu(subaxMenu,'label','Plot topoplot','callback',{nbt_pvaluesmatrix(S)});
                else
                    %%% Biomarker is not a CrossChannelBiomarker
                    %%% Plot the topoplot for the biomarker
                    topoHandle = nbt_topoplot(biomarkerValues,chanLocs,'headrad','rim','emarker2',{significanceMask{biomarkerIndex(i)},'o','g',4,1},'maplimits',[-3 3],'style','map','numcontour',0,'electrodes','on','circgrid',circgrid,'gridscale',gridscale,'shading','flat');
                    set(gca, 'LooseInset', get(gca,'TightInset'));
                    nbt_plotColorbar(i, cmin, cmax, 6, units, maxColumns, cbType);
                    
                    if exist('S','var')
                        %%% Set the menu for the topoplot
                        subaxMenu = uicontextmenu;
                        set(topoHandle,'uicontextmenu',subaxMenu);
                        uimenu(subaxMenu,'label','Show pValues matrix','callback',{nbt_pvaluesmatrix(S)});
                    else
                        subaxMenu = uicontextmenu;
                        set(topoHandle,'uicontextmenu',subaxMenu);
                        uimenu(subaxMenu,'label','No statistics were computed');
                    end
                end
                
                figure(fgh(end));
           end
            
            %% PLOTTING FREQUENCY BANDS ABOVE THE TOP ROW
            % omega is the # index of the last pre-defined biomarker
            switch VIZ_LAYOUT
                case 'dflt'
                    if mod(i,25)==1 && i <= omega;
                        title ('Delta','FontSize',10,'interpreter','tex','fontweight','demi');
                    elseif mod(i,25)==2 && i<= omega;
                        title ('Theta','FontSize',10,'interpreter','tex','fontweight','demi');
                    elseif mod(i,25)==3 && i<= omega;
                        title ('Alpha','FontSize',10,'interpreter','tex','fontweight','demi');
                    elseif mod(i,25)==4 && i<= omega;
                        title ('Beta','FontSize',10,'interpreter','tex','fontweight','demi');
                    elseif mod(i,25)==5 && i<= omega;
                        title ('Gamma','FontSize',10,'interpreter','tex','fontweight','demi');
                    elseif i>omega
                        title (biom{i},'FontSize',10,'interpreter','tex');
                    end
                case 'cstm'
                    title (biom{i},'FontSize',10,'interpreter','tex')
            end
        end
        
        ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        
        % If it is a difference group:
        if strcmp(groupType,'difference')
             switch dataType
                case 'mean'
                    text(0.5,0.93,['Average difference of ', Group1.groupName ,' minus ', Group2.groupName, ' ({\itn} = ', num2str(nSubjects),'), reference electrode: ',chanLocs(1).ref],'horizontalalignment','center','FontSize',14,'Interpreter','tex');
                case 'raw'
                    text(0.5,0.93,['Raw difference of ', Group1.groupName ,' minus ', Group2.groupName, ' ({\itn} = ', num2str(nSubjects),'), reference electrode: ',chanLocs(1).ref],'horizontalalignment','center','FontSize',14,'Interpreter','tex');
            end

            text(0.5, 0.99,strcat('NBT print for groups ',{' '}, Group1.groupName ,' and ',{' '}, Group2.groupName),'HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',22,'Interpreter','tex');
            try
                text(0.5,0.90,['Multiple comparisons: ', multiComp],'horizontalalignment','center','FontSize',12,'Interpreter','tex');
            catch
            end
        else
            if strcmp(dataType,'mean')
                text(0.5,0.93,['Average of subjects ({\itn} = ', num2str(nSubjects) ,'), reference electrode: ',chanLocs(1).ref],'horizontalalignment','center','FontSize',14,'Interpreter','tex');
            end
            text(0.5, 0.99,strcat('NBT print for group ',{' '},Group1.groupName),'HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',22,'Interpreter','tex');
        end
        
        switch VIZ_LAYOUT
            case 'dflt'
                if page==1
                    get(gcf,'CurrentAxes');
                    ABSAMP = text(0.02,9/12, 'Absolute Power','horizontalalignment', 'center', 'fontweight','demi');
                    set(ABSAMP,'rotation',90);
                    get(gcf,'CurrentAxes');
                    RELAMP= text(0.02,7/12, 'Relative Power','horizontalalignment', 'center', 'fontweight','demi');
                    set(RELAMP,'rotation',90);
                    get(gcf,'CurrentAxes');
                    DFA= text(0.02,5/12, 'Central Frequency','horizontalalignment', 'center', 'fontweight','demi');
                    set(DFA,'rotation',90);
                    get(gcf,'CurrentAxes');
                    CENTRAL= text(0.02,3/12, 'DFA','horizontalalignment', 'center', 'fontweight','demi');
                    set(CENTRAL,'rotation',90);
                    get(gcf,'CurrentAxes');
                    LIFETIME= text(0.02,1/12, 'Phase Lag Index','horizontalalignment', 'center', 'fontweight','demi');
                    set(LIFETIME,'rotation',90);
                elseif page==2;
                    get(gcf,'CurrentAxes');
                    ABSAMP = text(0.02,9/12, 'Bandwidth','horizontalalignment', 'center', 'fontweight','demi');
                    set(ABSAMP,'rotation',90);
                    get(gcf,'CurrentAxes');
                    RELAMP= text(0.02,7/12, 'Spectral edge','horizontalalignment', 'center', 'fontweight','demi');
                    set(RELAMP,'rotation',90);
                    get(gcf,'CurrentAxes');
                    DFA= text(0.02,5/12, 'Amplitude Correlations','horizontalalignment', 'center', 'fontweight','demi');
                    set(DFA,'rotation',90);
                    get(gcf,'CurrentAxes');
                    CENTRAL= text(0.02,3/12, 'Coherence','horizontalalignment', 'center', 'fontweight','demi');
                    set(CENTRAL,'rotation',90);
                    get(gcf,'CurrentAxes');
                    LIFETIME= text(0.02,1/12, 'Phase Locking Value','horizontalalignment', 'center', 'fontweight','demi');
                    set(LIFETIME,'rotation',90);
                end
            case 'cstm'
        end
        
        
        %%% Store the biomarkerValues in the NBTstudy object
    end

% Nested functions part
    function checkInput()
        if ~isa(NBTstudy,'nbt_Study')
            error('No valid NBTstudy object was detected');
        end

        if ~isnumeric(groups)
            error('No valid group number(s) was/were detected');
        else
            % Get the number of groups
            nGroups = size(groups,2);
            if nGroups < 1
                error('Number of groups is smaller than 1');
            elseif nGroups > 2
                error('NBT Print can not handle more than two groups');
            end
        end
    end

    function chanLocs = verifyChanLocs(chanLocs)
        if isempty(chanLocs(1).ref)
            disp('No reference electrode is specified, assuming average');
            for channel = 1 : size(chanLocs,2)
                chanLocs(channel).ref = 'average';
            end
        end
    end

    function [Group1, Group2, signalBiomarkers, crossChannelBiomarkers] = extractBiomarkers(NBTstudy,groups)
        %%% Get groups NBTstudy
        Group1 = NBTstudy.groups{groups(1)};
        Group2 = NBTstudy.groups{groups(2)};

        %%% Generate fixed biomarker list
        AnalysisObjGrp1 = nbt_generateBiomarkerList(NBTstudy,signal,groups(1));
        AnalysisObjGrp2 = nbt_generateBiomarkerList(NBTstudy,signal,groups(2));

        %%% Get the data
        DataObjGrp1 = getData(Group1,AnalysisObjGrp1);
        DataObjGrp2 = getData(Group2,AnalysisObjGrp2);

        [signalBiomsGrp1, crossChannelBiomsGrp1] = getBiomarkerValues(DataObjGrp1,subjectNumber);
        [signalBiomsGrp2, crossChannelBiomsGrp2] = getBiomarkerValues(DataObjGrp2,subjectNumber);

        signalBiomarkers = signalBiomsGrp1 - signalBiomsGrp2;
        crossChannelBiomarkers = crossChannelBiomsGrp1 - crossChannelBiomsGrp2;
    end
    
    function [signalBiomarkers, crossChannelBiomarkers] = getBiomarkerValues(DataObj, subjectNumber)
        % Get information from DataObj
        nChannels = 129;
        nSubjects = size(DataObj{1,1},2);
        nBioms = DataObj.numBiomarkers;

        % Initialize matrices for signalBiomarkers and
        % crossChannelBiomarkers
        signalBiomarkers = zeros(nBioms,nChannels);
        crossChannelBiomarkers = zeros(nChannels,nChannels,nBioms);
        for biomID = 1 : nBioms
            biomDataGroup1 = DataObj.dataStore{biomID};
            switch dataType
                case 'raw'
                    if size(biomDataGroup1{1},2) == nChannels
                        %% chan * chan biomarker
                        crossChannelBiomarkers(:,:,biomID) = biomDataGroup1{subjectNumber};
                    else
                        %% Get raw biomarker data, compute means and store them
                        signalBiomarkers(biomID,:) = DataObj{biomID,1};
                    end
                case 'mean'
                    if size(biomDataGroup1{1},2) == nChannels
                        chanValues = zeros(nChannels,nChannels);
                        for subject = 1 : size(biomDataGroup1,1)
                            chanValues = chanValues + biomDataGroup1{subject};
                        end
                        crossChannelBiomarkers(:,:,biomID) = chanValues / size(biomDataGroup1,1);
                    else
                        %% Get raw biomarker data, compute means and store them
                        chanValuesGroup1 = DataObj{biomID,1};
                        meanGroup1 = nanmean(chanValuesGroup1',1);
                        
                        signalBiomarkers(biomID,:) = meanGroup1;
                    end
            end
        end
    end
end