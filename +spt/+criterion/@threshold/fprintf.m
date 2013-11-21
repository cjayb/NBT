function count = fprintf(fid, obj, varargin)

import meegpipe.node.globals;
import misc.fid2fname;
import mperl.file.spec.catfile;
import misc.unique_filename;
import plot2svg.plot2svg;
import inkscape.svg2png;

gallery = clone(globals.get.Gallery);

visible = globals.get.VisibleFigures;

if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

for featItr = 1:numel(obj.Feature)    
    figure('Visible', visibleStr);
    
    featVals = obj.FeatVals(:, featItr);
    
    plot(featVals, 'k', 'LineWidth', 1.5*globals.get.LineWidth);
    hold on;
    plot(featVals, 'ok');
    hold on;
    grid on;
    
    % Plot some additional statistics to make it easier to find a good
    % threshold
    yLim = get(gca, 'YLim');
    axis([0.75 numel(featVals)+0.25 yLim(1) yLim(2)]);
    yMin = yLim(1);
    yMax = yLim(2);
    
    if ~isempty(obj.FeatPlotStats),
        
        statNames = keys(obj.FeatPlotStats);
        statVal  = zeros(1, numel(statNames));
        pos = round(linspace(1, numel(featVals), numel(statNames)+2));
        for i = 1:numel(statNames)
            stat = obj.FeatPlotStats(statNames{i});
            statVal(i) = stat(featVals);
            yMin = min(yMin, statVal(i));
            yMax = max(yMax, statVal(i));
            hold on;
            plot([0.75  numel(featVals)+0.25], repmat(statVal(i), 1, 2), 'g');
        end
    end
      
    % Plot the min/max thresholds, if they fall in view
    minVal = obj.Min{featItr};
    maxVal = obj.Max{featItr};
    if isa(minVal, 'function_handle'), minVal = minVal(featVals); end
    if isa(maxVal, 'function_handle'), maxVal = maxVal(featVals); end
    if maxVal < yMax,
        plot([0.75  numel(featVals)+0.25], repmat(maxVal, 1, 2), 'r');
    end
    if minVal > yMin,
        plot([0.75  numel(featVals)+0.25], repmat(minVal, 1, 2), 'r');
    end      
    
    if ~isempty(obj.FeatPlotStats),
        % Add the texts at the end to prevent the lines writing over them
        for i = 1:numel(statNames)
            text(pos(1+i), statVal(i), statNames{i}, ...
                'FontSize', 6, 'BackgroundColor', 'white');
        end
        R = (yMax - yMin);
        axis([0.75 numel(featVals)+0.25 yMin-0.05*abs(R) yMax+0.05*R]);
    end
  
    nbSel = numel(find(obj.Selected));
    if nbSel > 1,
        plot(find(obj.Selected), featVals(obj.Selected), 'ro', ...
            'MarkerFaceColor', 'Red');
    end
    xlabel('SPC index');
    if numel(obj.Feature) == 1,
        ylabel(class(obj.Feature{1}));
    else
        ylabel('Feature value');
    end
    set(gca, 'XTick', 1:numel(featVals));
    
    rootPath = fileparts(fid2fname(fid));
    fileName = catfile(rootPath, 'rank-report.svg');
    fileName = unique_filename(fileName);
    caption = sprintf(['Feature value for each spatial component.' ...
        ' The red line marks the boundary between selected and unselected' ...
        ' components ']);
    evalc('plot2svg(fileName, gcf);');
    svg2png(fileName);
    close;
end


gallery = add_figure(gallery, fileName, caption);

% Information about the criterion
count = 0;
count = count + fprintf(fid, 'Components selected with criterion ');
count = count + fprintf@spt.criterion.criterion(fid, obj, varargin{:});
count = count + fprintf(fid, '\n\n');
count = count + fprintf(fid, gallery);

end