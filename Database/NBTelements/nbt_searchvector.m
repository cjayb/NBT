% nbt_searchvector() - returns a vector with indices of elements in
% 'vector'
% that match the 'searchvector'
%
% Usage:
%   >>  positive = nbt_searchvector( vector, searchvector );
%
% Inputs:
%   vector     - vector which indices will be used
%   searchvector     - a vector with elements to match
%
% Outputs:
%   positive     - non-sorted vector of indices of elements in 'vector' that match elements
%   in 'searchvector'
%
% Example:
%nbt_searchvector([1 2 6 3 4 5], [1 2 6 4])
% will return; 1 2 3 5.


% Copyright (C) 2010 Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
%

function [positive] = nbt_searchvector(vector, searchvector)

if(isempty(vector) || isempty(searchvector))
    positive  = [];
    return;
end

if(iscell(searchvector))
    if(length(searchvector) == 1)
        if(ischar(searchvector{1,1}))
            positive = find(strcmp(searchvector,vector));
        elseif(isnumeric(searchvector{1,1}))
            vector = nbt_cellc(vector,0);
            positive = [];
            for m=1:length(vector)
                positive = [positive; find(vector{m,1} == searchvector{1,1})];
            end
        end
    else
        searchvector = nbt_cellc(searchvector, 0);
        vector = nbt_cellc(vector,0);
         positive = [];
        for i=1:length(searchvector)
            vs = searchvector{i,1};
            if(isnumeric(vs))
                for m=1:length(vector)
                    positive = [positive; find(vector{m,1} == vs)];
                end
            elseif(ischar(vs))
                positive = [positive; find(strcmp(vector,vs))];
            end
        end
    end
else
    if(isnan(searchvector))
        positive = find(isnan(vector));
        return
    end
    positive = [];
    for i=1:length(searchvector)
        temp = find(vector == searchvector(i));
        if(~isempty(temp))
            for mm=1:length(temp)
                positive = [positive temp(mm)];
            end
        end
    end
end

end
