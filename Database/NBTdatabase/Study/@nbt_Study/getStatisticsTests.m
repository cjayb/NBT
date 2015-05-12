

%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2014), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
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
% -------------------------------------------------------------------------
function  S = getStatisticsTests(index)
%if index == 0 we return a list of all available tests.
if(index ==0)
    S = {...
        'Grand median plot', ...
        'Grand mean plot', ... 
        'Median group plot', ... 
        'Mean group plot',... 
        'Normality (Univariate): Lilliefors test', ...
        'Normality (Univariate): Shapiro-Wilk test', ...   
        'Parametric (Univariate): Student paired t-test', ...
        'Non-Parametric (Univariate): Wilcoxon signed rank test', ...
        'Parametric (Bi-variate): Student unpaired t-test', ...
        'Non-Parametric (Bi-variate): Wilcoxon rank sum test', ...
        'Non-Parametric (Bi-variate): Permutation for mean difference', ...
        'Non-Parametric (Univariate): Permutation for paired mean difference', ...
        'Non-Parametric (Bi-variate): Permutation for median difference', ...
        'Non-Parametric (Univariate): Permutation for paired median difference', ...
        'Non-Parametric (Bi-variate): Permutation for correlation', ...
        'One-way ANOVA', ...
        'Two-way ANOVA', ...
        'n-way ANOVA', ...  
        'Kruskal-Wallis test', ...
        'Friedman test', ...
        'Spider plot', ...
        'Elastic logit', ...
        'LS-SVM', ...
        'Compare biomarkers' ...
        };
    return
end
%Otherwise we return the specific statistics object
switch index
    case 1
        %'Grand median plot';
        
    case 2
        
        
        %'Grand mean plot';
        
    case 3
        %'Median group plot';
        
    case 4
        %'Mean group plot';
        
    case 5 % Normality (Univariate): Lilliefors test
        
        
      
        
    case 6 % Normality (Univariate): Shapiro-Wilk test
        
      
        
    case 7 % Parametric (Univariate): Student paired t-test
      S = nbt_ttest;
        
    case 8 % Non-Parametric (Univariate): Wilcoxon signed rank test
      S = nbt_signrank;  
      
        
    case 9 % Parametric (Bi-variate): Student unpaired t-test
        S = nbt_ttest2;
        
    case 10 % Non-Parametric (Bi-variate):  Wilcoxon rank sum test
        %.statfuncname='Wilcoxon rank sum test';
        
    case 11 % Non-Parametric (Univariate):  Permutation for difference means or medians
        %        s.statfuncname='Permutation for mean difference';
        
    case 12 % Non-Parametric (Univariate):  Permutation for paired difference means or medians
        
        %s.statfuncname='Permutation for paired mean difference';
        
    case 13 % Non-Parametric (Univariate):  Permutation for difference means or medians
        %.statfuncname='Permutation for median difference';
        
    case 14 % Non-Parametric (Univariate):  Permutation for paired difference means or medians
        
        %s.statfuncname='Permutation for paired median difference';
        
    case 15 % Non-Parametric (Bi-variate):  Permutation for correlation
        
        % s.statfuncname='Permutation for correlation';
        
    case 16 % ANOVA one-way
        %.statfuncname = 'One-way ANOVA';
        
    case 17 % ANOVA two-way
        %s.statfuncname = 'Two-way ANOVA';
        
    case 18
        %s.statfuncname = 'n-way ANOVA';
        
    case 19 %Kruskal-Wallis test
        %s.statfuncname = 'Kruskal-Wallis test';
        
    case 20 %Friedman test
        %s.statfuncname = 'Friedman test';
        
    case 21 % Spider plot
        %s.statfuncname = 'Spider plot';
        S = nbt_spiderplot;
    case 22
        S = nbt_elasticLogit;
    case 23
        S = nbt_lssvm;
    case 24
        S = nbt_comparebiomarkers;
    otherwise
        S = [];
end
end