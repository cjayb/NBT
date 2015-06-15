function  nbt_Print(NBTstudy, groupIndex)

% 1. Run statistics
%nbt_runStatistics(1);

% 2. Statistics object
StatObj = NBTstudy.statAnalysis{end};

% 3. Get name and data for group
Group = NBTstudy.groups{groupIndex};
groupName = Group.groupName;
DataGroup = getData(Group,StatObj);



%%% Biomarker sorting

% To optimize we we perform the biomarker sorting only once if the
% stat_results struct hasn't been updated.
%-------------------------------------------------------------------------
% try
%     stat_update=evalin('base','stat_update');
% catch
%     error('stat_update not found!');%stat_update is not necessary for
%     %     proper function but its absence most likely indicates error in
%     %     nbt_selectrunstatistics
% end
% try
%     sort_nfo=evalin('base','sort_nfo');
% catch
%     sort_nfo.update=0;
%     sort_nfo.group='';
% end


%-------------------------------------------------------------------------
%Performs check IF STAT_RESULTS has been MODIFIED since the previous
%Visualization initalization OR if the GROUP changed.
%stat_results=evalin('base','stat_results');
%G=evalin('base','G');

%if ~((stat_update<sort_nfo.update)&&(strcmp(sort_nfo.group,group_name)))

    disp('Default frequency bands');
    disp('Delta = [1,4];')
    disp('Theta = [4,8];')
    disp('Alpha = [8,13];')
    disp('Beta = [13,30];')
    disp('Gamma = [30,45];')
    
    temp=input('Declare own frequency bands?[y/n]: ','s');
    if strcmp(temp,'y')
        Delta = (input('Specify Delta [lowF highF]: '));
        Theta = (input('Specify Theta [lowF highF]: '));
        Alpha = (input('Specify Alpha [lowF highF]: '));
        Beta = (input('Specify Beta [lowF highF]: '));
        Gamma = (input('Specify Gamma [lowF highF]: '));
    else
        Delta = [1,4];
        Theta = [4,8];
        Alpha = [8,13];
        Beta = [13,30];
        Gamma = [30,45];
    end
    sort_nfo.update = now;
    sort_nfo.group = groupName;

    assignin('base','sort_nfo',sort_nfo);
    [namind, zindex, biom, pzindex] = nbt_PrintSort(StatObj, Delta, Theta, Alpha, Beta, Gamma, groupName);

    assignin('base','namind',namind);%Name index, used to sort so that it

    % follows order defined in nbt_PrintSort
    assignin('base','zindex',zindex);%index that points to stat_results (for z-scores)
    assignin('base','biom',biom);%biomarker names
    assignin('base','pzindex',pzindex);%index that points to stat_results (for t-tests)
% else %loading data that's been sorted previously
%    namind=evalin('base','namind');
%    zindex=evalin('base','zindex');
%    biom=evalin('base','biom');
%    pzindex=evalin('base','pzindex');
%end



%% Check if any z-scores and t-tests were found in stat_results
if isempty(zindex)
    error('Z-score not found in stat_results.')
elseif isempty(pzindex) && (~isempty(G(group_ind).group_difference))

error('T-tests not found in stat_results.')
elseif (length(pzindex)~=length(zindex)) && (~isempty(G(group_ind).group_difference))
    error('Z-score and t-tests not defined for the same biomarkers.')
end


%% nbt Print visualization OPTIONS
waitfor(VizQuerry);
if ~isempty(G(group_ind).group_difference)
    prompt = {'Alpha sig. threshold:'}; dlg_title = 'Alpha'; num_lines = 1; def = {'0.05'};
    alpha = str2double(inputdlg(prompt,dlg_title,num_lines,def));
end
switch DATA_TYPE
    case {'zscore','raw'}
        if isempty(G(group_ind).group_difference)
            allindex =listdlg('Liststring',cellstr(char(G(group_ind).fileslist(:).name)),'SelectionMode' ,'multiple','ListSize',[220,300],'Name','NBT print','promptstring','Select subject for NBT print');
        elseif ~isempty(G(group_ind).group_difference)
            allindex =listdlg('Liststring',cellstr(char(G(group_ind).fileslist(1:end/2).name)),'SelectionMode' ,'multiple','ListSize',[220,300],'Name','NBT print','promptstring','Select subject for NBT print');
        end
    case 'mean'
        allindex=1;
