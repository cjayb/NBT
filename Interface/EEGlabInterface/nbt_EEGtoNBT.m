%  [Signal, SignalInfo]=nbt_EEGtoNBT(EEG, filename, FileExt)
%  convert EEG struct into NBT Signal (in workspace)
%
%  Usage:
%  [Signal, SignalInfo]=nbt_EEGtoNBT(EEG, filename, FileExt)
%
% Inputs:
%   EEG
%   filename
%   FileExt
%
% Output:
%   Signal
%   SignalInfo
%
% See also:
%   nbt_NBTtoEEG

%--------------------------------------------------------------------------
% Copyright (C) 2008  Neuronal Oscillations and Cognition group,
% Department of Integrative Neurophysiology, Center for Neurogenomics and
% Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
%--------------------------------------------------------------------------


function [Signal, SignalInfo, SignalPath, SubjectInfo] = nbt_EEGtoNBT(EEG, filename, fileExt, saveflag, SignalName)
narginchk(1,5)
%initial setup
if(~exist('filename','var') || isempty(filename))
    filename = EEG.setname;
end

if(~exist('fileExt','var') || isempty(fileExt))
    fileExt = [];
end

if(~exist('SignalName','var') || isempty(SignalName))
   SignalName = 'RawSignal'; 
end

%check and clean EEG struct
EEG = eeg_checkset(EEG(1));
EEG.history = [];
EEG.icaact = [];

%convert to Signal
Signal = double(EEG.data');
EEG.data =[];

%Find SignalInfo and SubjectInfo
if isfield(EEG,'NBTinfo')
    if(isa(EEG.NBTinfo,'nbt_SignalInfo'))
        SignalInfo = EEG.NBTinfo;
        SubjectInfo = EEG.NBTSubjectInfo;
        EEG=rmfield(EEG,'NBTinfo');
        EEG=rmfield(EEG,'NBTSubjectInfo');
    else
        [SignalInfo, SubjectInfo] = nbt_CreateInfoObject(filename, fileExt, EEG.srate,SignalName,Signal);
    end
else
    [SignalInfo, SubjectInfo] = nbt_CreateInfoObject(filename, fileExt, EEG.srate,SignalName,Signal);
end

SignalInfo.convertedSamplingFrequency = EEG.srate;
SignalInfo.interface.EEG = EEG;

%Find SignalPath
if(~isempty(EEG.filepath))
    SignalPath = EEG.filepath;
else
    try
        SignalPath = evalin('base', 'SignalPath');
    catch
        SignalPath = pwd;
        %SignalPath = input('Please specify signal path : ','s');
    end
end

% We are now ready to save the signal
if(~exist('saveflag','var') || isempty(saveflag))
    auto = 0;
    if (strcmpi(input('Do you want to save this signal? ([Y]es/[N]o)','s'),'y'))
        saveflag = 1;
        name = input('Name of NBT Signal? (should contain the word Signal) ','s');
    end
else
    auto = 1;
    name = SignalInfo.signalName;
end

%Make signals
eval([name '= Signal;'])
eval(['[',name,'Info]=SignalInfo;']);

%--- save NBT files if the saveflag = 1
if(saveflag == 1)
    fn=nbt_correctSubjectinfoNames(SignalInfo.subjectInfo);
    if(~auto)
        disp('select directory to save NBT file')
        directoryname = uigetdir('select directory to save NBT file');
    else
        directoryname = SignalPath;
    end    
        d = dir(directoryname);
    
    present=0;
    for i=1:length(d)
        if strcmp(d(i).name,[fn,'.mat'])
            present=1;
        end
    end
    disp('saving...')
    if (present || auto)
        try
            save([directoryname filesep fn '.mat' ],[name 'Info'],'-append')
            if(exist('SubjectInfo','var'))
                save([directoryname filesep fn '.mat'],'SubjectInfo','-append')
            end
        catch
            save([directoryname filesep fn '.mat'],[name 'Info'])
            if(exist('SubjectInfo','var'))
                save([directoryname filesep fn '.mat'],'SubjectInfo','-append')
            end
        end
        try
            save([directoryname filesep fn(1:end-5) '.mat'],name,'-append')
        catch
            save([directoryname filesep fn(1:end-5) '.mat'],name)
        end
    else
        OptionSave = input(['A file named ' fn '.mat does not exist in this directory. Do you want create a new file? [[Y]es [N]o]'],'s'); % e.g. RawSignal, CleanSigna
        if strcmp(OptionSave(1),'Y') || strcmp(OptionSave(1),'y')
            save([directoryname filesep fn '.mat'],[name 'Info'])
            if(exist('SubjectInfo','var'))
                save([directoryname filesep fn '.mat'],'SubjectInfo','-append')
            end
            save([directoryname filesep fn(1:end-5) '.mat'],name)
        end
    end
    disp('NBT signal saved')
end
end