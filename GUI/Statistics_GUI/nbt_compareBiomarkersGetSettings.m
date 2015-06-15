function nbt_compareBiomarkersGetSettings(d1,d2,ListBiom1, ListBiom2, ListRegion, ListGroup,ListTest,ListDisplay,ListSplit,ListSplitValue,StatObj)
disp('Computing biomarkers comparison ...')
global NBTstudy

load Questions

% arsq_biom_index = find(ismember(StatObj.data{1}.biomarkers,'NBTe_nbt_rsq'));
% Questions = StatObj.data{1}.biomarkerMetaInfo{arsq_biom_index};

load ARSQfactors
ARSQfactors.arsqLabels = Questions;



% arsq_biom_index = find(ismember(StatObj.data{1}.biomarkers,'NBTe_nbt_rsq'));
% Questions = StatObj.data{1}.biomarkerMetaInfo{arsq_biom_index};


bioms_name = get(findobj('Tag','ListBiomarker'),'String');

% --- get statistics test (one)
bioms_ind1 = get(ListBiom1,'Value');
bioms_name1 = get(ListBiom1,'String');
bioms_name1 = bioms_name1(bioms_ind1);
% --- get channels or regions (ozzne)
regs_or_chans_index = get(ListRegion,'Value');
regs_or_chans_name = get(ListRegion,'String');
regs_or_chans_name = regs_or_chans_name(regs_or_chans_index);
% --- get biomarkers (one or more)
bioms_ind2 = get(ListBiom2,'Value');
bioms_name2 = get(ListBiom2,'String');
bioms_name2 = bioms_name2(bioms_ind2);
% --- get group (one or more)
group_ind = get(ListGroup,'Value');
group_name = get(ListGroup,'String');
group_name = group_name(group_ind);
% --- get Test
test_ind = get(ListTest,'Value');

% --- get Display
display_ind = get(ListDisplay,'Value');


splitType = get(ListSplit,'Value');
splitValue = str2num(get(ListSplitValue,'String'));

StatObj.groups = group_ind;

bioms_ind = [bioms_ind1 bioms_ind2];

StatObj.channelsRegionsSwitch  = regs_or_chans_index;

for gp = 1:length(StatObj.groups)
    for i = 1:length(bioms_ind)
        [StatObj.group{gp}.biomarkers{i}, StatObj.group{gp}.biomarkerIdentifiers{i}, StatObj.group{gp}.subBiomarkers{i}, StatObj.group{gp}.classes{i}, StatObj.group{gp}.units{i}] = nbt_parseBiomarkerIdentifiers(bioms_name{bioms_ind(i)});
    end
end


group_diffexist = 0;

if length(group_ind) == 1
    [B_values1,B_values2, bioms1,bioms2, Group1] = getCompareBiomarkerData(bioms_name1,bioms_name2,group_ind,StatObj);
    Group2.groupName = '';
else
    [B_values1,B_values2, bioms1,bioms2, Group1,Group2] = getCompareBiomarkerData(bioms_name1,bioms_name2,group_ind,StatObj);
end

%[B_values1, B_values2] = getCompareBiomarkerRegions(regs_or_chans_name,bioms_name1,bioms_name2,B_values1,B_values2,group_ind,StatObj);

try
emptyDats = ~cellfun(@isempty,StatObj.data);
presentDats = find(emptyDats);


% replace Questions with StatObj.data{1}.biomarkerMetaInfo{2} !!!
classes = StatObj.data{presentDats}.classes;
if strcmp(classes{1},'nbt_QBiomarker')
    ARSQfactors.arsqLabels = StatObj.data{presentDats(1)}.biomarkerMetaInfo{1};
    Questions = StatObj.data{presentDats(1)}.biomarkerMetaInfo{1};
else
    if strcmp(classes{2},'nbt_QBiomarker');
        ARSQfactors.arsqLabels = StatObj.data{presentDats(1)}.biomarkerMetaInfo{2};
        Questions = StatObj.data{presentDats(1)}.biomarkerMetaInfo{2};
    else
        
    end
end

catch me
end