end
switch VIZ_LAYOUT
    case 'dflt'
        omega=50;%max amount of defined biomarkers UPDATE from nbt_PrintSort
        missing=setdiff([1:omega],namind);
        namind=[namind,missing];
        biom=[biom;cell(length(missing),1)];
        
        [B,I]=sort(namind);
        zindex=[zindex,missing];
        zindex=zindex(I);
        
        if isempty(G(group_ind).group_difference) && isempty(pzindex)
            pzindex = [];
        else
            pzindex=[pzindex,missing];
            pzindex=pzindex(I);
        end
        
        biom=cellstr(char(biom{I}));
    case 'cstm'
        missing=[];
        [B,I]=sort(namind);
        zindex=zindex(I);
        if isempty(G(group_ind).group_difference) && isempty(pzindex)
            pzindex = [];
        else
            pzindex=pzindex(I);
        end
        biom=cellstr(char(biom{I}));
end
if ~isempty(G(group_ind).group_difference) && isempty(pzindex)
    error('T-test need to be computed to visualize a group difference.')
end

%% DISPLAYING THE RESULTS
for dingus=1:numel(allindex);
    index=allindex(dingus);%cycles through the subjects & selects right one
    pages=ceil(length(zindex)/25);
    fgh=[];
    for iotta=0:pages-1
        if length(zindex)-iotta*25>25
            perpage=25;
        elseif length(zindex)-iotta*25<=25
            perpage=length(zindex)-iotta*25;
        end
        %% Generates a new figure for each page defined by iotta
        switch DATA_TYPE
            case {'zscore','raw'}
                fgh(end+1)=figure('name',['NBT print of ',char(G(group_ind).fileslist(index).name)],'NumberTitle','on');
            case 'mean'
                if length(stat_results(1,1).group_ind)>1 % there are two groups
                    fgh(end+1)=figure('name',['Mean of  ', char(stat_results(1,1).group_name{1,1}), '-', char(stat_results(1,1).group_name{2,1})],'NumberTitle','off');
                else
                    fgh(end+1)=figure('name',['Mean of  ',char(group_name)],'NumberTitle','off');
                end
        end
       
        
        xSize =27; ySize = 19.;
        xLeft = (30-xSize)/2; yTop = (21-ySize)/2;
        set(gcf,'PaperPosition',[xLeft yTop xSize ySize]);
        set(gcf,'Position',[0 0 xSize*50 ySize*50]);
        
        for i=(1+(iotta)*25):1:(1+(iotta)*25)+perpage-1
            % Loads p-vals when there is a group difference
            if ~isempty(G(group_ind).group_difference) && ~isempty(char(biom(i)))
                sig_biom=find(stat_results(1,pzindex(i)).p<alpha);
            else
                sig_biom=[];
            end
            
            %% LOADS DATA TO BE VISUALIZED IN SUBPLOT
            switch DATA_TYPE     
                case 'zscore'
                    if ~isempty(char(biom(i)))%length(stat_results)>=zindex(i)
                    %    if (size(stat_results(1,1).group_name,1)>1) % 2 groups
                    %        biomholder=stat_results(1,zindex(i)).vals1(:,index);
                    %    else
                            biomholder=stat_results(1,zindex(i)).vals(:,index);
                    %    end
                    elseif isempty(char(biom(i)))
                        biomholder=zeros(size(G(1).chansregs.chanloc)).';
                    end
                    if(isempty(sig_biom))
                        %0.05 significance level for z-score is 1.96
                        %(two-tail)
                        p = 2*(1-normcdf(abs(biomholder),0,1));
                        sig_biom = nbt_MCcorrect(p,'bino');
                    end
                case 'mean'




