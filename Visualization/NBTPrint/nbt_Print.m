    function nbt_Print(statTest,groups,selectedBiomarkers)
    global NBTstudy
    courseMode = 'on';
    
    %%% Check whether the input is valid
    checkInput();
 
    %% Display the NBT Print visualization window
    %% NBT Print visualization options
    dataType = '';
    VIZ_LAYOUT = '';
    VIZ_SIG = '';
    waitfor(VizQuerry);
    
    %%% Select Signal
    % SH FIX ME - No signal selection for course, reduces amount of errors
    % in the practical room
    if strcmp(courseMode,'off')
        signal = input('For which signal do you want to plot the biomarkers? (Example: Signal, ICASignal, CSDSignal) ','s');
    else
        signal = 'TransSignal';
    end
    
    %%% If the user wants to print raw biomarker values, then we get the
    %%% subject number from the command line
    if strcmp(dataType,'raw')
        subjectNumber = input('Specify the number of the subject');
    else
        subjectNumber = [];
    end
        
    % Get the number of groups
    nGroups = size(groups,2);

    % Check the groupType and whether the number of groups is correct
    if nGroups == 1
        GroupObject = NBTstudy.groups{groups};

        if isa(GroupObject,'nbt_DiffGroup')
            groupType = 'difference';
        else
            groupType = 'single';
        end
    elseif nGroups == 2
        GroupObj1 = NBTstudy.groups{groups(1)};
        GroupObj2 = NBTstudy.groups{groups(2)};

        if isa(GroupObj1, 'nbt_DiffGroup') & isa(GroupObj2, 'nbt_DiffGroup')
            groupType = 'diffDifference';
        elseif ~isa(GroupObj1, 'nbt_DiffGroup') & ~isa(GroupObj2, 'nbt_DiffGroup')
            groupType = 'difference';
        else
            error('One of the two groups is a difference group, but the other is not.');
        end
    else
        error('NBT Print can only handle one or two groups.');
    end

    % Define the AnalysisObject and GroupObjects
    AnalysisObject = nbt_Analysis;
    AnalysisObject.groups = [];

    GroupObjects = cell(1,nGroups);

    % Iterate along the group(s) and store the GroupObject and store the
    % biomarkers in the AnalysisObject
    disp('Loading data...');
    for groupIdx = 1 : nGroups
        CurrentGroup = NBTstudy.groups{groups(groupIdx)};
        GroupObjects{groupIdx} = CurrentGroup;

        if isa(CurrentGroup, 'nbt_DiffGroup')
            AnalysisObject.groups = CurrentGroup.groupDifference;
            for subGroupIdx = 1 : 2
                SubGroup = NBTstudy.groups{CurrentGroup.groupDifference(subGroupIdx)};
                AnalysisObject = nbt_generateBiomarkerList(AnalysisObject,SubGroup,signal,subGroupIdx,selectedBiomarkers,courseMode);
            end
        else
            AnalysisObject = nbt_generateBiomarkerList(AnalysisObject,CurrentGroup,signal,groupIdx,selectedBiomarkers,courseMode);
            AnalysisObject.groups = [AnalysisObject.groups groups(groupIdx)];
        end
        DataObjects{groupIdx} = getData(CurrentGroup, AnalysisObject);
    end
    disp('Data is loaded into NBT Print.');
    
    % Get the number of channels
    tempBiom = DataObjects{1}.dataStore{1};
    nChannels = size(tempBiom{1},1);
    %nChannels = length(GroupObjects{1}.chanLocs);
    
    % Get the biomarker values out of the DataObjects
    signalBiomarkers = getBiomarkerValues(DataObjects,[]);
    
    % Get the number of biomarkers
    nBioms = length(signalBiomarkers);
    
    % Get the indices of the bad channels
    for biomIdx = 1 : nBioms
        badChannels{biomIdx} = find(isnan(signalBiomarkers{biomIdx}));
    end
    
    % Get the fixed-order biomarker index and the units from the AnalysisObj
    biomarkerIndex = AnalysisObject.group{1}.biomarkerIndex;
    units = AnalysisObject.group{1}.units;
    
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
            pValues = cell(nBioms,nChannels);
            
            for biomID = 1 : nBioms
                if size(signalBiomarkers{biomID},1) == nChannels
                    significanceMask{biomID} = 1:nChannels*nChannels;
                else
                    significanceMask{biomID} = [];
                    pValues{biomID} = [];
                end
            end
        case 'sig'
            %%% We only run statistics if the user wants to show
            %%% significant channels
            
            if strcmp(groupType, 'single')
                disp('You selected one group, but chose to run statistics. Statistics test can not be performed.');
                %%% No statistics, no significance mask or threshold
                significanceMask = cell(nBioms,nChannels);
                pValues = cell(nBioms,nChannels);

                for biomID = 1 : nBioms
                    if size(signalBiomarkers{biomID},1) == nChannels
                        significanceMask{biomID} = 1:nChannels*nChannels;
                    else
                        significanceMask{biomID} = [];
                        pValues{biomID} = [];
                    end
                end
            else
                disp('Running statistics');
                %%% Run the statistics, will be stored in:
                %%% NBTstudy.statAnalysis{end}