switch (test_ind)
    case 1
        %%
        if size(B_values2,2) >=8 && size(B_values2,2) <=10
            disp('This operation might take a very long time... consider using Pearson correlation instead');
        end
        for n = 1:size(B_values2,1);
            for m = 1: size(B_values1,1);
                
                
                [rho(n,m),Pvalues(n,m)] = corr(B_values1(m,:)',B_values2(n,:)','type','Spearman');
                
                
            end
        end
        
    case 2
        %%
        %split on second biomarker
        for n = 1:size(B_values2,1);
            for m = 1: size(B_values1,1);
                if splitType == 1
                    %split on %
                    nns = nnz(isnan(B_values2(n,:)));
                    if nns > 0
                        quarts = floor((splitValue/100)*(size(B_values2,2)- nns));
                        [valk,inds] = sort(B_values2(n,:));
                        Grp2{n} = inds(1:quarts);
                        Grp1{n} = inds(1+end-quarts-nns:end-nns);
                    else
                        quarts = floor((splitValue/100)*size(B_values2,2));
                        [indef,inds] = sort(B_values2(n,:));
                        Grp2{n} = inds(1:quarts);
                        Grp1{n} = inds(1+end-quarts:end);
                    end
                    
                    B1 = B_values1(m,Grp1{n}); % biomarker for yes group
                    B2 = B_values1(m,Grp2{n}); % biomarker for no group
                    [indef,Pvalues(n,m),indef] = ttest2(B1,B2);
                    rho(n,m) = mean(B1)-mean(B2);
                else
                    %split on value
                    Grp1{n} = find(B_values2(n,:)>splitValue);% yes
                    Grp2{n} = find(B_values2(n,:)<splitValue);% no
                    
                    B1 = B_values1(m,Grp1{n}); % biomarker for yes group
                    B2 = B_values1(m,Grp2{n}); % biomarker for no group
                    [indef,Pvalues(n,m),indef] = ttest2(B1,B2);
                    rho(n,m) = mean(B1)-mean(B2);
                end
            end
        end
    case 3
        %%
        
        for n = 1:size(B_values2,1);
            for m = 1: size(B_values1,1);
                [rho(n,m),Pvalues(n,m)] = corr(B_values1(m,:)',B_values2(n,:)','type','Pearson');
            end
        end
        
    case 4
        %%
        if size(B_values2,2) >=8 && size(B_values2,2) <=10
            disp('This operation might take a very long time... consider using Pearson correlation instead');
        end
        for i = 1:size(B_values1,3)
            for n = 1:size(B_values2,1);
                for m = 1: size(B_values1,1);
                    [rho(n,m),Pvalues(n,m)] = corr(B_values1(m,:)',B_values2(n,:)','type','Kendall');
                end
            end
        end
        
end

assignin('base','Pvalues',Pvalues)
assignin('base','rho',rho)

Pvalues(isinf(log10(Pvalues))) = 10^-2.6;

