function nbt_plotBoxplots(valuesGroup1,valuesGroup2,biom,G1name,G2name,subjectList1,subjectList2,p,biomTitle)
    % this plot is valid when using same subject with different
    % conditions--> this implies that groups have same sumber of subject
    figure();
    hold on
    
    % Clean up biomarker name
    biomTitle = cleanBiomarkerName(biomTitle);
    biom = cleanBiomarkerName(biom);
    
    title(biomTitle,'FontSize',16);
    
    sub1 = subjectList1;
    sub2 = subjectList2;
    
    % Convert single to double, otherwise issues with 'text' function
    G1 = double(valuesGroup1);
    G2 = double(valuesGroup2);
    
    if find(isnan(G1))
        warning('Group %s contains NaNs',G1name);
    end
    
    if find(isnan(G2))
        warning('Group %s contains NaNs',G2name);
    end
    
    % Paired or unpaired?
    % Check whether the groups have equal size
    % AND if the subjects in both groups are the same
    if size(G1,2) ~= size(G2,2) | ~eq(sub1,sub2)
        % Unpaired data
        
        % Plot the dots for each subject, but no lines
        % Group 1
        for subject = 1 : size(G1,2)
            plot(1.2,G1(subject));
            text(1.2,G1(subject),num2str(sub1(subject)),'fontsize',10,'horizontalalignment','right');
        end

        % Group 2
        for subject = 1 : size(G2,2)
            plot(1.8,G2(subject));
            text(1.8,G2(subject),num2str(sub2(subject)),'fontsize',10)
        end
        
        % Pad if unequal lengths, for plotting boxplots later on
        if size(G1,2) < size(G2,2)
            G1 = [G1 nan(1,size(G2,2)-size(G1,2))];
        elseif size(G2,2) < size(G1,2)
            G2 = [G2 nan(1,size(G1,2)-size(G2,2))];
        end
    else
        % Paired
        % Plot the dots and line for each subject
        for subject = 1 : size(G1,2)
            % Check whether difference is positive / negative / zero
            if G1(subject) < G2(subject)
                % Positive difference: red line
                plot([1.2 1.8],[G1(subject) G2(subject)],'LineWidth',2,'Color',[1 0 0]);
            elseif G2(subject) < G1(subject)
                % Negative difference: blue line
                plot([1.2 1.8],[G1(subject) G2(subject)],'LineWidth',2,'Color',[0 0 1]);
            else
                % No difference: black line
                plot([1.2 1.8],[G1(subject) G2(subject)],'LineWidth',2,'Color',[0 0 0]);
            end
            text(1.2,G1(subject),num2str(sub1(subject)),'fontsize',10,'horizontalalignment','right');
            text(1.8,G2(subject),num2str(sub2(subject)),'fontsize',10)
        end
    end
    
    % Store in same matrix to plot boxplots
    g(1,:) = G1;
    g(2,:) = G2;
    
    boxplot(g')
    hold on

    plot(1,nanmean(g(1,:)),'s','Markerfacecolor','k')
    plot(2,nanmean(g(2,:)),'s','Markerfacecolor','k')
    text(1.02,nanmean(g(1,:)),'Mean','fontsize',10)
    text(2.02,nanmean(g(2,:)),'Mean','fontsize',10)
    xlim([0.8 2.2])

    % Add 30% above and 10% below range of values for better
    % visualization
    range = max(g(:))-min(g(:));
    ylim([min(g(:))-0.1*range max(g(:))+0.35*range])
    set(gca,'Xtick', [1 2],'XtickLabel',{[G1name,' (n = ',num2str(sum(~isnan(g(1,:)))),')'];[G2name,' (n = ',num2str(sum(~isnan(g(2,:)))),')']},'fontsize',12,'fontweight','bold')
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
    
    
    function biomName = cleanBiomarkerName(biomName)
        try
            biomName = strrep(biomName,'NBTe nbt ','');
            biomName = strrep(biomName,'PeakFit','');
            biomName = strrep(biomName,'frequencyRange ','');
            biomName = strrep(biomName,'markerValues','');
            biomName = strrep(biomName,'MarkerValues','');
            biomName = strrep(biomName,'.',' ');
            biomName = strrep(biomName,'1  4','Delta');
            biomName = strrep(biomName,'4  8','Theta');
            biomName = strrep(biomName,'8  13','Alpha');
            biomName = strrep(biomName,'13  30','Beta');
            biomName = strrep(biomName,'30  45','Gamma');
            biomName = strrep(biomName,'  ',' ');
        catch
            disp('Could not clean up biomarker name.');
        end
    end
end