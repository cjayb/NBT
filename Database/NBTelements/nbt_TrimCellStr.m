% nbt_TrimCellStr - trim leading . in cell strings along first dimension
%
% Usage:
%   >>  cellstring=nbt_TrimCellStr(cellstring)
%
% Inputs:
%   cellstring     - the cell string to trim
%
% Outputs:
%   cellstring     - trimemd cell string
%
% Example:
% temp{1,1} = '.1.2'; temp{2,1} = '.2.1'
% temp = nbt_TrimCellStr(temp)
%
%temp =
%
%    '1.2'
%    '2.1'
%

% Copyright (C) 2010  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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

% ChangeLog - see version control log for details
% <date> - Version <#> - <text>

function cellstring=nbt_TrimCellStr(cellstring)

if(iscell(cellstring))
    %first we check first element
    dotindex = strfind(cellstring{1,1},'.');
    if(~isempty(dotindex))
        if(dotindex(1) ~= 1 && dotindex(end) ~= length(cellstring{1,1}))
            return
        end
    end
    dotindex = strfind(cellstring,'.');
    for i=1:length(cellstring)
        tmp = dotindex{i,1};
        if(~isempty(tmp))
            if(tmp(1) == 1)
                tmpString = cellstring{i,1};
                cellstring{i,1} = tmpString(2:end);
            elseif(tmp(end) == length(cellstring{i,1}))
                tmpString = cellstring{i,1};
                cellstring{i,1} = tmpString(1:(end-1));
            end
        end
    end
else
    dotindex = strfind(cellstring,'.');
    if(dotindex(1) == 1)
        cellstring = cellstring(2:end);
    elseif(dotindex(end) == length(cellstring))
        cellstring = cellstring(1:(end-1));
    end
end
end
