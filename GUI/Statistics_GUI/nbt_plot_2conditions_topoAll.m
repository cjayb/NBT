%  nbt_plot_2conditions_topoALL - plots an overview of all selected biomarkers - topoplot for statistics with two groups or conditions
%
% Usage:
% nbt_plot_2conditions_topoALL(Group1,Group2,chanloc,s,unit,biomarker,regions)
%
% Inputs:
%   Group1,
%   Group2,
%   chanloc,
%   s,
%   unit,
%   biomarker,
%   regions
%
% Outputs:
%
%
% Example:
%
%
% References:
%
% See also:
%  nbt_plot_EEG_channels, nbt_plot_stat

%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2011), see NBT website for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
%
% Copyright (C) 2011  Simon-Shlomo Poil  (Neuronal Oscillations and Cognition group,
% Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research,
% Neuroscience Campus Amsterdam, VU University Amsterdam)
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
% -------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------

% Todo:
% 1. Fix cmin and cmax
% 2. Combine topoplot functions?
% 3. Fix visualization
% 4. Fix title for each biomarker

function nbt_plot_2conditions_topoAll(StatObj)
global NBTstudy
%%% Get groups NBTstudy
Group1 = NBTstudy.groups{StatObj.groups(1)};
Group2 = NBTstudy.groups{StatObj.groups(2)};

%%% Group names
nameGroup1 = Group1.groupName;
nameGroup2 = Group2.groupName;

%%% Get Biomarker names
biomarkerNames = StatObj.getBiomarkerNames;


%%% Get data for both groups
DataGroup1 = getData(Group1,StatObj);
DataGroup2 = getData(Group2,StatObj);

%%% Group sample sizes
nSubjectsGroup1 = DataGroup1.numSubjects;
nSubjectsGroup2 = DataGroup2.numSubjects;


%%% Get the channel locations from one of the two groups
chanLocs = Group1.chanLocs;

% For all biomarkers, plot the topoplots
nBioms = DataGroup1.numBiomarkers;

q = input('Specify the desired false discovery rate: (default = 0.05) ');

