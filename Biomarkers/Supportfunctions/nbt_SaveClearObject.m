% nbt_SaveClearObject - Saves the object to the analysis file and clear it.
%
% Usage:
%   nbt_SaveClearObject(ObjectName, SignalInfo, SaveDir);
%
% Inputs:
%   ObjectName     - The name of the object you want to save and clear
%   SignalInfo     - The SignalInfo
%   SaveDir        - The directory you want to save to
%

%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2011), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2011  Simon-Shlomo Poil  (Neuronal Oscillations and Cognition group,
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

function nbt_SaveClearObject(ObjectName, SignalInfo, SaveDir, ReloadSwitch)
narginchk(3,4);
%first we get the object to save
eval([ObjectName '= evalin(''caller'', ObjectName );']);

if(isa(SignalInfo,'nbt_SignalInfo'))
    SaveName = [ObjectName '_' SignalInfo.signalName];
    eval([SaveName '=' ObjectName ';'])
else
    SaveName = ObjectName;
end
%Then we save it
% if(length(strfind(SignalInfo.subjectInfo,'.')) > 3)
%     %%% Hack for converted old data, remove
%     SignalInfo.subjectInfo = strrep(SignalInfo.subjectInfo,'SS','S');
%     an_file = [SaveDir filesep SignalInfo.subjectInfo(1:end-9) '_analysis.mat'];
% else
%%% Hack for converted old data, remove
%   SignalInfo.subjectInfo = strrep(SignalInfo.subjectInfo,'SS','S');
%   an_file = [SaveDir filesep SignalInfo.subjectInfo '_analysis.mat'];
%end
if(isa(SignalInfo,'nbt_SignalInfo'))
    subjectInfoFileName = nbt_correctSubjectinfoNames(SignalInfo.subjectInfo);
else
    subjectInfoFileName = nbt_correctSubjectinfoNames(SignalInfo);
end

an_file = [SaveDir filesep subjectInfoFileName(1:end-5) '_analysis.mat'];
if(exist(an_file,'file') == 2)
    % NBTanalysisFile = matfile(an_file,'Writable', true);
    % eval(['NBTanalysisFile.' ObjectName '= ' ObjectName ';'])
    save(an_file, SaveName, '-append');
    disp('NBT: Analysis File already exists. Appending to existing file!');
elseif(exist(an_file,'file') == 0)
    save(an_file, SaveName,'-v7')
end

%SignalInfo.listOfBiomarkers{end+1} = ObjectName;
%info_name = [SaveDir filesep SignalInfo.subjectInfo '.mat'];
%[SignalInfo.signalName 'Info'];
% save(info_name, 'SignalInfo');

%And then we clear it
eval(['evalin(''caller'',''clear ' ObjectName ''');']);

if(exist('ReloadSwitch','var'))
    nbt_loadsavefile(an_file);
end
end
