function nbt_pvaluesmatrix(StatObj)
global NBTstudy
    
    % ---------compare p-values test results
    x = nan(size(StatObj.pValues{1},2),size(StatObj.pValues,2));
    for n = 1:size(StatObj.pValues,2)
        x(:,n)  = log10(StatObj.pValues{n})';
    end
    y =  x;
    
    h1 = figure('Visible','off');
    ah=bar3(y);
    h2 = figure('Visible','on','numbertitle','off','Name',['p-values of biomarkers for ', StatObj.testName],'position',[10          80       1700      500]);
    %--- adapt to screen resolution
    nbt_movegui(h2);
    %---
    hh  = uicontextmenu;
    hh2 = uicontextmenu;
    bh  = bar3(x);
    for i=1:length(bh)
        zdata = get(ah(i),'Zdata');
        set(bh(i),'cdata',zdata);
    end
    axis tight
    %     axis image
    %     zlabel('mean difference')
    %     axis off
    grid off
    view(-90,-90)
    colorbar('off')
    coolWarm = load('nbt_CoolWarm.mat','coolWarm');
    coolWarm = coolWarm.coolWarm;
    colormap(coolWarm);
    cbh = colorbar('EastOutside');
    minPValue = -2.6;%min(zdata(:));% Plot log10(P-Values) to trick colour bar
    maxPValue = 0;%max(zdata(:));
    caxis([minPValue maxPValue])
    set(cbh,'YTick',[-2 -1.3010 -1 0])
    set(cbh,'YTicklabel',{' 0.01', ' 0.05', ' 0.1', ' 1'}) %(log scale)
    set(cbh,'XTick',[],'XTickLabel','')
    %     set(get(cbh,'title'),'String','p-values','fontsize',8,'fontweight','b
    %     old');
    DeltaC = (maxPValue-minPValue)/20;
    pos_a = get(gca,'Position');
    %     pos = get(cbh,'Position');
    set(cbh,'Position',[1.5*pos_a(1)+pos_a(3) pos_a(2)+pos_a(4)/3 0.01 0.3 ])
    Pos=get(cbh,'position');
    set(cbh,'units','normalized');
    %         uic=uicontrol('style','slider','units','normalized','position',[Pos(1)-0.015*Pos(1) Pos(2) 0.01 0.3 ],...
    %         'min',minPValue,'max',maxPValue-DeltaC,'value',minPValue,...
    %         'callback',{@Slider_fun,DeltaC,Pos,maxPValue,bh});
    
    biomarkerNames = StatObj.getBiomarkerNames;
    switch StatObj.channelsRegionsSwitch
        case 1 %channels
            for i = 1:length(biomarkerNames)
                umenu = text(i,-10, biomarkerNames{i},'horizontalalignment','left','fontsize',10,'fontweight','bold');
                set(umenu,'uicontextmenu',hh);
            end
            set(gca,'YTick',1:5:size(y,1))
            set(gca,'YTickLabel',1:5:size(y,1),'Fontsize',10)
            set(gca,'XTick',[])
            set(gca,'XTickLabel','','Fontsize',10)
            ylabel('Channels')
        case 2 %regions  
            for i = 1:length(biomarkerNames)
                umenu = text(i,-0.3,biomarkerNames{i},'horizontalalignment','left','fontsize',10,'fontweight','bold');
                set(umenu,'uicontextmenu',hh);
            end
            for i= 1:size(x,1)
                text(size(x,2)+0.5,i, regexprep(regs(i).reg.name,'_',' '),'verticalalignment','base','fontsize',10,'rotation',-30,'fontweight','bold');
            end
            set(gca,'XTick',[])
            set(gca,'XTickLabel','','Fontsize',10)
            set(gca,'YTick',[])
            set(gca,'YTickLabel','','Fontsize',10)
            ylabel('Regions')
    end
    set(bh,'uicontextmenu',hh2);
    title(['p-values of biomarkers for ', StatObj.testName, ' for ''', NBTstudy.groups{StatObj.groups(1)}.groupName,''' vs ''', NBTstudy.groups{StatObj.groups(2)}.groupName ,''''],'fontweight','bold','fontsize',12)
    
    %uimenu(hh,'label','Plot topoplot','callback',{@plot_test2Groups,x,StatObj,regs,Group1,Group2});
    %uimenu(hh2,'label','Plot boxplot','callback',{@plot_subj_vs_subj,x,stat_results,regs,Group1,Group2,regs_or_chans_name});
    %uicontrol(h2, 'Style', 'pushbutton', 'string', 'Plot topoplots of all biomarkers', 'position', [20 400 200 20],'callback',{@plot_test2GroupsAll,x, stat_results, regs, Group1, Group2});
    close(h1)
    %nbt_plotMCcorrection(s,stat_results,bioms_name,nameG1,nameG2); 
end

 function plot_test2Groups(d1,d2,x,StatObj,regs,Group1,Group2)
        pos_cursor_unitfig = get(gca,'currentpoint');
        biomarker = round(pos_cursor_unitfig(1,1));
        if  biomarker>0 && biomarker<= size(x,2)
            s = stat_results(biomarker);
            chanloc = Group1.chansregs.chanloc;
            biom = s.biom_name;
            unit = s.unit;
            nbt_plot_2conditions_topo(StatObj);
        end
        %
 end

    
     function plot_test2GroupsAll(d1,d2,x,stat_results,regs,Group1,Group2)
        %This function plots full overview of all biomarkers
        fontsize = 10;
        fig1 = figure('name',['NBT: Statistics (Channels) for all selected biomarkers'],...
            'NumberTitle','off','position',[10          80       1500      500]); %128
        fig1=nbt_movegui(fig1);
        hold on;
        NR_Biomarkers = length(stat_results);
        for biomIndex = 1:NR_Biomarkers
            %FIXME
            s = stat_results(biomIndex);
            biom = s.biom_name;
            unit = s.unit;
            nbt_plot_2conditions_topoAll(Group1, Group2, Group1.chansregs.chanloc,s,unit,biom,biomIndex, NR_Biomarkers);
        end
    end