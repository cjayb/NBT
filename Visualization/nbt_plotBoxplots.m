function nbt_plotBoxplots(valuesGroup1,valuesGroup2,biomarkerName,G1name,G2name,subjectList1,subjectList2,p,biomTitle)
    % this plot is valid when using same subject with different
    % conditions--> this implies that groups have same sumber of subject
    figure();
        title(biomTitle,'FontSize',16);
        
        sub1 = subjectList1;
        sub2 = subjectList2;

        %s = stat_results(biomarker);
        biom = biomarkerName;
        g(1,:) = valuesGroup1;
        g(2,:) = valuesGroup2;
        %pval = sprintf('%.4f',s.p(chan_or_reg));

        % SH: Convert back to double, otherwise issues with 'text'
        % function
        g = double(g);

        hold on

        for i = 1 : size(g,2)
            if isnan(g(1,i)) | isnan(g(2,i))
                warning('There are NaNs in your data, check your data!');
            else
                if isequal(sub1,sub2)
                    % Data are paired
                    if g(1,i) < g(2,i)
                        plot([1.2 1.8],g(:,i),'LineWidth',2,'Color',[1 0 0]);
                    elseif g(2,i) < g(1,i)
                        plot([1.2 1.8],g(:,i),'LineWidth',2,'Color',[0 0 1]);
                    else
                        plot([1.2 1.8],g(:,i),'LineWidth',2,'Color',[0 0 0]);
                    end
                end
                text(1.2,g(1,i),num2str(sub1(i)),'fontsize',10,'horizontalalignment','right')
                text(1.8,g(2,i),num2str(sub2(i)),'fontsize',10)
            end
        end
        boxplot(g')
        hold on
        plot(1,mean(g(1,:)),'s','Markerfacecolor','k')
        plot(2,mean(g(2,:)),'s','Markerfacecolor','k')
        text(1.02,mean(g(1,:)),'Mean','fontsize',10)
        text(2.02,mean(g(2,:)),'Mean','fontsize',10)
        xlim([0.8 2.2])

        % Add 30% above and 10% below range of values for better
        % visualization
        range = max(g(:))-min(g(:));
        ylim([min(g(:))-0.1*range max(g(:))+0.35*range])
        set(gca,'Xtick', [1 2],'XtickLabel',{[G1name,' (n = ',num2str(length(g(1,:))),')'];[G2name,' (n = ',num2str(length(g(1,:))),')']},'fontsize',12,'fontweight','bold')
        xlabel('')
        ylabel([regexprep(biom,'_',' ')],'fontsize',12,'fontweight','bold')

        % Add significance bar above boxplots
        if ~isempty(p)
            plot([1.2 1.8], [max(g(:))+0.15*range max(g(:))+0.15*range],'LineWidth',2,'Color',[0 0 0]);
            plot([1.2 1.2], [max(g(:))+0.13*range max(g(:))+0.15*range],'LineWidth',2','Color',[0 0 0]);
            plot([1.8 1.8], [max(g(:))+0.13*range max(g(:))+0.15*range],'LineWidth',2','Color',[0 0 0]);

            if p <= 1E-3
                stars = '***'; 
            elseif p <= 1E-2
                stars = '**';
            elseif p <= 0.05
                stars = '*';
            elseif isnan(p)
                stars = 'n.s.';
            else p > 0.05
                stars = 'n.s.';
            end

            if strcmp(stars,'n.s.')
                text(1.46, max(g(:))+0.20*range,stars,'FontSize',14);
            else
                text(1.5, max(g(:))+0.17*range,stars,'FontSize',16);
            end

            text(2.1, max(g(:))+0.25*range,['p-value: ', num2str(p)],'FontSize',12,'horizontalalignment','right');
        end
end