%                     if ~isempty(char(biom(i)))
%                         if (size(stat_results(1,1).group_name,1)>1) % 2 groups
%                             
%                            biomholder=stat_results(1,zindex(i)).mu1-stat_results(1,zindex(i)).mu;
%                         else
%                         biomholder=stat_results(1,zindex(i)).mu;
%                         end
%                     elseif isempty(char(biom(i)))
%                         biomholder=zeros(size(G(group_ind).chansregs.chanloc)).';
%                     end


                    if ~isempty(char(biom(i)))
                        if (size(StatObj.groups) > 1)
                            % There are (at least) 2 groups, subtract the means
                            biomholder = meanGroup2 - meanGroup1;
                        else
                            % 1 group
                            biomholder = meanGroup;
                        end
                    elseif isempty(char(biom(i)))
                        biomholder = zeros(size(chanLocs));
                    end



                case 'raw'% In the future, replace this with proper data loading
                    if ~isempty(char(biom(i)))
                    %    if (size(stat_results(1,1).group_name,1)>1) % 2 groups
                    %        biomholder=(stat_results(1,zindex(i)).vals1(:,index).*stat_results(1,zindex(i)).sigma)+stat_results(1,zindex(i)).mu;
                    %    else
                            biomholder=(stat_results(1,zindex(i)).vals(:,index).*stat_results(1,zindex(i)).sigma)+stat_results(1,zindex(i)).mu;
                    %    end
                    elseif isempty(char(biom(i)))
                        biomholder=zeros(size(G(group_ind).chansregs.chanloc)).';
                    end
            end
            switch VIZ_SIG
                case 'sig'
                    if ~isempty(sig_biom)
                        biomholder(setdiff(1:numel(biomholder),sig_biom))=NaN;
                        sig_biom=[];
                    else
                        biomholder=zeros(size(G(group_ind).chansregs.chanloc)).';
                    end
            end
            %Check if all biomarker vals are NaN, which often happens for
            % alpha and beta peak frequencies
            if any(~isnan(biomholder))==0
                sig_biom=[];
                biomholder=zeros(size(G(group_ind).chansregs.chanloc)).';
            end
            
%             subaxis(1+ceil(perpage/5),5,6+mod(i-1,25), 'Spacing', 0.03, 'Padding', 0, 'Margin', 0)
            subaxis(6,5,6+mod(i-1,25), 'Spacing', 0.03, 'Padding', 0, 'Margin', 0)
            if size(biomholder,1)==length(G(group_ind).chansregs.channel_nr)
%                 coolWarm = load('nbt_CoolWarm.mat','coolWarm');
             %   coolWarm =load('nbt_GoldenBrown.mat','cdata');
                %                 coolWarm = load('nbt_CoolWarmWhite.mat');
              %  coolWarm=coolWarm.cdata;
               % if ~isempty(G(group_ind).group_difference) && ~strcmp(DATA_TYPE,'zscore')
                %    coolWarm=flipud(coolWarm);
                %end
               % colormap(coolWarm);
