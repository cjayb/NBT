function data = ft_datatype_raw(data, varargin)

% FT_DATATYPE_RAW describes the FieldTrip MATLAB structure for raw data
%
% The raw datatype represents sensor-level time-domain data typically
% obtained after calling FT_DEFINETRIAL and FT_PREPROCESSING. It
% contains one or multiple segments of data, each represenetd as 
% Nchan X Ntime arrays.
%
% An example of a raw data structure with 275 MEG channels is
%
%        label: {275x1 cell}        the channel labels (e.g. 'MRC13')
%         time: {1x10 cell}         the timeaxis [1xN double] per trial
%        trial: {1x10 cell}         the numeric data [275xN double] per trial
%          hdr: [1x1 struct]        the full header information of the original dataset on disk
%      fsample: 600                 the sampling frequency
%         grad: [1x1 struct]        information about the sensor array (for EEG it is called elec)
%          cfg: [1x1 struct]        the configuration used by the function that generated this data structure
%
% Required fields:
%   - time, trial, label
%
% Optional fields:
%   - sampleinfo, trialinfo, grad, elec, hdr, cfg
%
% Deprecated fields:
%   - fsample
%
% Obsoleted fields:
%   - offset
%
% Revision history:
%
% (2010v2/latest) The trialdef field has been replaced by the sampleinfo and
% trialinfo fields. The sampleinfo corresponds to trl(:,1:2), the trialinfo
% to trl(4:end).
%
% (2010v1) In 2010/Q3 it shortly contained the trialdef field which was a copy
% of the trial definition (trl) is generated by FT_DEFINETRIAL.
%
% (2007) It used to contain the offset field, which correcponds to trl(:,3).
% Since the offset field is redundant with the time axis, the offset field is
% from now on not present any more. It can be recreated if needed.
%
% (2003) The initial version was defined
%
% See also FT_DATATYPE and FT_DATATYPE_xxx

% Copyright (C) 2011, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: ft_datatype_raw.m 3096 2011-03-13 19:07:20Z jansch $

% get the optional input arguments, which should be specified as key-value pairs
version = keyval('version', varargin); if isempty(version), version = 'latest'; end

if strcmp(version, 'latest')
  version = '2010v2';
end

switch version
  case '2010v2'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isfield(data, 'fsample')
      data.fsample = 1/(data.time{1}(2) - data.time{1}(1));
    end

    if isfield(data, 'offset')
      data = rmfield(data, 'offset');
    end

    if ~isfield(data, 'sampleinfo') || ~isfield(data, 'trialinfo')
      % reconstruct it on the fly
      data = fixtrialdef(data);
    end

    % the trialdef field should be renamed into sampleinfo
    if isfield(data, 'trialdef')
      data.sampleinfo = data.trialdef;
      data = rmfield(data, 'trialdef');
    end

  case '2010v1'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isfield(data, 'fsample')
      data.fsample = 1/(data.time{1}(2) - data.time{1}(1));
    end

    if isfield(data, 'offset')
      data = rmfield(data, 'offset');
    end

    if ~isfield(data, 'trialdef') && hascfg
      % try to find it in the nested configuration history
      data.trialdef = ft_findcfg(data.cfg, 'trl');
    end

  case '2007'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isfield(data, 'fsample')
      data.fsample = 1/(data.time{1}(2) - data.time{1}(1));
    end

    if isfield(data, 'offset')
      data = rmfield(data, 'offset');
    end

  case '2003'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isfield(data, 'fsample')
      data.fsample = 1/(data.time{1}(2) - data.time{1}(1));
    end

    if ~isfield(data, 'offset')
      data.offset = zeros(length(data.time),1);
      for i=1:length(data.time);
        data.offset(i) = round(data.time{i}(1)*data.fsample);
      end
    end

  otherwise
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    error('unsupported version "%s" for raw datatype', version);
end

