function nbt_runStatistics(GUIswitch)
global NBTstudy
if(GUIswitch)
    disp('Waiting for statistics ...')
    HrunStat = findobj( 'Tag', 'NBTstatRunButton');
    set(HrunStat, 'String', 'Calculating..')
    drawnow
    
    %Let's generate the statistics object
    S = NBTstudy.getStatisticsTests(get(findobj('Tag','ListStat'),'Value'));
    S.groups = get(findobj('Tag', 'ListGroup'),'Value');
    bioms_ind = get(findobj('Tag','ListBiomarker'),'Value');
    bioms_name = get(findobj('Tag','ListBiomarker'),'String');
    S.channelsRegionsSwitch = get(findobj('Tag', 'ListRegion'),'Value');
else %case of commandline
    statTestList = NBTstudy.getStatisticsTests(0);
    for mm=1:size(statTestList,2)
        disp([int2str(mm) ':' statTestList{1,mm}])
    end
    statTestIdx = input('Please select test above ');
    S = NBTstudy.getStatisticsTests(statTestIdx);
    
    disp('Groups:')
    for mm=1:length(NBTstudy.groups)
        disp([int2str(mm) ':' NBTstudy.groups{mm}.groupName])
    end
    S.groups = input('Please select groups above ');
    
    disp('Biomarkers')
    bioms_name = NBTstudy.groups{1}.biomarkerList;
    ll=0;
    for mm=1:length(bioms_name)
        disp([int2str(mm) ':' bioms_name{1,mm} ])
        ll=ll+1;
        if(ll ==20)
            input('More (press enter)');
            ll = 0;
        end
    end
    bioms_ind = input('Please select biomarkers above ');
    
    
    disp('1:Channels');
    disp('2:Regions');
    disp('3:Match channels');
    S.channelsRegionsSwitch  = input('Please select channels, regions, or match channels ');
end


for gp = 1:length(S.groups)
    for i = 1:length(bioms_ind)
        [S.group{gp}.biomarkers{i}, S.group{gp}.biomarkerIdentifiers{i}, S.group{gp}.subBiomarkers{i}, S.group{gp}.classes{i}, S.group{gp}.units{i}] = nbt_parseBiomarkerIdentifiers(bioms_name{bioms_ind(i)});
    end
end

if strcmp(class(S),'nbt_lssvm')
    %cv_type = input('Cross validation: 10-fold or random subsampler? (F/RS)');
    S.nCrossVals = input('Input the desired number of cross-validations (e.g. 100) ');
    dimRed = input('Would you like to perform dimensionality reduction first? Y/N ','s');
    if strcmp(dimRed,'Y')
        S.dimensionReduction = input('Which kind of dimensionality reduction? PCA/PLS/ICA/MDS? ','s');
    end    
end

if isa(S,'nbt_PairedStat') || isa(S,'nbt_UnPairedStat')
    NBTstudy.settings.visual.mcpCorrection = input('Input desired multiple comparison correction: "holm", "hochberg", "binomial", "bonfi" or "fdr" ', 's');
end
    
S = S.calculate(NBTstudy);

NBTstudy.statAnalysis{length(NBTstudy.statAnalysis)+1} = S;
disp('Statistics done.')
if ~strcmp(class(S),'nbt_lssvm')&& ~strcmp(class(S),'nbt_spiderplot') && ~strcmp(class(S),'nbt_comparebiomarkers') % && ~strcmp(class(S),'nbt_ttest')
    nbt_plot_2conditions_topoAll(S)
end

if strcmp(class(S),'nbt_ttest')&& ismember('rsq.Answers',S.getBiomarkerNames)
    nbt_pvaluesmatrix(S)
end

end