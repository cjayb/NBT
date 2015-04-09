% [Signal, Info] = nbt_EEGlab2NBTsignal(EEG,saveflag)
% Will convert EEGLAB dataset to NBTsignal
%
% Usage:
%  [Signal, Info]= EEGlab2NBTsignal(EEG,saveflag)
% or
% [Signal, Info]= EEGlab2NBTsignal(EEG)
%
% Inputs:
%   EEG : EEGLAB EEG structure
%   saveflag : if it is present and equal to 1; allow to save the NBT
%              Signal and Info files in the selected folder
% Outputs:
%  Saves two files: signal and info file
%
% See also:
%   nbt_NBTsignal2EEGlab

%--------------------------------------------------------------------------
% Copyright (C) 2008  Simon-Shlomo Poil
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

function [Signal,SignalInfo, SignalPath, SubjectInfo] = nbt_EEGlab2NBTsignal(EEG,saveflag)

EEG = eeg_checkset(EEG(1));
Signal = double(EEG.data');

if(~isempty(EEG.filepath))
    SignalPath = EEG.filepath;
else
    try
        SignalPath = evalin('base', 'SignalPath');
    catch
        SignalPath = input('Please specify signal path : ','s');
    end
end

%--- make Info object
if isfield(EEG,'NBTinfo')
    if(isa(EEG.NBTinfo,'nbt_SignalInfo'))
        SignalInfo = EEG.NBTinfo;
        SubjectInfo = EEG.NBTSubjectInfo;
        EEG=rmfield(EEG,'NBTinfo');
        EEG=rmfield(EEG,'NBTSubjectInfo');
    else
        [SignalInfo, SubjectInfo] = nbt_CreateInfoObject(EEG.setname, [], EEG.srate,[],double(EEG.data'));
    end
else
    [SignalInfo, SubjectInfo] = nbt_CreateInfoObject(EEG.setname, [], EEG.srate,[],double(EEG.data'));
end

SignalInfo.convertedSamplingFrequency = EEG.srate;


%--- make NBTSignal files only if there are changes in the Signal
if (strcmpi(input('Do you want to save this signal? ([Y]es/[N]o)','s'),'y'))
    
    %--- make NBTSignal files
    name = input('Name of NBT Signal? (should contain the word Signal) ','s'); % e.g. RawSignal, CleanSignal
    eval([name '=double(EEG.data'');'])
    
    EEG.data=[];
    EEG.history = [];
    EEG.icaact = [];
    SignalInfo.interface.EEG = EEG;
    
    eval(['[',name,'Info]=SignalInfo;']);
    fn=nbt_correctSubjectinfoNames(SignalInfo.subjectInfo);
    
    %--- save NBT files if the saveflag = 1
    if(exist('saveflag','var'))
        if saveflag == 1
            disp('select directory to save NBT file')
            directoryname = uigetdir('select directory to save NBT file');
            d = dir(directoryname);
            
            present=0;
            for i=1:length(d)
                if strcmp(d(i).name,[fn,'.mat'])
                    present=1;
                end
            end
            disp('saving...')
            if present
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
end
EEG.data=[];
EEG.history = [];
EEG.icaact = [];
SignalInfo.interface.EEG = EEG;
end