%                 load nbt_zscorecolormap
%                 colormap(flipud(nbt_zscorecolormap))
% colormap('cool')
colormap('HSV')
% colormap('Jet')
% load nbt_BlueWhiteRed
% colormap(nbt_BlueWhiteRed)
% load nbt_colormapContourBlueRed
% colormap(nbt_colormapContourBlueRed)
% load nbt_colormapContourWhiteRed
% colormap(nbt_colormapContourWhiteRed)
% load nbt_colormapP
% colormap(nbt_colormapP)
% load nbt_colortmapP
% colormap(nbt_colortmapP)
% load nbt_colortmap2
% colormap(nbt_colortmap2)
% load nbt_CoolWarm
% colormap(coolWarm)
% load nbt_CoolWarmBlack
% colormap(coolWarmBlack)
% load nbt_CoolWarmWhite
% colormap(coolWarmWhite)
% load nbt_DarkBlueWhiteDarkRed
% colormap(nbt_DarkBlueWhiteDarkRed)
% load nbt_DarkBlueWhiteDarkRedSharp
% colormap(nbt_DarkBlueWhiteDarkRedSharp)
% load nbt_GoldenBrown
% colormap(cdata)
% load nbt_InvCoolWarm
% colormap(nbt_InvCoolWarm)
% load nbt_redwhite
% colormap(nbt_redwhite)
% load nbt_zscorecolormap
% colormap(nbt_zscorecolormap)

                figure(fgh(end));
                modplot(biomholder',G(group_ind).chansregs.chanloc,'headrad','rim','emarker2',{sig_biom,'o','w',6,2},'maplimits',[-3 3],'style','map');
                set(gca, 'LooseInset', get(gca,'TightInset'));
                
                switch DATA_TYPE
                    case 'mean'
                        if  any(biomholder~=0)
                        cbar=colorbar('location','west');
                        posish=get(cbar,'position');
                        set(cbar,'position',[0.14+mod(i-1,5)*.205,posish(2),0.01,posish(4)+.2*posish(4)],'fontsize',7);
                         caxis([min(stat_results(1,zindex(i)).mu(~isnan(stat_results(1,zindex(i)).mu))),max(stat_results(1,zindex(i)).mu(~isnan(stat_results(1,zindex(i)).mu)))]);
                        if isfield(stat_results(1,zindex(i)),'unit')&& ~isempty( stat_results(1,zindex(i)).unit)
                            set(get(cbar,'title'),'String', stat_results(1,zindex(i)).unit);
                        end
                        else
%                             cbar=colorbar('location','west');
%                             posish=get(cbar,'position');
%                             set(cbar,'position',[0.14+mod(i-1,5)*.205,posish(2),0.01,posish(4)+.2*posish(4)],'fontsize',7);
%                            if ~isempty( stat_results(1,zindex(i)).unit)
%                                 set(get(cbar,'title'),'String', stat_results(1,zindex(i)).unit);
%                            end
                        end 
                    case 'raw'
                        if  any(biomholder~=0)
                            cbar=colorbar('location','west');
                            posish=get(cbar,'position');
                            set(cbar,'position',[0.14+mod(i-1,5)*.205,posish(2),0.01,posish(4)+.2*posish(4)],'fontsize',7);
                             caxis([min(stat_results(1,zindex(i)).mu(~isnan(stat_results(1,zindex(i)).mu))),max(stat_results(1,zindex(i)).mu(~isnan(stat_results(1,zindex(i)).mu)))]);
                            if isfield(stat_results(1,zindex(i)),'unit')&& ~isempty( stat_results(1,zindex(i)).unit)
                                set(get(cbar,'title'),'String', stat_results(1,zindex(i)).unit);
                            end
                        else
                            %                             cbar=colorbar('location','west');
                            %                             posish=get(cbar,'position');
                            %                             set(cbar,'position',[0.14+mod(i-1,5)*.205,posish(2),0.01,posish(4)+.2*posish(4)],'fontsize',7);
%                            if ~isempty( stat_results(1,zindex(i)).unit)
                                %                                 set(get(cbar,'title'),'String', stat_results(1,zindex(i)).unit);
%                            end
                        end
                end
            elseif size(biomholder,1)==length(G(stat_results(zindex(i)).group_ind(1)).chansregs.channel_nr)^2
                ThisLineIsLong=reshape(biomholder,length(G(stat_results(zindex(i)).group_ind(1)).chansregs.channel_nr),length(G(stat_results(zindex(i)).group_ind(1)).chansregs.channel_nr));
             %   bh=imagesc(ThisLineIsLong,[-3,3]);
             load nbt_CoolWarmBlack
             colormap(coolWarmBlack)
             ds.chanPairs =[];
           %  ds.connectStrength = [];
             plotconnect = 0;
             for m1=1:size(ThisLineIsLong,1)
                for m2=m1:size(ThisLineIsLong,2)
                    if(abs(ThisLineIsLong(m1,m2)) > 5)
                        ds.chanPairs = [ds.chanPairs; m1 m2];
                       % ds.connectStrength = [ds.connectStrength; ThisLineIsLong(m1,m2)];
                        plotconnect = 1;
                    end
                end
             end 
             if(plotconnect)
                topoplot_connect(ds, G(1).chansregs.chanloc);
                set(gca, 'LooseInset', get(gca,'TightInset'));
             end
                colorbar('off')
            %    coolWarm = load('nbt_CoolWarm.mat','coolWarm');
            %    coolWarm = coolWarm.coolWarm;
             %   colormap([1,1,1;coolWarm]);
                load nbt_zscorecolormap
                colormap(flipud(nbt_zscorecolormap))
               % axis off tight square;
                set(gca, 'LooseInset', get(gca,'TightInset'));
                switch DATA_TYPE
                    case {'mean','raw'}
                        cbar=colorbar('location','west');
                        posish=get(cbar,'position');
                        set(cbar,'position',[0.14+mod(i-1,5)*.205,posish(2),0.01,posish(4)+.35*posish(4)],'fontsize',7);
%                         caxis([min(stat_results(1,zindex(i)).mu(~isnan(stat_results(1,zindex(i)).mu))),max(stat_results(1,zindex(i)).mu(~isnan(stat_results(1,zindex(i)).mu)))]);
                        if isfield(stat_results(1,zindex(i)),'unit')&& ~isempty( stat_results(1,zindex(i)).unit)
                            set(get(cbar,'title'),'String', stat_results(1,zindex(i)).unit,'interpreter','tex');
                        end
                end
            end
            switch DATA_TYPE
                case {'mean','raw'}
                    if (min(biomholder)>0)
                        cbar_limit=get(cbar,'ylim');
                        set(cbar,'ylim',[0,cbar_limit(2)]);
                    elseif (max(biomholder)<0)
                        cbar_limit=get(cbar,'ylim');
                        set(cbar,'ylim',[cbar_limit(1),0]);
                    end
            end
            %% PLOTTING FREQUENCY BANDS ABOVE THE TOP ROW
            % omega is the # index of the last pre-defined biomarker
            switch VIZ_LAYOUT
                case 'dflt'
                    if mod(i,25)==1 && i<= omega;
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
                        title (biom{i},'FontSize',9,'interpreter','tex');
                    end
                case 'cstm'
                    title (biom{i},'FontSize',9,'interpreter','tex')
            end
        end
        % Colorbar right alignment
        switch DATA_TYPE
            case 'zscore'
                caxis([-3,3])
                cb = colorbar('location','WestOutside','position',[1-0.02,0.41,0.007,1/6]);
                set(get(cb,'title'),'String','Z','interpreter','tex');
        end
        set(gca,'fontsize',8)
        ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        switch DATA_TYPE
            case 'zscore'
                if length(stat_results(1,1).group_ind)>1 % there are two groups
                    group2=strtrim(regexprep(stat_results(1,1).group_name{2,1},'Group \d : ',''));
                    text(0.85,0.9,['Relative Z-SCORES based on ',int2str(length(G(group_ind).fileslist)/2),' subject pairs from ', group2 ,', with ref. electrode ',G(1,1).chansregs.chanloc(1,1).ref],'horizontalalignment','right','FontSize',14,'Interpreter','tex');
                else
                    if ~isempty(G(group_ind).group_difference)
                    text(0.85,0.9,['Z-SCORE based on ',int2str(length(G(group_ind).fileslist)/2),' subject pairs with ref. electrode ',G(1,1).chansregs.chanloc(1,1).ref],'horizontalalignment','right','FontSize',14,'Interpreter','tex');
                else
                    text(0.85,0.9,['Z-SCORE based on ',int2str(length(G(group_ind).fileslist)),' subjects with ref. electrode ',G(1,1).chansregs.chanloc(1,1).ref],'horizontalalignment','right','FontSize',14,'Interpreter','tex');
                    end
                end
            case 'mean'
                if length(stat_results(1,1).group_ind)>1 % there are two groups
                    group1=strtrim(regexprep(stat_results(1,1).group_name{1,1},'Group \d : ',''));
                    group2=strtrim(regexprep(stat_results(1,1).group_name{2,1},'Group \d : ',''));
                    text(0.85,0.9,['Average difference between ', group1 ,' and ', group2, ', with ref. electrode ',G(1,1).chansregs.chanloc(1,1).ref],'horizontalalignment','right','FontSize',14,'Interpreter','tex');
                else
                    if ~isempty(G(group_ind).group_difference)
                     text(0.85,0.9,['Average of ',int2str(length(G(group_ind).fileslist)/2),' subject pairs with ref. electrode ',G(1,1).chansregs.chanloc(1,1).ref],'horizontalalignment','right','FontSize',14,'Interpreter','tex');
                 else
                     text(0.85,0.9,['Average of ',int2str(length(G(group_ind).fileslist)),' subjects with ref. electrode ',G(1,1).chansregs.chanloc(1,1).ref],'horizontalalignment','right','FontSize',14,'Interpreter','tex');
                    end
                end
            case 'raw'
                text(0.85,0.9,['Raw data with  ref. electrode ',G(1,1).chansregs.chanloc(1,1).ref],'horizontalalignment','right','FontSize',14,'Interpreter','tex');
        end
        switch DATA_TYPE
            case 'mean'
                if length(stat_results(1,1).group_ind)>1 % there are two groups
                    group1=strtrim(regexprep(stat_results(1,1).group_name{1,1},'Group \d : ',''));
                    group2=strtrim(regexprep(stat_results(1,1).group_name{2,1},'Group \d : ',''));
                    text(0.5, 0.99,strcat('NBT print for groups ',{' '}, group1 ,' and ',{' '}, group2),'HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',18,'Interpreter','tex');
                else
                    group_name=strtrim(regexprep(group_name,'Group \d : ',''));
                text(0.5, 0.99,strcat('NBT print for group ',{' '},group_name),'HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',18,'Interpreter','tex');
                end
             otherwise
                text(0.5, 0.99,['NBT print for ',regexprep(G(group_ind).fileslist(index).name,'_analysis.mat',' ')],'HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',18,'Interpreter','tex');
        end
        switch VIZ_LAYOUT
            case 'dflt'
                if iotta==0
                    get(gcf,'CurrentAxes');
                    ABSAMP = text(0.02,9/12, 'Relative','horizontalalignment', 'center');
                    set(ABSAMP,'rotation',90);
                    get(gcf,'CurrentAxes');
                    RELAMP= text(0.02,7/12, 'Absolute','horizontalalignment', 'center');
                    set(RELAMP,'rotation',90);
                    get(gcf,'CurrentAxes');
                    DFA= text(0.02,5/12, 'DFA','horizontalalignment', 'center');
                    set(DFA,'rotation',90);
                    get(gcf,'CurrentAxes');
                    CENTRAL= text(0.02,3/12, 'Central Freq.','horizontalalignment', 'center');
                    set(CENTRAL,'rotation',90);
                    get(gcf,'CurrentAxes');
                    LIFETIME= text(0.02,1/12, 'Lifetime','horizontalalignment', 'center');
                    set(LIFETIME,'rotation',90);
                elseif iotta==1;
                    get(gcf,'CurrentAxes');
                    ABSAMP = text(0.02,9/12, 'Bandwidth','horizontalalignment', 'center');
                    set(ABSAMP,'rotation',90);
                    get(gcf,'CurrentAxes');
                    RELAMP= text(0.02,7/12, 'Spectral edge','horizontalalignment', 'center');
                    set(RELAMP,'rotation',90);
                    get(gcf,'CurrentAxes');
                    DFA= text(0.02,5/12, 'Amplitude Correlations','horizontalalignment', 'center');
                    set(DFA,'rotation',90);
                    get(gcf,'CurrentAxes');
                    CENTRAL= text(0.02,3/12, 'Coherence','horizontalalignment', 'center');
                    set(CENTRAL,'rotation',90);
                    get(gcf,'CurrentAxes');
                    LIFETIME= text(0.02,1/12, 'PhaseLock PLV','horizontalalignment', 'center');
                    set(LIFETIME,'rotation',90);
                end
            case 'cstm'
        end
        %         switch printoptions
        %             case 'pdf'
%                         set(gcf,'PaperPosition',[xLeft yTop xSize ySize]);
%                         set(gcf,'PaperOrientation','landscape');
%                         genericname=['NBTprint_',regexprep(regexprep(G(group_ind).fileslist(index).name,'_analysis.mat',' '),'\.','_'),'_page',num2str(iotta+1),'.pdf'];
%                         print(gcf, '-dpdf','-r300', genericname);
        %
        %             case 'eps'
        %                 genericname=['NBTprint_',regexprep(regexprep(G(group_ind).fileslist(index).name,'_analysis.mat',' '),'\.','_'),'_page',num2str(iotta+1),'.eps'];
        %                 saveas(h,genericname,'eps')
        %             case 'jpg'
        %                 set(gcf,'PaperPosition',[xLeft yTop xSize ySize]);
        %                 set(gcf,'PaperOrientation','landscape');
        %                 genericname=['NBTprint_',regexprep(regexprep(G(group_ind).fileslist(index).name,'_analysis.mat',' '),'\.','_'),'_page',num2str(iotta+1),'.jpg'];
        %                 print(gcf, '-djpeg','-r600', genericname);
        %             otherwise
        %                 printdlg();  %#ok<MCPRD>
        %         end
        %         close(gcf);
    end
end
end