for biomID = 1:nBioms
    %%% Values for all channels for selected biomarker
    chanValuesGroup1 = DataGroup1{biomID,1};
    chanValuesGroup2 = DataGroup2{biomID,1};
    
    %%% Group means
    meanGroup1 = StatObj.groupStatHandle(chanValuesGroup1');
    meanGroup2 = StatObj.groupStatHandle(chanValuesGroup2');
    
    %%% Check whether the statistics test is paired or unpaired
    if (isa(StatObj, 'nbt_PairedStat'))
        statType = 'paired';
        if (size(chanValuesGroup1) ~= size(chanValuesGroup2))
            warning('Different amount of channels for Group 1 and Group 2');
        else %%% este else fica
            diffGrp2Grp1 = StatObj.groupStatHandle((chanValuesGroup2 - chanValuesGroup1)');
        end
    else
        statType = 'unpaired';
        diffGrp2Grp1 = meanGroup2 - meanGroup1;
    end
    
    %%% pValues - corrected for multiple comparision
    pValues = StatObj.pValues(:,biomID);
    [~, pValues] = nbt_MCcorrect(pValues{1}, NBTstudy.settings.visual.mcpCorrection, q);
    
    
    %%% Properties for plotting
    % Set the range [cmin cmax] for the colorbars later on
    vmax=max([meanGroup1 meanGroup2]);
    vmin=min([meanGroup1 meanGroup2]);
    cmax = max(vmax);
    cmin = min(vmin);
    
    % x-spacing, y-spacing, max number of lines, font size
    xa = -2.5;
    ya = 0;
    fontsize = 10;
    
    % Number of contours on the colorbars
    NumberOfContours = 6;
    levs = linspace(cmin, cmax, NumberOfContours + 2);
    MinLevelIndex1 = find(levs > min(meanGroup1),1,'first');
    MinLevelIndex2 = find(levs > min(meanGroup2),1,'first');
    NumberOfContours1 = 6-(MinLevelIndex1-1);
    NumberOfContours2 = 6-(MinLevelIndex2-1);
    
    %%% Plot the subplots
    %%% Subplot for grand average of group 1
    subplot(4, nBioms, biomID);
    text(0,0.7,biomarkerNames{biomID},'horizontalalignment','center','fontWeight','bold');
    plotGrandAvgTopo(1,meanGroup1,biomID,statType);
    cbfreeze
    freezeColors
    
    %%% Subplot for grand average of group 2
    subplot(4, nBioms, biomID+nBioms);
    plotGrandAvgTopo(2,meanGroup2,biomID,statType);
    cbfreeze
    freezeColors
    
    %%% Subplot for grand average difference group 2 minus group 1
    subplot(4, nBioms, biomID+2*nBioms);
    plotGrandAvgDiffTopo(biomID);
    cbfreeze
    freezeColors
    
    %%% Subplot for p-values plot
    % %---plot P-values for the test (log scaled colorbar)
    % minPValue = -2;% Plot log10(P-Values) to trick colour bar -
    % maxPValue = -0.5;
    % % %red white blue color scale
    minPValue = log10(0.0005);
    maxPValue = -log10(0.0005);
    
    
    
    pLog = log10(pValues); % to make it log scaled
    
    pLog = sign(diffGrp2Grp1)'.*pLog;
    pLog = -1*pLog;
    pLog(pLog<minPValue) = minPValue;
    pLog(pLog> maxPValue) = maxPValue;
    
    subplot(4, nBioms, biomID+3*nBioms);
    plot_pTopo(biomID);
    
    cbfreeze;
    drawnow;
end


%% nested functions part
    function plotGrandAvgTopo(conditionNr,meanGroup,subplotIndex,statType)
        %%% This function plots the topoplots for the grand averages of all channels for group 1 and group 2
        %%% Load the predefined nbt red-white colormap
        %nbt_redwhite = load('nbt_colormapContourWhiteRed', 'nbt_colormapContourWhiteRed');
        %nbt_redwhite = nbt_redwhite.nbt_colormapContourWhiteRed;
        
        %%% Set the colormap
        %colormap(nbt_redwhite);
        Reds5 = load('Reds5','Reds5');
        Reds5 = Reds5.Reds5;
        colormap(Reds5);
        
        %%% Plot the topoplot for the corresponding condition, stored in groupMeans vector
        topoplot(meanGroup,chanLocs,'headrad','rim','numcontour',0,'electrodes','on');
        
        %%% Adjust the colorbar limits
        caxis([cmin cmax]);
        
        %%% Plot the colorbar
        plot_colorbar();
        
        %%% Labels for the rows
        if (subplotIndex == 1)
            %%% If the stat test is paired, use 'condition' instead of 'group'
            if (strcmp(statType,'paired'))
                if (conditionNr == 1)
                    rowLabel = sprintf('Grand average for condition %s (n = %s)',nameGroup1,num2str(nSubjectsGroup1));
                else
                    rowLabel = sprintf('Grand average for condition %s (n = %s)',nameGroup2,num2str(nSubjectsGroup2));
                end
                
            else
                % statType == unpaired
                if (conditionNr == 1)
                    rowLabel = sprintf('Grand average for group %s (n = %s)',nameGroup1,num2str(nSubjectsGroup1));
                else
                    rowLabel = sprintf('Grand average for group %s (n = %s)',nameGroup2,num2str(nSubjectsGroup2));
                end
            end
            
            %% Fit the label onto the y-axis
            nbt_wrapText(xa,ya,rowLabel,15,fontsize);
        end
    end


    function plotGrandAvgDiffTopo(subplotIndex)
        %%% This function plots the topoplot for the grand average difference between group 1 and group 2
        climit = max(abs(diffGrp2Grp1)); %colorbar limit
        if(length(find(diffGrp2Grp1>=0)) == length(diffGrp2Grp1(~isnan(diffGrp2Grp1))))  % only positive values
            Red_cbrewer5colors = load('Red_cbrewer5colors','Red_cbrewer5colors');
            Red_cbrewer5colors = Red_cbrewer5colors.Red_cbrewer5colors;
            colormap(Red_cbrewer5colors);
            cmin = 0;
            cmax = climit;
        elseif(length(find(diffGrp2Grp1<=0)) == length(diffGrp2Grp1(~isnan(diffGrp2Grp1)))) % only negative values
            Blue_cbrewer5colors = load('Blue_cbrewer5colors','Blue_cbrewer5colors');
            Blue_cbrewer5colors = Blue_cbrewer5colors.Blue_cbrewer5colors;
            colormap(Blue_cbrewer5colors);
            cmin = -1*climit;
            cmax = 0;
        else
            
            
            RedBlue_cbrewer10colors = load('RedBlue_cbrewer10colors','RedBlue_cbrewer10colors');
            RedBlue_cbrewer10colors = RedBlue_cbrewer10colors.RedBlue_cbrewer10colors;
            colormap(RedBlue_cbrewer10colors);
            cmin = -1*climit;
            cmax = climit;
        end
        %%% Plot the topoplot: check whether test statistic is a ttest or signrank
        chans_Psignificant = find(pValues<0.05);
        nbt_topoplot(diffGrp2Grp1,chanLocs,'headrad','rim','numcontour',0,'electrodes','on','emarker2',{[chans_Psignificant],'o','w',4,1});
        
        
        
        %%% Plot the colorbar
        caxis([cmin cmax]);
        plot_colorbar();
        
        %%% Labels for the rows
        
        
        
        if(subplotIndex == 1)
            if (strcmp(statType,'paired'))
                rowLabel = sprintf('Grand average for condition %s minus incondition %s ',nameGroup2,nameGroup1);
            else
                % statType == unpaired
                rowLabel = sprintf('Grand average for group %s minus group %s',nameGroup2,nameGroup1);
            end
            %% Fit the label onto the y-axis
            nbt_wrapText(xa,ya,rowLabel,15,fontsize);
        end
    end


    function plot_pTopo(subplotIndex)
        %%% This function plots the topoplot for the p-values of the difference
        %%% Load colormap
        
        CoolWarm = load('nbt_DarkBlueWhiteDarkRedSharp', 'nbt_DarkBlueWhiteDarkRedSharp');
        CoolWarm = CoolWarm.nbt_DarkBlueWhiteDarkRedSharp;
        
        
        %%% Set the colormap
        colormap(CoolWarm);
        
        %%% Plot the topoplot
        topoplot(pLog,chanLocs,'headrad','rim','numcontour',0,'electrodes','on');
        
        %%% Adjust the colorbar limits
        caxis([minPValue maxPValue]);
        
        %%% Plot the colorbar
        
        cb = colorbar('westoutside');
        
        rowLabel = 'test';
        %% Fit the label onto the y-axis
        if (subplotIndex == 1)
            rowLabel = sprintf('P-values');
            nbt_wrapText(xa,ya,rowLabel,15,fontsize);
        end
        
        
        axis square
        set(cb,'YTick',[-2.3010 -1.3010 0 1.3010 2.3010]);
        set(cb,'YTicklabel',[0.005 0.05 0 0.05 0.005]);
    end


    function plot_colorbar()
        %%% Plot the colorbar on the lefthand side of the topoplot
        cb = colorbar('westoutside');
        set(get(cb,'title'),'String','');
        
        %%% Round the YTick to 2 decimals
        if((abs(cmax) - abs(cmin))/6<=1)
            cmin = round(cmin/0.01)*0.01;
            cmax = round(cmax/0.01)*0.01;
        else
            cmin = round(cmin);
            cmax = round(cmax);
        end
        
        cticks = linspace(cmin,cmax,6);
        caxis([min(cticks) max(cticks)]);
        set(cb,'YTick',cticks);
        if((abs(cmax) - abs(cmin))/6<=1)
            set(cb,'YTickLabel',round(cticks/0.01)*0.01);
        else
            set(cb,'YTickLabel',round(cticks));
        end
        
    end
end %% ver s este esta bem
