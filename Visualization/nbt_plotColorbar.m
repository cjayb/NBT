% nbt_plotColorbar - this function plots the colorbar for the topoplots in
% nbt_Print and other NBT visualization tools
%
% Usage:
%   nbt_plotColorbar(subplotIndex, cmin, cmax, maxTicks, units, maxColumns)
%
% Inputs:
%   subPlotIndex,
%   cmin,
%   cmax,
%   maxTicks,
%   units,
%   maxColumns
%
% Outputs:
%
% Example:
%   nbt_plotColorbar(1, min(biomarkerValues), max(biomarkerValues), 6, units, 5)
%
% References:
%
% See also:
%  nbt_Print, nbt_plot_2conditions_topoAll

%------------------------------------------------------------------------------------
% Originally created by ..., Edited by Simon J. Houtman (2015)
%------------------------------------------------------------------------------------
%
% Copyright (C) <year>  <Main Author>  (Neuronal Oscillations and Cognition group,
% Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research,
% Neuroscience Campus Amsterdam, VU University Amsterdam)
%
% Part of the Neurophysiological Biomarker Toolbox (NBT)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% See Readme.txt for additional copyright information.
% ---------------------------------------------------------------------------------------

function nbt_plotColorbar(subplotIndex, cmin, cmax, maxTicks, units, maxColumns, cbType)
    if ~exist('maxTicks')
        disp('Maximum number of ticks was not specified, using default of 6 ticks.');
        maxTicks = 6;
    end
    
    if strcmp(cbType,'diff')
        maxTicks = 5;
    end
    
    %%% Plot the colorbar on the righthand side of the topoplot
    cbar = colorbar('location','west');
    posish = get(cbar,'position');
    set(cbar,'position',[0.14 + mod(subplotIndex-1, maxColumns)*.205,posish(2),0.01,posish(4)+.2*posish(4)],'fontsize',11);               
    
    %%% Set caxis
    if cmin ~= cmax
        caxis([cmin,cmax]);
    else
        caxis([0,1]);
    end
    
    %%% Round the ticks to 2 decimals
    %%% Except if values are smaller than 0.01
    if abs(cmin) > 0.01 | abs(cmax) > 0.01
        
        if((abs(cmax) - abs(cmin))/maxTicks<=1)
            cmin = round(cmin/0.01)*0.01;
            cmax = round(cmax/0.01)*0.01;
        else
            cmin = round(cmin);
            cmax = round(cmax);
        end
    end
    
    %%% Cticks
    cticks = linspace(cmin,cmax,maxTicks);

    %%% Increase the colorbar limits by a very small number, otherwise the
    %%% first or the last tick might fall off (Fix for Matlab bug)
    %%% Note: if you decrease this number further, ticks will fall off
    caxis([min(cticks)-0.00000000001 max(cticks)+0.00000000001]);
    set(cbar,'YTick',cticks);

    if abs(cmin) > 0.01 | abs(cmax) > 0.01
        if((abs(cmax) - abs(cmin))/maxTicks<=1)
            cticks = round(cticks/0.01)*0.01;
        else
            cticks = round(cticks);
        end
    end
    
    %%% Make sure that the number of decimals is the same for all labels
    %%% Convert the ticks to string
        tickStringOriginal = num2str(cticks');
        for k = 1 : size(tickStringOriginal,1)
            %%% If the tick is not rounded to an int, look for the dot
            if ~isempty(strfind(tickStringOriginal(k,:),'.'))
                [head, tail] = strtok(tickStringOriginal(k,:),'.');
                if numel(tail) ~= 3
                    %%% Remove the space at the beginning
                    head = head(2:end);

                    %%% And add the zero at the end
                    tickString(k,:) = [head tail '0'];
                else
                    tickString(k,:) = [head tail];
                end
            else
                %%% If there is no dot, take the original
                tickString(k,:) = tickStringOriginal(k,:);
            end
        end
        set(cbar,'YTickLabel',tickString,'FontName','Helvetica');

    %%% Freeze the colorbar colors
    cbar = cbfreeze(cbar);
    freezeColors;
    
    %%% Put the unit on the colorbar
    set(get(cbar,'title'),'String',units(subplotIndex),'interpreter','tex','fontsize',10,'FontName','Helvetica','FontWeight','demi');

    
    %%% Change the colorbar position [left, bottom, width, height]
    cbarPos = [0.14+mod(subplotIndex-1,5)*.205, posish(2), 0.008, posish(4)+.2*posish(4)];
    
    %%% Set the colorbar position
    set(cbar,'Position',cbarPos);
end