% Usage:nbt_doCorrelations(Signal,Info,Save_dir)
%
% computes correlations between the channels in the NBT Signal matrix
%
% Inputs:
%
% Signal = NBT Signal matrix
% Info = NBT Info object
%
% This function computes correlations and creates a NBT Biomarker object 
% where it stores the biomarker values.
% This NBT biomarker object is saved in a NBT Analysis file.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2008  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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

function [CorrelationObject] = nbt_doCorrelations(Signal,Info)
type='Pearson';% 'Pearson' (the default) to compute Pearson's linear
% correlation coefficient, 'Kendall' to compute Kendall's
% tau, or 'Spearman' to compute Spearman's rho.

disp(' ')
disp('Command window code:')
disp('nbt_doCorrelations(Signal,SignalInfo')
disp(' ')

disp(['Computing correlations for ',Info.subjectInfo])

% Remove artifact intervals:
Signal = nbt_RemoveIntervals(Signal,Info);

% Compute correlations
nChannels = size(Signal(:,:),2);
CorrelationObject = nbt_Correlations(nChannels);
for i = 1 : (nChannels - 1)
    for j = i + 1 : nChannels
        [CorrelationObject.correlation(i,j), CorrelationObject.pValues(i,j)] = corr(Signal(:,i),Signal(:,j),'type',type);
    end
end

% Set results of bad channels to NaNs:
CorrelationObject.correlation(find(Info.badChannels),:)=NaN;
CorrelationObject.correlation(:,find(Info.badChannels))=NaN;
CorrelationObject.pValues(find(Info.badChannels),:)=NaN;
CorrelationObject.pValues(:,find(Info.badChannels))=NaN;

% Update biomarker object 
CorrelationObject = nbt_UpdateBiomarkerInfo(CorrelationObject, Info);
end
