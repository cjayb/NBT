function nbt_topoplotConnect(NBTstudy,connMatrix,significanceMask,cbType)
    if strcmp(cbType,'diff')
        perc20 = [ 0 0 0 0 0 ];
    else
        perc20 = linspace(min(connMatrix(:)),max(connMatrix(:)),5);
    end

    chanLocs = NBTstudy.groups{1}.chanLocs;
    
    %%% Draw the empty topoplot
    topoplot([],chanLocs,'headrad','rim','maplimits',[-3 3],'style','map','numcontour',0,'electrodes','on','circgrid',100,'gridscale',32,'shading','flat');
    set(gca, 'LooseInset', get(gca,'TightInset'));

    hold on

    connMatrix = reshape(connMatrix,129,129);
    
    
    % Number of channels
    nChannels = size(connMatrix,1);
    %

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

    
    % Colors
    if strcmp(cbType,'diff')
        Cols = load('RedBlue_cbrewer10colors','RedBlue_cbrewer10colors');
        Cols = Cols.RedBlue_cbrewer10colors;
        Cols = Cols([1:4, 7:10],:);
        
        climit = max(abs(connMatrix(connMatrix > ((perc20(3)+perc20(4))/2))));
        cmax = climit;
        cmin = -1*climit;
        
        valueRange = linspace(cmin,cmax,8);
    else
        Cols = load('Red_cbrewer5colors','Red_cbrewer5colors');
        Cols = Cols.Red_cbrewer5colors;
        
        cmax = max(connMatrix(connMatrix > ((perc20(3)+perc20(4))/2)));
        cmin = min(connMatrix(connMatrix > ((perc20(3)+perc20(4))/2)));
        
        valueRange = linspace(cmin,cmax,5);
    end
    
    count = 1;
    for i = 1 : (nChannels - 1)
        for j = i + 1 : nChannels
            if ismember(count, significanceMask) & connMatrix(i,j) > ((perc20(3)+perc20(4))/2)
                
            color = sum(connMatrix(i,j) >= valueRange);
            plot3([y(i) y(j)],[x(i) x(j)], [ones(size(x(i))) ones(size(x(i)))],'LineWidth',2,'Color',Cols(color,:));
            end
            count = count + 1;
        end
    end
end