if (display_ind == 1 && test_ind ~= 5  && test_ind ~=6)
    h2 = figure('Visible','on','numbertitle','off','Name','Biomarkers Comparison','position',[10 80 1700 500]);
    %display as grid system
    
    subplot(1,1,1)
    %--- bar plot (map of pvalues)
    minPValue = -2.6;% Plot log10(P-values) to trick colour bar
    maxPValue = 0;
    hh=uicontextmenu;
    hh2 = uicontextmenu;
    bh=bar3(log10(Pvalues'));
    for k=1:length(bh)
        zdata = get(bh(k),'Zdata');
        set(bh(k),'cdata',zdata);
    end
    colorbar('off')
    coolWarm = load('nbt_CoolWarm.mat','coolWarm');
    coolWarm = coolWarm.coolWarm;
    colormap(coolWarm);
    cbh = colorbar('SouthOutside');
    caxis([minPValue maxPValue])
    set(cbh,'XTick',[-2.6 -1.3010 -1 0])
    set(cbh,'XTicklabel',[0.01 0.05 0.1 1]) %(log scale)
    set(get(cbh,'title'),'String','P-values');
    axis tight
    set(gca,'xticklabel','')
    if isempty(strfind(bioms_name1{1},'Answers')) || isempty(strfind(bioms_name1{1},'values'))
        for j = 1: size(B_values1,1)
            if strcmp(regs_or_chans_name,'Regions')
                reg = NBTstudy.groups{1}.listRegData;
                umenu = text(size(B_values2,1)+1,j,[num2str(j) '. ' reg(j).reg.name],'horizontalalignment','left','fontsize',8,'interpreter','none','rotation',-30);
            else
                umenu = text(size(B_values2,1)+1,j,['Channel '  num2str(j)],'horizontalalignment','left','fontsize',8,'rotation',-30);
            end
        end
        
        
        set(gca,'yTick',[],'yticklabel',[],'fontsize',8)
    else
        for j = 1: size(B_values1,1)
            
            if isempty(strfind(bioms_name1{1},'Factors'));
                varQuest = ARSQfactors;
                umenu = text(size(B_values2,1)+1,j,[varQuest.arsqLabels{j} ' ' num2str(j)],'horizontalalignment','left','fontsize',8,'rotation',-90);
            else
                varQuest = ARSQfactors;
                umenu = text(size(B_values2,1)+1,j,[varQuest.factorLabels{j} ' ' num2str(j)],'horizontalalignment','left','fontsize',8,'rotation',-90);
            end
            set(umenu,'uicontextmenu',hh);
        end
        set(gca,'yTick',[],'yticklabel',[],'fontsize',8)
    end
    
    view(-90,-90)
    
    %     pos = get(gca,'Position')
    pos = get(cbh,'Position');
    % p value bar
    set(cbh,'Position',[pos(1)-0.5*pos(1) pos(2)-0.6*pos(2) 0.1 0.03])
    for j = 1: size(B_values2,1)
        if ~isempty(strfind(bioms_name2{1},'Answers')) || ~isempty(strfind(bioms_name2{1},'values'))
            if isempty(strfind(bioms_name2{1},'Factors'));
                varQuest = ARSQfactors;
                limx = get(gca,'xlim');
                umenu = text(j,limx(1),[varQuest.arsqLabels{j} ' ' num2str(j)],'horizontalalignment','right','fontsize',8);
            else
                varQuest = ARSQfactors;
                limx = get(gca,'xlim');
                umenu = text(j,limx(1),[varQuest.factorLabels{j} ' ' num2str(j)],'horizontalalignment','right','fontsize',8);
            end
            set(umenu,'uicontextmenu',hh);
        else
            if strcmp(regs_or_chans_name,'Regions')
                reg = NBTstudy.groups{1}.listRegData;
                umenu = text(j,-5,[num2str(j) '. ' reg(j).reg.name],'horizontalalignment','left','fontsize',8,'interpreter','none');
            else
                umenu = text(j,-12,['Channel '  num2str(j)],'horizontalalignment','left','fontsize',8);
            end
        end
    end
    title(['P-values of the correlation between ',regexprep(bioms2,'_',' '), ' and ', regexprep(bioms1,'_',' ')],'fontweight','bold','fontsize',12)
    title(['Correlation between groups difference of ',regexprep(bioms2,'_',' '), ' and difference ', regexprep(bioms1,'_',' ')],'fontweight','bold','fontsize',12)
    set(bh,'uicontextmenu',hh2);
        
    uimenu(hh,'label','Correlation topoplot','callback',{@nbt_compareBiomarkersPlotTopos,B_values1,B_values2,bioms1,bioms2,1,Pvalues',rho',length(group_ind),splitType,splitValue,regs_or_chans_name,test_ind});
    uimenu(hh2,'label','plot boxplots and least-squares fit','callback',{@nbt_compareBiomarkersPlotChansComp,B_values1,B_values2,bioms1,bioms2,1,length(group_ind),splitType,splitValue,Pvalues,test_ind,regs_or_chans_index,Group1.groupName,Group2.groupName});
    
else if ( test_ind ~= 5 && test_ind ~=6 )
        %display as topoplots
        
        if strcmp(regs_or_chans_name,'Components')
            disp(['Should view as individual channels instead of components']);
        else
            
            if ~isempty(strfind(bioms_name2{1},'Answers')) || ~isempty(strfind(bioms_name2{1},'values'))
                %sbp = ceil(size(B_values2,1)^0.5);
                sbp = 4;
                mxlim = max([abs(max(max(rho))) abs(min(min(rho)))]);
                noFigs = ceil(size(B_values2,1)/16);
                for k = 1:noFigs
                    figure;
                    coolWarm = load('nbt_CoolWarm.mat','coolWarm');
                    coolWarm = coolWarm.coolWarm;
                    colormap(coolWarm);
                    for i = 1+((k-1)*16):min(k*16,size(B_values2,1))
                        idd = i-((k-1)*16);
                        % subplot(sbp,sbp,idd);
                        if strcmp(regs_or_chans_name,'Regions')
                            disp('Topoplots only work for Channels')
                            
                            if nnz(isnan(Pvalues(i,:))) > 0
                                xidd =  mod(idd-1,4);
                                yidd = 4-(1 +floor((idd-1)/4));
                                
                                axes;
                                
                                set(gca,'position',[0.05+ (0.25 * xidd) 0.05 + (0.25 * yidd) 0.2 0.1]);
                                set(gca,'xtick',[]);
                                set(gca,'ytick',[]);
                                text(0.25,0.5,'No members in one of the groups','fontweight','bold');
                                origTitle = get(get(gca,'title'),'position');
                            else
                                
                                axes;
                                set(gca,'clim',[-6 0]);
                                nbt_plot_subregions_hack(log10(Pvalues(i,:)),-2.6,0);
                                xidd =  mod(idd-1,4);
                                yidd = 4-(1 +floor((idd-1)/4));
                                
                                cbh = colorbar('WestOutside');
                                oldCBH = get(cbh,'position');
                                oldCBH(1) = 0.05 + (0.25 * xidd) + 0.01;
                                oldCBH(2) = 0.05 + (0.25 * yidd);
                                oldCBH(3) = 0.0086;
                                oldCBH(4) = 0.1009;
                                
                                set(cbh,'position',oldCBH);
                                set(cbh,'yTick',[-6 -3  0])
                                set(cbh,'yTicklabel',[0.000001 0.001 1])
                                set(gca,'position',[0.05 + (0.25 * xidd) 0.05 + (0.25 * yidd) 0.1 0.1]);
                                
                                
                                axes;
                                
                                nbt_plot_subregions_hack(rho(i,:),-mxlim,mxlim);
                                set(gca,'clim',[-mxlim mxlim]);
                                cbh = colorbar('EastOutside');
                                oldCBH = get(cbh,'position');
                                oldCBH(1) = 0.05+ (0.25 * xidd)+0.15;
                                oldCBH(2) = 0.05 + (0.25 * yidd);
                                oldCBH(3) = 0.0086;
                                oldCBH(4) = 0.1009;
                                set(cbh,'position',oldCBH);
                                set(gca,'position',[ 0.05+(0.25 * xidd)+0.07 0.05 + (0.25 * yidd) 0.1 0.1]);
                                origTitle = get(get(gca,'title'),'position');
                                if (test_ind ~= 2)
                                    text(-0.2,-1.2514,origTitle(3),'rho');
                                else
                                    text(-0.2,-1.2514,origTitle(3),'\delta mean');
                                end
                                text(-3,-1.2514,origTitle(3),'P-value');
                                origTitle(1) = -2.7;
                            end
                            if isempty(strfind(bioms_name2{1},'Factors'))
                                varQuest = ARSQfactors;
                                if (length(varQuest.arsqLabels{i}) > 20)
                                    bs = varQuest.arsqLabels{i};
                                    [ab, cd] = strtok(bs(15:end));
                                    ad = length(ab);
                                    
                                    if nnz(isspace(cd)) == length(cd)
                                        title([num2str(i) '. ' bs(1:14 + ad)],'FontWeight','Bold');
                                    else
                                        title({[num2str(i) '. ' bs(1:14 + ad)], cd},'FontWeight','Bold');
                                    end
                                else
                                    title([num2str(i) '. ' varQuest.arsqLabels{i}],'FontWeight','Bold');
                                end
                            else
                                varQuest = ARSQfactors;
                                if (length(varQuest.factorLabels{i}) > 20)
                                    bs = varQuest.factorLabels{i};
                                    [ab, cd] = strtok(bs(15:end));
                                    ad = length(ab);
                                    
                                    if nnz(isspace(cd)) == length(cd)
                                        title([num2str(i) '. ' bs(1:14 + ad)],'FontWeight','Bold');
                                    else
                                        title({[num2str(i) '. ' bs(1:14 + ad)], cd},'FontWeight','Bold');
                                    end
                                else
                                    title([num2str(i) '. ' varQuest.factorLabels{i}],'FontWeight','Bold');
                                end
                            end
                            set(get(gca,'title'),'position',origTitle);
                        else
                            if nnz(isnan(Pvalues(i,:))) > 0
                                xidd =  mod(idd-1,4);
                                yidd = 4-(1 +floor((idd-1)/4));
                                
                                axes;
                                
                                set(gca,'position',[0.05+ (0.25 * xidd) 0.05 + (0.25 * yidd) 0.2 0.1]);
                                set(gca,'xtick',[]);
                                set(gca,'ytick',[]);
                                text(0.25,0.5,'No members in one of the groups','fontweight','bold');
                                
                            else
                                axes;
                                % topoplot(log10(Pvalues(i,:)),NBTstudy.groups{1}.listRegData);
                                topoplot(log10(Pvalues(i,:)),NBTstudy.groups{1}.chanLocs);
                                %topoplot(log10(Pvalues(i,:)),G(1).chansregs.chanloc);
                                xidd =  mod(idd-1,4);
                                yidd = 4-(1 +floor((idd-1)/4));
                                set(gca,'clim',[-6 0]);
                                
                                cbh = colorbar('WestOutside');
                                oldCBH = get(cbh,'position');
                                oldCBH(1) = 0.05+ (0.25 * xidd) + 0.01;
                                oldCBH(2) = 0.05 + (0.25 * yidd);
                                oldCBH(3) = 0.0086;
                                oldCBH(4) = 0.1009;
                                set(cbh,'position',oldCBH);
                                set(cbh,'yTick',[-6 -3  0])
                                set(cbh,'yTicklabel',[0.00001 0.001  1])
                                
                                
                                set(gca,'position',[0.05+ (0.25 * xidd) 0.05 + (0.25 * yidd) 0.1 0.1]);
                                
                                axes;
                                topoplot(rho(i,:),NBTstudy.groups{1}.chanLocs);
                                %topoplot(rho(i,:),G(1).chansregs.chanloc);
                                set(gca,'clim',[-mxlim mxlim]);
                                cbh = colorbar('EastOutside');
                                oldCBH = get(cbh,'position');
                                oldCBH(1) = 0.05+(0.25 * xidd)+0.15;
                                oldCBH(2) =  0.05 + (0.25 * yidd);
                                oldCBH(3) = 0.0086;
                                oldCBH(4) = 0.1009;
                                set(cbh,'position',oldCBH);
                                
                                set(gca,'position',[ 0.05+(0.25 * xidd)+0.07 0.05 + (0.25 * yidd) 0.1 0.1]);
                                origTitle = get(get(gca,'title'),'position');
                                if (test_ind ~=2)
                                    text(-0.1,-origTitle(2),origTitle(3),'rho');
                                else
                                    text(-0.1,-origTitle(2),origTitle(3),'\delta mean');
                                end
                                text(-1.4,-origTitle(2),origTitle(3),'P-value');
                                origTitle(1) = -0.7;
                                
                                set(get(gca,'title'),'position',origTitle);
                            end
                            if isempty(strfind(bioms_name2{1},'Factors'))
                                varQuest = ARSQfactors;
                                if (length(varQuest.arsqLabels{i}) > 20)
                                    bs = varQuest.arsqLabels{i};
                                    [ab, cd] = strtok(bs(15:end));
                                    ad = length(ab);
                                    
                                    if nnz(isspace(cd)) == length(cd)
                                        title([num2str(i) '. ' bs(1:14 + ad)],'FontWeight','Bold');
                                    else
                                        title({[num2str(i) '. ' bs(1:14 + ad)], cd},'FontWeight','Bold');
                                    end
                                else
                                    title([num2str(i) '. ' varQuest.arsqLabels{i}],'FontWeight','Bold');
                                end
                            else
                                varQuest = ARSQfactors;
                                if (length(varQuest.factorLabels{i}) > 20)
                                    bs = varQuest.factorLabels{i};
                                    [ab, cd] = strtok(bs(15:end));
                                    ad = length(ab);
                                    
                                    if nnz(isspace(cd)) == length(cd)
                                        title([num2str(i) '. ' bs(1:14 + ad)],'FontWeight','Bold');
                                    else
                                        title({[num2str(i) '. ' bs(1:14 + ad)], cd},'FontWeight','Bold');
                                    end
                                else
                                    title([num2str(i) '. ' varQuest.factorLabels{i}],'FontWeight','Bold');
                                end
                            end
                            origTitle = get(get(gca,'title'),'position');
                            origTitle(1) = -0.7;
                            set(get(gca,'title'),'position',origTitle);
                        end
                    end
                end
            else
                if ~isempty(strfind(bioms_name1{1},'Answers')) || ~isempty(strfind(bioms_name1{1},'values'))
                    sbp = 4;
                    mxlim = max([abs(max(max(rho))) abs(min(min(rho)))]);
                    noFigs = ceil(size(B_values1,1)/16);
                    for k = 1:noFigs
                        figure;
                        coolWarm = load('nbt_CoolWarm.mat','coolWarm');
                        coolWarm = coolWarm.coolWarm;
                        colormap(coolWarm);
                        for i = 1+((k-1)*16):min(k*16,size(B_values1,1))
                            try
                                idd = i-((k-1)*16);
                                % subplot(sbp,sbp,idd);
                                if strcmp(regs_or_chans_name,'Regions')
                                    axes;
                                    set(gca,'clim',[-6 0]);
                                    nbt_plot_subregions_hack(log10(Pvalues(:,i)),-2.6,0);
                                    xidd =  mod(idd-1,4);
                                    yidd = 4-(1 +floor((idd-1)/4));
                                    
                                    cbh = colorbar('WestOutside');
                                    oldCBH = get(cbh,'position');
                                    oldCBH(1) = 0.05 + (0.25 * xidd) + 0.01;
                                    oldCBH(2) = 0.05 + (0.25 * yidd);
                                    oldCBH(3) = 0.0086;
                                    oldCBH(4) = 0.1009;
                                    
                                    set(cbh,'position',oldCBH);
                                    set(cbh,'yTick',[-6 -3 0])
                                    set(cbh,'yTicklabel',[0.000001 0.001 1])
                                    set(gca,'position',[0.05 + (0.25 * xidd) 0.05 + (0.25 * yidd) 0.1 0.1]);
                                    
                                    
                                    axes;
                                    
                                    nbt_plot_subregions_hack(rho(:,i),-mxlim,mxlim);
                                    set(gca,'clim',[-mxlim mxlim]);
                                    cbh = colorbar('EastOutside');
                                    oldCBH = get(cbh,'position');
                                    oldCBH(1) = 0.05+ (0.25 * xidd)+0.15;
                                    oldCBH(2) = 0.05 + (0.25 * yidd);
                                    oldCBH(3) = 0.0086;
                                    oldCBH(4) = 0.1009;
                                    set(cbh,'position',oldCBH);
                                    set(gca,'position',[ 0.05+(0.25 * xidd)+0.07 0.05 + (0.25 * yidd) 0.1 0.1]);
                                    if isempty(strfind(bioms_name1{1},'Factors'))
                                        varQuest = ARSQfactors;
                                        if (length(varQuest.arsqLabels{i}) > 20)
                                            bs = varQuest.arsqLabels{i};
                                            [ab, cd] = strtok(bs(15:end));
                                            ad = length(ab);
                                            
                                            if nnz(isspace(cd)) == length(cd)
                                                title([num2str(i) '. ' bs(1:14 + ad)],'FontWeight','Bold');
                                            else
                                                title({[num2str(i) '. ' bs(1:14 + ad)], cd},'FontWeight','Bold');
                                            end
                                        else
                                            title([num2str(i) '. ' varQuest.arsqLabels{i}],'FontWeight','Bold');
                                        end
                                    else
                                        varQuest = ARSQfactors;
                                        if (length(varQuest.factorLabels{i}) > 20)
                                            bs = varQuest.factorLabels{i};
                                            [ab, cd] = strtok(bs(15:end));
                                            ad = length(ab);
                                            
                                            if nnz(isspace(cd)) == length(cd)
                                                title([num2str(i) '. ' bs(1:14 + ad)],'FontWeight','Bold');
                                            else
                                                title({[num2str(i) '. ' bs(1:14 + ad)], cd},'FontWeight','Bold');
                                            end
                                        else
                                            title([num2str(i) '. ' varQuest.factorLabels{i}],'FontWeight','Bold');
                                        end
                                    end
                                    
                                    origTitle = get(get(gca,'title'),'position');
                                    if (test_ind ~=2)
                                        text(-0.2,-1.2514,origTitle(3),'rho');
                                    else
                                        text(-0.2,-1.2514,origTitle(3),'\delta mean');
                                    end
                                    text(-3,-1.2514,origTitle(3),'P-value');
                                    origTitle(1) = -2.7;
                                    
                                    set(get(gca,'title'),'position',origTitle);
                                    
                                else
                                    axes;
                                    topoplot(log10(Pvalues(:,i)),G(1).chansregs.chanloc);
                                    xidd =  mod(idd-1,4);
                                    yidd = 4-(1 +floor((idd-1)/4));
                                    set(gca,'clim',[-2.6 0]);
                                    
                                    cbh = colorbar('WestOutside');
                                    oldCBH = get(cbh,'position');
                                    oldCBH(1) = 0.05+ (0.25 * xidd) + 0.01;
                                    oldCBH(2) = 0.05 + (0.25 * yidd);
                                    oldCBH(3) = 0.0086;
                                    oldCBH(4) = 0.1009;
                                    set(cbh,'position',oldCBH);
                                    set(cbh,'yTick',[-2 -1.3010 -1 0])
                                    set(cbh,'yTicklabel',[0.01 0.05 0.1 1])
                                    
                                    
                                    set(gca,'position',[0.05+ (0.25 * xidd) 0.05 + (0.25 * yidd) 0.1 0.1]);
                                    
                                    axes;
                                    topoplot(rho(:,i),G(1).chansregs.chanloc);
                                    set(gca,'clim',[-mxlim mxlim]);
                                    cbh = colorbar('EastOutside');
                                    oldCBH = get(cbh,'position');
                                    oldCBH(1) = 0.05+(0.25 * xidd)+0.15;
                                    oldCBH(2) =  0.05 + (0.25 * yidd);
                                    oldCBH(3) = 0.0086;
                                    oldCBH(4) = 0.1009;
                                    set(cbh,'position',oldCBH);
                                    
                                    set(gca,'position',[ 0.05+(0.25 * xidd)+0.07 0.05 + (0.25 * yidd) 0.1 0.1]);
                                    if isempty(strfind(bioms_name1{1},'Factors'))
                                        varQuest = ARSQfactors;
                                        if (length(varQuest.arsqLabels{i}) > 20)
                                            bs = varQuest.arsqLabels{i};
                                            [ab, cd] = strtok(bs(15:end));
                                            ad = length(ab);
                                            
                                            if nnz(isspace(cd)) == length(cd)
                                                title([num2str(i) '. ' bs(1:14 + ad)],'FontWeight','Bold');
                                            else
                                                title({[num2str(i) '. ' bs(1:14 + ad)], cd},'FontWeight','Bold');
                                            end
                                        else
                                            title([num2str(i) '. ' varQuest.arsqLabels{i}],'FontWeight','Bold');
                                        end
                                    else
                                        varQuest = ARSQfactors;
                                        if (length(varQuest.factorLabels{i}) > 20)
                                            bs = varQuest.factorLabels{i};
                                            [ab, cd] = strtok(bs(15:end));
                                            ad = length(ab);
                                            
                                            if nnz(isspace(cd)) == length(cd)
                                                title([num2str(i) '. ' bs(1:14 + ad)],'FontWeight','Bold');
                                            else
                                                title({[num2str(i) '. ' bs(1:14 + ad)], cd},'FontWeight','Bold');
                                            end
                                        else
                                            title([num2str(i) '. ' varQuest.factorLabels{i}],'FontWeight','Bold');
                                        end
                                    end
                                    
                                    origTitle = get(get(gca,'title'),'position');
                                    if (test_ind ~=2)
                                        text(-0.1,-origTitle(2),origTitle(3),'rho');
                                    else
                                        text(-0.1,-origTitle(2),origTitle(3),'\delta mean');
                                    end
                                    text(-1.4,-origTitle(2),origTitle(3),'P-value');
                                    origTitle(1) = -0.7;
                                    
                                    set(get(gca,'title'),'position',origTitle);
                                end
                            catch
                            end
                        end
                    end
                else
                    disp('ERROR:  THIS CODE IS NOT WORKING YET');
                    %             nbt_plotInsetTopo(([G(1).chansregs.chanloc.X;G(1).chansregs.chanloc.Y;G(1).chansregs.chanloc.Z]'),log10(Pvalues)',[-2.6 0]);
                    %             coolWarm = load('nbt_CoolWarm.mat','coolWarm');
                    %             coolWarm = coolWarm.coolWarm;
                    %             colormap(coolWarm);
                    %
                    %
                    %             mxlim = max([abs(max(max(rho))) abs(min(min(rho)))]);
                    %
                    %             nbt_plotInsetTopo(([G(1).chansregs.chanloc.X;G(1).chansregs.chanloc.Y;G(1).chansregs.chanloc.Z]'),rho',[-mxlim mxlim]);
                    %             coolWarm = load('nbt_CoolWarm.mat','coolWarm');
                    %             coolWarm = coolWarm.coolWarm;
                    %             colormap(coolWarm);
                end
            end
        end
    end
end
end

%%
function [B_values1,B_values2, bioms1,bioms2, Group1,Group2] = getCompareBiomarkerData(bioms_name1,bioms_name2,group_ind,StatObj)
%need-group_ind, Group
%returns - B_values1,2, bioms1,2, Group or Grop1,Grop2
%%  If more than one group then has to be paired and make sure that
%  both have the same subjects.
global NBTstudy

if length(group_ind) == 1
    
    Group1 = NBTstudy.groups{group_ind};
    
    bioms1 = bioms_name1;
    bioms2 = bioms_name2;
    nameG1 = Group1.groupName;
    
    Data1 = NBTstudy.groups{StatObj.groups(1)}.getData(StatObj); %with parameters);
    
    B1 = Data1.dataStore{1};
    B2 = Data1.dataStore{2};
    for j=1:size(Data1.dataStore{1})
        B_values1(:,j) = B1{j};
        B_values2(:,j) = B2{j};
    end
    
elseif length(group_ind) == 2
    
    Group1 = NBTstudy.groups{group_ind(1)};
    Group2 = NBTstudy.groups{group_ind(2)};
    bioms1 = bioms_name1;
    bioms2 = bioms_name2;
    
    bioms1 = bioms_name1;
    nameG1 = Group1.groupName;
    
    StudyObj = NBTstudy;
    
    %  Data1 = StudyObj.groups{StatObj.groups(group_ind(1))}.getData(StatObj); %with parameters);
    Data1 = StudyObj.groups{group_ind(1)}.getData(StatObj); %with parameters);
    
    
    G1B1 = Data1.dataStore{1};
    G1B2 = Data1.dataStore{2};
    for j=1:size(Data1.dataStore{1})
        B1_values1(:,j) = G1B1{j};
        B1_values2(:,j) = G1B2{j};
    end
    
    bioms2 = bioms_name2;
    nameG2 = Group2.groupName;
    
    %Data2 = StudyObj.groups{StatObj.groups(group_ind(2))}.getData(StatObj); %with parameters);
    Data2 = StudyObj.groups{group_ind(2)}.getData(StatObj); %with parameters);
    
    G2B1 = Data2.dataStore{1};
    G2B2 = Data2.dataStore{2};
    for j=1:size(Data2.dataStore{1})
        B2_values1(:,j) = G2B1{j};
        B2_values2(:,j) = G2B2{j};
    end
    
    try
        B_values1 = B1_values1-B2_values1;
        
    catch me
        disp('Failed due to unequal Sizes: Trying Pruning Questions')
        bothGroups = min(size(B1_values1,1),size(B2_values1,1));
        B_values1 = B1_values1(1:bothGroups,:)-B2_values1(1:bothGroups,:);
    end
    
    try
        B_values2 = B1_values2-B2_values2;
    catch me
        disp('Failed due to unequal Sizes: Trying Pruning Questions')
        bothGroups = min(size(B1_values2,1),size(B2_values2,1));
        B_values2 = B1_values2(1:bothGroups,:)-B2_values2(1:bothGroups,:);
    end
    
    
    