%                 statTestList = NBTstudy.getStatisticsTests(0);
%                 for mm=1:size(statTestList,2)
%                     disp([int2str(mm) ':' statTestList{1,mm}])
%                 end
%                 statTestIdx = input('Please select test above ');
                S = NBTstudy.getStatisticsTests(statTest);

                S.groups = groups;

                S.data{1} = DataObjects{1};
                S.data{2} = DataObjects{2};

                S.group{1} = AnalysisObject.group{1};
                S.group{2} = AnalysisObject.group{2};

                S = S.calculate(NBTstudy);

                NBTstudy.statAnalysis{length(NBTstudy.statAnalysis)+1} = S;

                %%% Get the pValues
                pValues = S.pValues;
                
                %%% Multiple comparisons
                multiComp = input('Correct for multiple comparisons? (no / fdr / bonferroni / holm / binomial /hochberg) ','s');

                if strcmp(multiComp,'fdr')
                    q = input('Specify the desired false discovery rate: (default = 0.05) ');
                end

                % Correct for multiple comparisons and remove bad channels
                for biomID = 1 : nBioms
                    %%% Take out the bad channels before we compute the
                    %%% significance mask (topoplot function removes the nans
                    %%% which shift the electrode positions)
                    pValuesCurrent = pValues{biomID};
                    pValuesCurrent = pValuesCurrent(~isnan(pValuesCurrent));

                    if strcmp(multiComp,'fdr')
                        [significanceMask{biomID}, ~] = nbt_MCcorrect(pValuesCurrent,multiComp,q);
                    else
                        [significanceMask{biomID}, ~] = nbt_MCcorrect(pValuesCurrent,multiComp);
                    end

                    % Remove the bad channels from the pValues
                    %pValues{biomID} = find(pValues{biomID})
                end

                %%% Change the string for fdr
                if strcmp(multiComp,'fdr')
                    multiComp = ['fdr(', num2str(q), ')'];
                end
                
                disp('Statistics done.');
            end
    end
    
    disp('Specify plot quality:');
    plotQual = input('1: low (fast / analysis), 2: high (slow / print), 3: very high (very slow / final print) ');
    
    %%% Get the channel locations from one of the two groups
    chanLocs = GroupObjects{1}.chanLocs;
    
    %%% Electrode positions for plotting electrodes on the heads
    % Plotting properties for topoplot.m
    rmax = 0.5;
    plotrad = 0.8011;
    
    for i = 1 : nChannels
        Th(i) = chanLocs(i).theta;
        Rd(i) = chanLocs(i).radius;
    end
    Th = pi/180*Th;
    [x,y]     = pol2cart(Th,Rd);
    
    % Transform electrode locations from polar to cartesian coordinates
    squeezefac = rmax/plotrad;
    Rd = Rd*squeezefac;       % squeeze electrode arc_lengths towards the vertex
                              % to plot all inside the head cartoon
    x    = x*squeezefac;
    y    = y*squeezefac;
    
    %%% Get the reference electrode
    if ~isempty(chanLocs) && ~isempty(chanLocs(1).ref)
        reference = chanLocs(1).ref;
    elseif ~isempty(GroupObjects{1}.ref)
        reference = GroupObjects{1}.ref;
    elseif isempty(GroupObjects{1}.ref)
        reference = 'unknown';
    else
        error('Cannot find a reference electrode');
    end
    
    % Define regions
    regionNames = {'Frontal', 'Left temporal', 'Central', 'Right temporal', 'Parietal', 'Occipital', 'Online reference'};
    regions = cell(1,6);
    regions{1}=[128,32,25,21,26,27,23,19,18,16,15,126,127,14,10,4,8,2,3,123,1,125,9,17,124,122,24,33,22];
    regions{2}=[48 43 38 49 44 39 34 28 40 35 56 50 46 51 47 41 45 57];
    regions{3}=[42 29 20 12 5 118 11 93 54 37 30 13 6 112 105 87 79 31 7 106 80 55 36 104 111];
    regions{4}=[117 110  103 98 116 109 102 97 108 115 121 114 100 107 113 120 119 101];
    regions{5}=[63 68 64 58 65 59 66 52 60 67 72 53 61 62 78 86 77 85 92 84 91 90 96 95 94 99];
    regions{6}=[71  76 70 75 83 69 74 82 89 73 81 88];
    regions{7}=[129];
    
    if nBioms < 25
        perPage = nBioms;
    else
        perPage = 25;
    end
    
    %%% Set maximum number of columns on the topoplot, fixed (5) for
    %%% nbt_Print and other NBT visualization tools
    maxColumns = 5;
    
    % SH FIXME - Just show 1 page for the course
    if strcmp(courseMode,'off')
        % Print just 1 page for course / demonstration
        nPages=ceil(nBioms/25);
    else
        nPages = 1;
    end
    
    % Create figure handle
    %fgh = ones(nPages);
    for page = 1 : nPages
        %% Generates a new figure for each page defined by iotta
        switch dataType
            case {'mean' 'raw'}
                if strcmp(groupType, 'diffDifference')
                    error('difference group not implemented');
                    fgh(page)=figure('name',['Mean of (', char(NBTstudy.groups{groups1(1)}.groupName), ' - ', char(NBTstudy.groups{groups1(2)}.groupName), ') - (', char(NBTstudy.groups{groups2(1)}.groupName), ' - ', char(NBTstudy.groups{groups2(2)}.groupName), ')'],'NumberTitle','off');
                elseif strcmp(groupType, 'difference')
                    fgh(page)=figure('name',['Mean of ', char(GroupObjects{2}.groupName), ' - ', char(GroupObjects{1}.groupName)],'NumberTitle','off');
                elseif strcmp(groupType, 'single')
                    fgh(page)=figure('name',['Mean of ',char(GroupObjects{1}.groupName)],'NumberTitle','off');
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
        elseif plotQual == 9
            set(gcf,'Renderer','painters');
            circgrid = 100;
            gridscale = 100;
        else
            circgrid = 100;
            gridscale = 32;           
        end
        
        upperBound = page * perPage;
        if upperBound > nBioms
            upperBound = nBioms;
        end
        
        crossChans = [21:25, 36:40, 41:45, 46:50];
        for i = page * perPage - perPage + 1 : upperBound    
            subaxis(6, maxColumns, 6+mod(i-1,25), 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
            axis off;
            
            if biomarkerIndex(i) ~= 0
                biomarkerValues = signalBiomarkers{biomarkerIndex(i)};
                
                cbType = '';
                
                % Remove connections higher than 0.99
                if ismember(i,crossChans)
                   for val = 1 : size(biomarkerValues,1)
                       for val2 = 1 : size(biomarkerValues,2)
                           if biomarkerValues(val,val2) > 0.99
                               biomarkerValues(val,val2) = NaN;
                           end
                        end
                   end
                end
                
                if strcmp(groupType,'single')
                    Red_cbrewer5colors = load('Red_cbrewer5colors','Red_cbrewer5colors');
                    Red_cbrewer5colors = Red_cbrewer5colors.Red_cbrewer5colors;
                    colormap(Red_cbrewer5colors);

                    cmin = min(biomarkerValues(:));
                    cmax = max(biomarkerValues(:));
                elseif strcmp(groupType,'difference') | strcmp(groupType,'diffDifference')
                    climit = max(abs(biomarkerValues(:))); %colorbar limit
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
                        NBTPrint8colors = load('nbt_NBTPrint8colors','NBTPrint_8colors');
                        NBTPrint8colors = NBTPrint8colors.NBTPrint_8colors;
                        
                        cmin = -1*climit;
                        cmax = climit;
                        colormap(NBTPrint8colors);
                        cbType = 'diff';
                    end
                end
                
                
                figure(fgh(end));
                
                %%% Plot topoplotConnect for CrossChannelBiomarkers
                if ismember(i,crossChans)
%                     %%% FIXME. Shoutman: check for size of
%                     %%% 'biomarkerValues' instead of checking for member of
%                     %%% a handmade set of connectivity biomarkers
%                     
                    nbt_topoplotConnect(NBTstudy,biomarkerValues,significanceMask{biomarkerIndex(i)},cbType);
                            
                    nbt_plotColorbar(i, cmin, cmax, 6, units, maxColumns, cbType);
                else
                    %%% Biomarker is not a CrossChannelBiomarker
                    %%% Plot the topoplot for the biomarker
                    [topoHandle] = nbt_topoplot(biomarkerValues,chanLocs,'headrad','rim','emarker2',{significanceMask{biomarkerIndex(i)},'o','w',5,2},'maplimits',[-3 3],'style','map','numcontour',0,'electrodes','on','circgrid',circgrid,'gridscale',gridscale,'shading','flat');
                    set(gca, 'LooseInset', get(gca,'TightInset'));
                    
                    if strcmp(groupType,'difference') | strcmp(groupType,'diffDifference')
                        DataObjectGrp1 = DataObjects{1};
                        DataObjectGrp2 = DataObjects{2};
                        biomValuesAllSubjGrp1 = DataObjectGrp1{biomarkerIndex(i),:};
                        biomValuesAllSubjGrp2 = DataObjectGrp2{biomarkerIndex(i),:};
                    else
                        DataObject = DataObjects{1};
                        biomValuesAllSubj = DataObject{biomarkerIndex(i),:};
                    end
                    
                    hold on
                    
                    % Get the pValues and significanceMask for this biomarker
                    % Important: The electrodes in the significance mask
                    % correspond to the significant electrodes after the
                    % NaNs have been taken out!
                    biompValues = pValues{biomarkerIndex(i)};
                    
                    %% Take out the badchannels for the current biomarker
                    xGoodChans = x(~ismember(x,x(badChannels{biomarkerIndex(i)})));
                    yGoodChans = y(~ismember(y,y(badChannels{biomarkerIndex(i)})));
                    
                    for channel = 1 : nChannels
                        % Find the region the electrode belongs to
                        for region = 1 : 7
                            if ismember(channel,regions{region})
                                regName = regionNames{region};
                            end
                        end
                        if ismember(channel,[11,17,62,75,129])
                            hp2 = plot3(y(channel),x(channel),2.1,'.','Color',[0 0 0],'markersize',5,'linewidth',1);
                        else
                            hp2 = plot3(y(channel),x(channel),2.1,'.','Color',[0 0 0],'markersize',3,'linewidth',1);
                        end
                        subaxMenu(i,channel) = uicontextmenu;
                        set(hp2,'uicontextmenu',subaxMenu(i,channel));
                        if ~isempty(biompValues) & ~isnan(biompValues(channel))
                            uimenu(subaxMenu(i,channel),'label',[chanLocs(channel).labels ' - ' regName],'enable','off');
                        else
                            uimenu(subaxMenu(i,channel),'label',[chanLocs(channel).labels ' - Bad channel / Eye channel'],'enable','off');
                        end
                        
                        if ~isempty(biompValues) & ~isnan(biompValues(channel))
                            electrodeData.pValues = biompValues(channel);
                            uimenu(subaxMenu(i,channel),'label',['p-value: ' num2str(biompValues(channel))],'enable','off');
                        else
                            electrodeData.pValues = [];
                        end
                        
                        % If a group difference is plotted then create
                        % the right-click options
                        if strcmp(groupType,'difference') | strcmp(groupType,'diffDifference')
                            % Only create the right-click options if the
                            % pValue is not a NaN (because NaN means
                            % badChannel or eyeChannel)
                            if ~isempty(biompValues) & ~isnan(biompValues(channel))
                                electrodeData.electrodeValues{1} = biomValuesAllSubjGrp1(channel,:);
                                electrodeData.electrodeValues{2} = biomValuesAllSubjGrp2(channel,:);
                                electrodeData.groupName{1} = GroupObjects{1}.groupName;
                                electrodeData.groupName{2} = GroupObjects{2}.groupName;
                                electrodeData.subjectList1 = DataObjects{1}.subjectList{1};
                                electrodeData.subjectList2 = DataObjects{2}.subjectList{1};

                                uimenu(subaxMenu(i,channel),'label','Plot electrode values','callback','nbt_plotBiomarkerValues','Separator','on');

                                if exist('S','var')
                                    electrodeData.statObject = S;
                                    uimenu(subaxMenu(i,channel),'label','Compare two conditions','callback',@plotTopoAll);
                                else
                                    electrodeData.statObject = [];
                                end
                            end
                        elseif strcmp(groupType,'single')
                            % Create right-click option for plotting
                            % electrode values for a single group?
                            electrodeData.electrodeValues{1} = biomValuesAllSubj(channel,:);
                            electrodeData.groupName{1} = GroupObjects{1}.groupName;
                        end
                        electrodeData.electrodeName = chanLocs(channel).labels;
                        electrodeData.biomarkerName = AnalysisObject.group{1}.originalBiomNames{biomarkerIndex(i)};
                        electrodeData.biomarkerIndex = biomarkerIndex(i);

                        set(hp2,'UserData',electrodeData);
                    end
                    
                    if cmin ~= cmax
                        nbt_plotColorbar(i, cmin, cmax, 6, units, maxColumns, cbType);
                    end
                end
           end
            
            %% PLOTTING FREQUENCY BANDS ABOVE THE TOP ROW
            % omega is the # index of the last pre-defined biomarker
            switch VIZ_LAYOUT
                case 'dflt'
                    if mod(i,25)==1 && i <= omega;
                        title ('Delta','FontSize',10,'fontweight','demi');
                    elseif mod(i,25)==2 && i<= omega;
                        title ('Theta','FontSize',10,'fontweight','demi');
                    elseif mod(i,25)==3 && i<= omega;
                        title ('Alpha','FontSize',10,'fontweight','demi');
                    elseif mod(i,25)==4 && i<= omega;
                        title ('Beta','FontSize',10,'fontweight','demi');
                    elseif mod(i,25)==5 && i<= omega;
                        title ('Gamma','FontSize',10,'fontweight','demi');
                    elseif i>omega
                        title (biom{i},'FontSize',10,'fontweight','demi');
                    end
                case 'cstm'
                    title (biom{i},'FontSize',10,'fontweight','demi')
            end
        end
        
        ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        
        % If it is a difference group:
        if strcmp(groupType,'diffDifference')
%             text(0.5, 0.99,['NBT print for groups ', NBTstudy.groups{groups1(1)}.groupName, ', ', NBTstudy.groups{groups2(1)}.groupName, ' and ', NBTstudy.groups{groups2(2)}.groupName],'HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',22,'Interpreter','tex');
%             switch dataType
%             case 'mean'
%                 text(0.5,0.93,['Average difference of (', char(NBTstudy.groups{groups1(1)}.groupName), ' - ', char(NBTstudy.groups{groups1(2)}.groupName), ') - (', char(NBTstudy.groups{groups2(1)}.groupName), ' - ', char(NBTstudy.groups{groups2(2)}.groupName), ')', ' ({\itn} = ', num2str(nSubjects),'), reference electrode: ',reference],'horizontalalignment','center','FontSize',14,'Interpreter','tex');
%             case 'raw'
%                 text(0.5,0.93,['Raw difference of (', char(NBTstudy.groups{groups1(1)}.groupName), ' - ', char(NBTstudy.groups{groups1(2)}.groupName), ') - (', char(NBTstudy.groups{groups2(1)}.groupName), ' - ', char(NBTstudy.groups{groups2(2)}.groupName), ')', ' ({\itn} = ', num2str(nSubjects),'), reference electrode: ',reference],'horizontalalignment','center','FontSize',14,'Interpreter','tex');
%             end
%             
%             try
%                 text(0.5,0.90,['Multiple comparisons: ', multiComp],'horizontalalignment','center','FontSize',12,'Interpreter','tex');
%             catch
%             end
        elseif strcmp(groupType,'difference')
            text(0.5, 0.99,['NBT print for groups ', char(GroupObjects{2}.groupName), ' and ', char(GroupObjects{1}.groupName)],'HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',22,'Interpreter','tex');
            switch dataType
            case 'mean'
                text(0.5,0.93,['Average difference of ', char(GroupObjects{2}.groupName), ' - ', char(GroupObjects{1}.groupName), ' ({\itn} = ', num2str(nSubjects),'), reference electrode: ',reference],'horizontalalignment','center','FontSize',14,'Interpreter','tex');
            case 'raw'
                text(0.5,0.93,['Raw difference of ', char(GroupObjects{2}.groupName), ' - ', char(GroupObjects{1}.groupName), ' ({\itn} = ', num2str(nSubjects),'), reference electrode: ',reference],'horizontalalignment','center','FontSize',14,'Interpreter','tex');
            end
            
            try
                text(0.5,0.90,['Multiple comparisons: ', multiComp],'horizontalalignment','center','FontSize',12,'Interpreter','tex');
            catch
            end
        else
            if strcmp(dataType,'mean')
                text(0.5,0.93,['Average of subjects ({\itn} = ', num2str(nSubjects) ,'), reference electrode: ',reference],'horizontalalignment','center','FontSize',14,'Interpreter','tex');
            end
            text(0.5, 0.99,strcat('NBT print for group ',{' '},GroupObjects{1}.groupName),'HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',22,'Interpreter','tex');
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
                    
                    if strcmp(courseMode,'off')
                        % SH FIXME - Just 4 rows for the course
                        get(gcf,'CurrentAxes');
                        LIFETIME= text(0.02,1/12, 'PLI','horizontalalignment', 'center', 'fontweight','demi');
                        set(LIFETIME,'rotation',90);
                    end
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
        
%         set(gcf,'UserData',GroupObjects{1}.groupName);
%         h1 = uicontrol(gcf,'Style','PushButton',...
%                'Units','normalized',...
%                'String','Save figure',...
%                'Position',[.89 .95 .1 .04],'callback',@saveNBTPrint);
    end

% Nested functions part
%         function saveNBTPrint(D1,D2)
%             groupName = get(gcf,'UserData');
%             set(gcf, 'PaperOrientation', 'landscape');
%             h = gcf;
%             
%             orient landscape
%             
%             %set(h,'PaperSize',[21 29.7]);
%             print(h,['NBTPrint_' groupName],'-dpng','-painters','-r 300');
%         end
        function plotTopoAll(D1,D2)
            userData = get(gco,'UserData');
                        
            nbt_plot_2conditions_topoAll(userData.statObject,userData.biomarkerIndex);
        end


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

    function [AnalysisObjGrpDiff, DataObjGrpDiff, signalBiomarkers] = extractBiomarkers(NBTstudy,groups)
        %%% Get groups NBTstudy
        Group1 = NBTstudy.groups{groups(1)};
        Group2 = NBTstudy.groups{groups(2)};

        %%% Generate fixed biomarker list using Group1
        AnalysisObjGrpDiff = nbt_generateBiomarkerList(NBTstudy,signal,groups(1));

        DataObjGrpDiff = getData(NBTstudy.groups{groups},AnalysisObjGrp1);
    end
    
    function [signalBiomarkers] = getBiomarkerValues(DataObjects, subjectNumber)
        % Get information from DataObj
        nSubjects = DataObjects{1}.numSubjects;
        nBioms = DataObjects{1}.numBiomarkers;

        % Initialize matrices for signalBiomarkers and
        % crossChannelBiomarkers
        %signalBiomarkers = zeros(nBioms,nChannels);
        %crossChannelBiomarkers = zeros(nChannels,nChannels,nBioms);
        for biomID = 1 : nBioms
            switch dataType
                case 'raw'
                    error('Functionality not available for HN2015.');
                case 'mean'
                    if size(DataObjects,2) == 1
                        DataObjectGrp1 = DataObjects{1};
                        meanGrp1 = nanmean(DataObjectGrp1{biomID,:},2);
                        signalBiomarkers{biomID} = meanGrp1'; 
                    elseif size(DataObjects,2) == 2
                        DataObjectGrp1 = DataObjects{1};
                        DataObjectGrp2 = DataObjects{2};
                        meanGrp1 = nanmean(DataObjectGrp1{biomID,:},2);
                        meanGrp2 = nanmean(DataObjectGrp2{biomID,:},2);
                        signalBiomarkers{biomID} = meanGrp2' - meanGrp1';
                    end
            end
        end
        signalBiomarkers = signalBiomarkers';
    end
end