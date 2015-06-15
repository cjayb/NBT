function nbt_plotBiomarkerValues()
    electrodeData = get(gco,'UserData');
    electrodeName = electrodeData.electrodeName;
    biomarkerName = strrep(electrodeData.biomarkerName,'_',' ');
    
    figure()
    biomTitle = [biomarkerName ' for electrode ' electrodeName];
    title(biomTitle,'FontSize',16);
        
    if size(electrodeData.electrodeValues,2) == 1
        electrodeValues = electrodeData.electrodeValues{1};
        scatter(ones(1,length(electrodeValues)),electrodeValues,'filled');
        
        xlim([-0.5 1.5]);
        xlabel('\it{n}\rm = 4','interpreter','tex','FontSize',16);
        ylabel(biomarkerName,'FontSize',16);
    else
        electrodeValuesGrp1 = electrodeData.electrodeValues{1};
        electrodeValuesGrp2 = electrodeData.electrodeValues{2};
        plot_subj_vs_subj(electrodeValuesGrp1,electrodeValuesGrp2,biomarkerName,electrodeData.subjectList);
    end
    
    function plot_subj_vs_subj(elecValuesGroup1,elecValuesGroup2,biomarkerName,subjectList)
        % this plot is valid when using same subject with different
        % conditions--> this implies that groups have same sumber of subject
        
            G1name = 'G1';
            G2name = 'G2';
            
            sub1 = subjectList;
            sub2 = subjectList;
            
            %s = stat_results(biomarker);
            biom = biomarkerName;
            g(1,:) = elecValuesGroup1;
            g(2,:) = elecValuesGroup2;
            %pval = sprintf('%.4f',s.p(chan_or_reg));

            hold on
            
            for i = 1 : size(g,2)
                if g(1,i) < g(2,i)
                    plot([1.2 1.8],g(:,i),'LineWidth',2,'Color',[0 1 0]);
                elseif g(2,i) < g(1,i)
                    plot([1.2 1.8],g(:,i),'LineWidth',2,'Color',[1 0 0]);
                else
                    plot([1.2 1.8],g(:,i),'LineWidth',2,'Color',[0 0 0]);
                end
                    
                text(1.2,g(1,i),num2str(sub1(i)),'fontsize',10,'horizontalalignment','right')
                text(1.8,g(2,i),num2str(sub2(i)),'fontsize',10)
            end
            boxplot(g')
            hold on
            plot(1,mean(g(1,:)),'s','Markerfacecolor','k')
            plot(2,mean(g(2,:)),'s','Markerfacecolor','k')
            text(1.02,mean(g(1,:)),'Mean','fontsize',10)
            text(2.02,mean(g(2,:)),'Mean','fontsize',10)
            xlim([0.8 2.2])
            ylim([min(g(:))-0.1*min(g(:)) max(g(:))+0.1*max(g(:))])
            set(gca,'Xtick', [1 2],'XtickLabel',{[G1name,'(n = ',num2str(length(g(1,:))),')'];[G2name,'(n = ',num2str(length(g(1,:))),')']},'fontsize',12,'fontweight','bold')
            xlabel('')
            ylabel([regexprep(biom,'_',' ')],'fontsize',12,'fontweight','bold')
    end
end