end

end
%%
function [B_values1, B_values2] = getCompareBiomarkerRegions(regs_or_chans_name,bioms_name1,bioms_name2,B_values1,B_values2,group_ind,StatObj)

if strcmp(regs_or_chans_name,'Regions')
    if isempty(strfind(bioms_name1{1},'Answers')) || isempty(strfind(bioms_name1{1},'values'))
        regions = G(group_ind(1)).chansregs.listregdata;
        for j = 1:size(B_values1,2) % subject
            
            B1 = B_values1(:,j);
            B_gebruik1(:,j) = nbt_compare_getRegions(B1,regions);
        end
        clear B_values1;
        B_values1 = B_gebruik1;
    end
    if isempty(strfind(bioms_name2{1},'Answers')) || isempty(strfind(bioms_name2{1},'values'))
        regions = G(group_ind(1)).chansregs.listregdata;
        for j = 1:size(B_values2,2) % subject
            B2 = B_values2(:,j);
            B_gebruik2(:,j) = nbt_compare_getRegions(B2,regions);
        end
        clear B_values2;
        B_values2 = B_gebruik2;
    end
else
    if strcmp(regs_or_chans_name,'Components')
        noComps = 6;
        if isempty(strfind(bioms_name1{1},'Answers')) || isempty(strfind(bioms_name1{1},'values'))
            if nnz(B_values1<0) > 0
                pcComps = pca(B_values1');
            else
                [pcComps,~] = nnmf(B_values1,noComps );
            end
            figure
            for i = 1:noComps
                x = sort(pcComps(:,i));
                spt =  x(floor(length(pcComps)*0.8));
                spts =pcComps(:,i);
                spts(spts<spt) = 0;
                spts(spts>=spt) = 1;
                subplot(2,3,i);
                topoplot(spts,G(1).chansregs.chanloc,'shading', 'flat');
                regions(i).reg.channel_nr = find(spts);
                regions(i).reg.name = ['Component ' i];
            end
            
            
            for j = 1:size(B_values1,2) % subject
                
                B1 = B_values1(:,j);
                B_gebruik1(:,j) = nbt_compare_getRegions(B1,regions);
            end
            clear B_values1;
            B_values1 = B_gebruik1;
        else
            if isempty(strfind(bioms_name2{1},'Answers')) || isempty(strfind(bioms_name2{1},'values'))
                if nnz(B_values2<0) > 0
                    pcComps = pca(B_values2');
                else
                    [pcComps,~] = nnmf(B_values2,noComps );
                end
                figure
                for i = 1:noComps
                    x = sort(pcComps(:,i));
                    spt =  x(floor(length(pcComps)*0.8));
                    spts =pcComps(:,i);
                    spts(spts<spt) = 0;
                    spts(spts>=spt) = 1;
                    subplot(2,3,i);
                    topoplot(spts,G(1).chansregs.chanloc,'shading', 'flat');
                    regions(i).reg.channel_nr = find(spts);
                    regions(i).reg.name = ['Component ' i];
                end
                regions = G(group_ind(1)).chansregs.listregdata;
                for j = 1:size(B_values2,2) % subject
                    B2 = B_values2(:,j);
                    B_gebruik2(:,j) = nbt_compare_getRegions(B2,regions);
                end
                clear B_values2;
                B_values2 = B_gebruik2;
            end
        end
    end
end
end

