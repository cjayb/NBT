function nbt_plotBoxplot(StatObj,bID,chID)

global NBTstudy
load Questions

% We plotting three Figures
h4 = figure('Visible','on','numbertitle','off','Name',[StatObj.data{1}.biomarkers{bID} ' values for item ' num2str(chID) ' for each subjects'],'Position',[1000   200   350   700]);
h4 = nbt_movegui(h4);
hold on

g = [StatObj.data{1}(bID,chID) StatObj.data{2}(bID,chID)]';
SubjectList = StatObj.data{1}.subjectList{bID};

plot([1.2 1.8],g,'g')
% for i = 1:length(g)
%     text(1.1+0.2*rand(1,1),g(1,i)+0.2*rand(1,1),num2str(SubjectList(i)),'fontsize',10,'horizontalalignment','right')
%     text(1.8+0.2*rand(1,1),g(2,i)+0.2*rand(1,1),num2str(SubjectList(i)),'fontsize',10)
% end
boxplot(g')
hold on
plot(1,mean(g(1,:)),'s','Markerfacecolor','k')
plot(2,mean(g(2,:)),'s','Markerfacecolor','k')
text(1.02,mean(g(1,:)),'Mean','fontsize',10)
text(2.02,mean(g(2,:)),'Mean','fontsize',10)
xlim([0.8 2.2])
ylim([min(g(:))-0.1*min(g(:)) max(g(:))+0.1*max(g(:))])
set(gca,'Xtick', [1 2],'XtickLabel',{[regexprep(NBTstudy.groups{StatObj.groups(1)}.groupName,'_',' ') , '(n = ',num2str(length(g(1,:))),')' ];[regexprep(NBTstudy.groups{StatObj.groups(2)}.groupName,'_',' ') , '(n = ',num2str(length(g(2,:))),')' ]},'fontsize',10,'fontweight','bold')
xlabel('')
ylabel([regexprep(StatObj.data{1}.biomarkers{bID},'_',' ')],'fontsize',10,'fontweight','bold')

pval = StatObj.pValues{1};

title({[regexprep(StatObj.getBiomarkerNames,'_',' ') ' values for '],[' Question ' num2str(chID) '.'''  Questions{chID} ''''],[' for each subjects (p = ',pval(chID),')']},'fontweight','bold','fontsize',10)
%----------------------
answ(:,1) = s.c1(chan_or_reg,:);
answ(:,2) = s.c2(chan_or_reg,:);

h5 = figure('Visible','on','numbertitle','off','Name',...
    [biom ' for question ' num2str(chan_or_reg) ': Relative Frequencies of Responses'],...
    'Position',[1000   500   450   300]);

set(h5,'CreateFcn','movegui')
hgsave(h5,'onscreenfig')
close(h5)
h4= hgload('onscreenfig');
currentFolder = pwd;
delete([currentFolder '/onscreenfig.fig']);

c_hist = hist(answ,floor(min(min(answ))):ceil(max(max(answ))));
c_hist = c_hist/size(answ,1)*100;
bar(floor(min(min(answ))):ceil(max(max(answ))),c_hist )
set(gca,'xtick',floor(min(min(answ))):ceil(max(max(answ))));
set(gca,'xticklabel',floor(min(min(answ)):ceil(max(max(answ)))));
set(gca,'ylim',[0 100])
xlabel('Scores')
ylabel('Frequency [%]')
legend([ regexprep(G1name,'_',' ')  ' (n = ' num2str(size(answ,1)) ')' ],[regexprep(G2name,'_',' ')  ' (n = ' num2str(size(answ,1)) ')' ])
title({['Relative Frequencies of Responses for Question ', num2str(chan_or_reg) '.' ] ,...
    [''''  questions{chan_or_reg} '''']},'fontweight', 'bold' )
h6 = figure('Visible','on','numbertitle','off','Name',...
    [biom ' for question ' num2str(chan_or_reg) ' Difference Distribution'],...
    'Position',[1000   500   450   300]);

set(h6,'CreateFcn','movegui')
hgsave(h6,'onscreenfig')
close(h6)
h6= hgload('onscreenfig');
currentFolder = pwd;
delete([currentFolder '/onscreenfig.fig']);
ansdiff = s.c2(chan_or_reg,:)-s.c1(chan_or_reg,:);
pdiff = s.p(chan_or_reg);
d_hist = hist(ansdiff,floor(min(min(ansdiff))):ceil(max(max(ansdiff))));
d_hist = d_hist/size(answ,1)*100;
bar(floor(min(min(ansdiff))):ceil(max(max(ansdiff))),d_hist)
legend([ regexprep(G2name,'_',' ') ' (n = ' num2str(size(answ,1)) ') - ' regexprep(G1name,'_',' ') ' (n = ' num2str(size(answ,1)) ') , p = ' num2str(sprintf('%.4f',pdiff))])
set(gca,'ylim',[0 100])
set(gca,'xtick',floor(min(min(ansdiff))):ceil(max(max(ansdiff))));
set(gca,'xticklabel',floor(min(min(ansdiff))):ceil(max(max(ansdiff))));

xlabel('Score Difference')
ylabel('Frequency [%]')
title({['Difference Distribution for Question ', num2str(chan_or_reg) '.' ] ,...
    [''''  questions{chan_or_reg} '''']},'fontweight', 'bold' )


end

