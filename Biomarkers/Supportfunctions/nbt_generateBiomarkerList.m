% nbt_generateBiomarkerList - this function creates an analysis object,
% iterates along all biomarkers which have a fixed order in NBT Print and
% checks whether the biomarker is present for the current group and stores
% it in the analysis object
%
% Usage:
%   obj = nbt_generateBiomarkerList(NBTstudy,groupNumber);
%
% Inputs:
%   NBTstudy,
%   groupNumber
%
% Outputs:
%  Analysis object containing the biomarkers present in the data for a
%  specific group, in the fixed NBT Print biomarker order
%
% Example:
%   obj = nbt_generateBiomarkerList(NBTstudy,1);
%
% References:
%
% See also:
%  nbt_Print, nbt_getData

%------------------------------------------------------------------------------------
% Originally created by Simon J. Houtman (2015)
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

function obj = nbt_generateBiomarkerList(obj,GroupObject,signal,grpIdx,selectedBiomarkers,courseMode)
    %Get the biomarkerlist from NBTstudy
    biomarkerList = GroupObject.biomarkerList;
    
    %obj.group{grpIdx}.biomarkerIndex = cell(1,length(biomarkerList));
    
    % Specify the fixed order for the NBT Print plots
    freqBandsFixedOrder = {'1  4', '4  8', '8  13', '13  30', '30  45'};
    freqBandsFixedOrderNames = {'Delta', 'Theta', 'Alpha', 'Beta', 'Gamma'};
    
    % SH FIXME - Only 4 rows of biomarkers for the course
    if strcmp(courseMode,'off')
        biomarkersFixedOrder = {'NBTe_nbt_PeakFit', 'NBTe_nbt_PeakFit', 'NBTe_nbt_PeakFit', 'NBTe_nbt_DFA', 'NBTe_nbt_PLI','NBTe_nbt_PeakFit','NBTe_nbt_PeakFit','NBTe_nbt_AmplitudeCorr','NBTe_nbt_Coher','NBTe_nbt_PhaseLocking'};
        subBiomarkersFixedOrder = {'AbsolutePower', 'RelativePower', 'CentralFreq', 'markerValues', 'pliVal','Bandwidth','SpectralEdge','MarkerValues','Coherence','PLV'};
    else
        biomarkersFixedOrder = {'NBTe_nbt_PeakFit', 'NBTe_nbt_PeakFit', 'NBTe_nbt_PeakFit', 'NBTe_nbt_DFA', '','','','','',''};
        subBiomarkersFixedOrder = {'AbsolutePower', 'RelativePower', 'CentralFreq', 'markerValues', '','','','','',''};
    end
    
    % Iterate along all fixed biomarkers and then check whether a present
    % biomarker corresponds to the fixed biomarker and store it in the
    % analysis object. This will make sure that the biomarkers are stored
    % in the fixed NBT Print order.
    i = 1;
    k = 50;
    for presentBiomarker = 1 : length(biomarkerList)
        currentBiom = biomarkerList{presentBiomarker}
        [biomName, identifiers, subBiomName, biomarkerClass, biomarkerUnit] = nbt_parseBiomarkerIdentifiers(currentBiom);
        
        if ~ismember('Signals',identifiers)
            identifiers{end+1,1} = 'Signals';
            identifiers{end,2} = signal;
        end
        
        %%% Pick out the biomarkers for the specified signal
        %%% Pick out all if no signal identifier is present
        if ismember(signal,identifiers)
        %%% Check whether there is a frequencyRange
            if ismember('frequencyRange',identifiers)
                %%% Get the index of the frequencyRange identifier
                identIndex = find(ismember(identifiers,'frequencyRange'));
                freqRange = identifiers{identIndex,2};
            else
                %%% For PeakFit
                [subBiomName, freqRange] = strtok(subBiomName,'_');
                freqRange = strrep(freqRange,'_','');
            end            
            

            if ismember(biomName,biomarkersFixedOrder) & ismember(subBiomName,subBiomarkersFixedOrder)
                biomIndex = find(ismember(subBiomarkersFixedOrder,subBiomName));
                %%% For all biomarkers except PeakFit
                if ismember(freqRange,freqBandsFixedOrder)
                    freqIndex = find(ismember(freqBandsFixedOrder,freqRange));

                    %%% Store the biomarker in the analysis object
                    obj.group{grpIdx}.originalBiomNames{i} = currentBiom;
                    obj.group{grpIdx}.biomarkers{i} = biomName;
                    obj.group{grpIdx}.subBiomarkers{i} = subBiomName;

                    obj.group{grpIdx}.biomarkerIdentifiers{i} = {'frequencyRange' freqRange};
                    obj.group{grpIdx}.classes{i} = biomarkerClass;
                    obj.group{grpIdx}.biomarkerIndex((biomIndex-1)*5 + freqIndex) = i;
                    obj.group{grpIdx}.units{(biomIndex-1)*5 + freqIndex} = biomarkerUnit;

                    i = i + 1;
                elseif ismember(freqRange,freqBandsFixedOrderNames)
                    %%% For PeakFit
                    freqIndex = find(ismember(freqBandsFixedOrderNames,freqRange));

                    %%% Store the biomarker in the analysis object
                    obj.group{grpIdx}.originalBiomNames{i} = currentBiom;
                    obj.group{grpIdx}.biomarkers{i} = biomName;
                    obj.group{grpIdx}.subBiomarkers{i} = [subBiomName '_' freqRange];

                    obj.group{grpIdx}.biomarkerIdentifiers{i} = [];
                    obj.group{grpIdx}.classes{i} = biomarkerClass;
                    obj.group{grpIdx}.biomarkerIndex((biomIndex-1)*5 + freqIndex) = i;
                    obj.group{grpIdx}.units{(biomIndex-1)*5 + freqIndex} = biomarkerUnit;

                    i = i + 1;
                end
%             else
%                 if isempty(strfind(currentBiom, 'rsq')) & strfind(biomarkerList{selectedBiomarkers},biomName)
%                     %%% Store the biomarker in the analysis object
%                     obj.group{grpIdx}.originalBiomNames{k} = currentBiom;
%                     obj.group{grpIdx}.biomarkers{k} = biomName;
%                     obj.group{grpIdx}.subBiomarkers{k} = subBiomName;
% 
%                     obj.group{grpIdx}.biomarkerIdentifiers{k} = {'frequencyRange' freqRange};
%                     obj.group{grpIdx}.classes{k} = biomarkerClass;
%                     obj.group{grpIdx}.biomarkerIndex(k) = i;
%                     obj.group{grpIdx}.units{k} = biomarkerUnit;
% 
%                     k = k + 1;
%                 end
            end
        end
    end
end