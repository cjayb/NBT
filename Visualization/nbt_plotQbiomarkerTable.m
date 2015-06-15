function nbt_plotQbiomarkerTable(StatObj,QBidx)
global NBTstudy
if(length(QBidx) > 1)
    for i = 1:length(QBidx)
        nbt_plotQbiomarkerTable(StatObj,QBidx(i));
    end
    %error('Only one questionaire per Analysis is currently supported')
else
    
    
    h5 = figure('Visible','on','numbertitle','off','resize','on','Menubar','none',...
        'Name',['Table with all items ' ],...
        'Position',[100   200  1000   500]);
    h5 = nbt_movegui(h5);
    Notsign = find(StatObj.pValues{QBidx} >= 0.05);
    for i = 1:length(StatObj.pValues{QBidx})
        strp{i} = (sprintf('%.4f',StatObj.pValues{QBidx}(i)));
    end
    
    for i = 1:length(Notsign)
        strp{Notsign(i)} = 'N.S.';
    end
    
    questions  = StatObj.data{StatObj.groups(1)}.biomarkerMetaInfo{QBidx};
    questions = replaceEmpty(questions);
    
    meanGroup1 = StatObj.groupStatHandle(StatObj.data{StatObj.groups(1)}{QBidx,1},2);
    meanGroup2 = StatObj.groupStatHandle(StatObj.data{StatObj.groups(2)}{QBidx,1},2);
    bothGroups = min(length(meanGroup1),length(meanGroup2));
    Group2minusGroup1 = meanGroup2(1:bothGroups) - meanGroup1(1:bothGroups);
    nNum = size(StatObj.data{StatObj.groups(1)}{QBidx,1},2);
    bNum = bothGroups; %size(StatObj.data{1}{QBidx,1},1);
    data = cell(bNum,7);
    
    for i = 1:bNum
        data{i,1} = i;
        data{i,2} = questions{i};
        data{i,3} = meanGroup1(i);
        data{i,4} = meanGroup2(i);
        data{i,5} = Group2minusGroup1(i);
        data{i,6} = strp{i};
        data{i,7} = nNum;
    end
    
    G1name = NBTstudy.groups{StatObj.groups(1)}.groupName;
    G2name = NBTstudy.groups{StatObj.groups(2)}.groupName;
    statName = func2str(StatObj.groupStatHandle);
    
    cnames = {'Question','Item',[statName '(' regexprep(G1name,'_',' ')  ')'],...
        [statName '(' regexprep(G2name,'_',' ') ')'],...
        [statName '(' regexprep(G2name,'_',' ')  ') - ' statName '(' regexprep(G1name,'_',' ') ')'],...
        [StatObj.testName ' p-value'],'n'};
    columnformat = {'numeric', 'char', 'numeric','numeric','numeric','char','numeric'};
    columnWidth = {100,200,100,100,200,100,25};
    t = uitable('Parent',h5,'ColumnName',cnames,'ColumnFormat', columnformat,...
        'Data',data,'Position',[20 20 950 470],'RowName',[], 'ColumnWidth',columnWidth);
    
    set(t,'CellSelectionCallBack',@qselected)
end
%nested function
    function qselected(a,b)
        Qid = b.Indices(1);
        %nbt_plotBoxplot(StatObj, QBidx, Qid);
        
        pValues = StatObj.pValues{1};
        p = pValues(Qid);
        
        subjectList1 = StatObj.data{StatObj.groups(1)}.subjectList{1};
        subjectList2 = StatObj.data{StatObj.groups(2)}.subjectList{1};
        
        
        % Use the working boxplot function:
        nbt_plotBoxplots(StatObj.data{StatObj.groups(1)}(QBidx,Qid)',StatObj.data{StatObj.groups(2)}(QBidx,Qid)',questions{Qid},G1name,G2name,subjectList1,subjectList2,p,'')
    end

end

function questions = replaceEmpty(questions)
for i=1:length(questions)
    if(isempty(questions{i}))
        questions{i} = 'Empty question';
    end
end
end


