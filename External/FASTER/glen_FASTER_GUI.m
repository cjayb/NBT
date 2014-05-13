function FASTER_GUI

% Copyright (C) 2010 Hugh Nolan, Robert Whelan and Richard Reilly, Trinity College Dublin,
% Ireland
% nolanhu@tcd.ie, robert.whelan@tcd.ie
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
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

% Options file format:
% option_wrapper (top level struct)
% option_wrapper.job_name - filename where the options file is stored
% option_wrapper.
% option_wrapper.current_group - current group of options displayed
% (modified by clicking e.g. "Filter Options" button)
% option_wrapper.last_value - last option number in the option group
% clicked (used for double-click window open functionality)

set(0,'Units','pixels');
screensize = get(0,'ScreenSize');
screensize = screensize(1,[3 4]);
%The normal window works down to 800*600, it's pretty unlikely anyone with a smaller res
%display will be running this script anyway
figurepos = [(screensize(1)-720)/2 (screensize(2)-450)/2 720 450];
figurepos = round(figurepos);
bgcolor = [0.9 0.9 0.9];

%%%%%%%%%%%%%%%%%%%%%%%
%%%%% MAIN WINDOW %%%%%
%%%%%%%%%%%%%%%%%%%%%%%

fh = figure;
set(fh,'DockControls','off','Visible','on','Position',figurepos,'MenuBar','none','Toolbar','none','Color',bgcolor,'Resize','off','Name','FASTER EEG Processing','NumberTitle','off');
set(fh,'Units','Normalized');
set(0,'Units','normalized');

all_options=struct;

optpanel=uipanel();

option_box=uicontrol('Parent',optpanel);
init_options();

mainpanel=uipanel('Parent',fh,'Units','Normalized','Position',[0 0 1 1],'BackgroundColor',bgcolor);
bGO = uicontrol('Parent',mainpanel,'Style','pushbutton','String','Run Job','FontSize',24,'FontWeight','bold','Units','Normalized','Position',[0.51 0.01 0.48 0.25],'Callback',{@FASTER_callbacks,'run_FASTER',option_box});

lHeading = uicontrol('Parent',mainpanel,'Style','text','String','Setup', 'FontSize',24,'Units','Normalized','Position',[0.51 0.88 0.49 0.12],'BackgroundColor',bgcolor);

bFolder = uicontrol('Parent',mainpanel,'Style','pushbutton','String','Job directory:', 'FontSize',14,'Units','Normalized','Position',[0.51 0.8 0.18 0.08],'BackgroundColor',bgcolor);
tbFolder = uicontrol('Parent',mainpanel,'Style','edit','String','','FontSize',14,'HorizontalAlign','center','Units','Normalized','Position',[0.70 0.8 0.28 0.08],'UserData','file_options.folder_name');
bChanLocs = uicontrol('Parent',mainpanel,'Style','pushbutton','String','Channel locations:', 'FontSize',12,'Units','Normalized','Position',[0.51 0.71 0.18 0.08],'BackgroundColor',bgcolor);
tbChanLocs = uicontrol('Parent',mainpanel,'Style','edit','String','','FontSize',14,'HorizontalAlign','center','Units','Normalized','Position',[0.70 0.71 0.28 0.08],'UserData','file_options.channel_locations','FontSize',12);
set(tbFolder,'Callback',{@FASTER_callbacks,'update_value',option_box});
set(tbChanLocs,'Callback',{@FASTER_callbacks,'update_value',option_box});
set(bFolder,'Callback',{@FASTER_callbacks,'folderselect',tbFolder,'Select job folder',option_box});
set(bChanLocs,'Callback',{@FASTER_callbacks,'fileselect',tbChanLocs,'Select channel location file',option_box});
lFileType = uicontrol('Parent',mainpanel,'Style','text','String','File type:', 'FontSize',12,'Units','Normalized','Position',[0.51 0.605 0.18 0.08],'BackgroundColor',bgcolor);
ddFileType = uicontrol('Parent',mainpanel,'Style','popupmenu','String',{'BDF file (Biosemi)','SET file (EEGLAB)'},'FontSize',14,'HorizontalAlign','center','Units','Normalized','Position',[0.70 0.615 0.28 0.08],'UserData','file_options.is_bdf','FontSize',12,'Callback',{@FASTER_callbacks,'update_value',option_box});
lSearchString = uicontrol('Parent',mainpanel,'Style','text','String','File filter:', 'FontSize',12,'Units','Normalized','Position',[0.51 0.54 0.18 0.06],'BackgroundColor',bgcolor);
tbSearchString = uicontrol('Parent',mainpanel,'Style','edit','String','','FontSize',14,'HorizontalAlign','center','Units','Normalized','Position',[0.70 0.55 0.28 0.06],'UserData','file_options.searchstring');
set(tbSearchString,'Callback',{@FASTER_callbacks,'update_value',option_box});
lPrefix = uicontrol('Parent',mainpanel,'Style','text','String','Output file prefix:', 'FontSize',12,'Units','Normalized','Position',[0.51 0.46 0.18 0.06],'BackgroundColor',bgcolor);
tbPrefix = uicontrol('Parent',mainpanel,'Style','edit','String','','FontSize',12,'HorizontalAlign','center','Units','Normalized','Position',[0.7 0.47 0.28 0.06],'UserData','file_options.file_prefix');
set(tbPrefix,'Callback',{@FASTER_callbacks,'update_value',option_box});
lResume = uicontrol('Parent',mainpanel,'Style','text','String','Resume:', 'FontSize',12,'Units','Normalized','Position',[0.51 0.39 0.18 0.06],'BackgroundColor',bgcolor);
cbResume = uicontrol('Parent',mainpanel,'Style','checkbox','String','','FontSize',14,'Units','Normalized','Position',[0.83 0.39 0.15 0.08],'UserData','file_options.resume','BackgroundColor',bgcolor);
set(cbResume,'Callback',{@FASTER_callbacks,'update_value',option_box});
other_handles=[tbFolder tbChanLocs ddFileType tbSearchString tbPrefix cbResume];

bSave = uicontrol('Parent',mainpanel,'Style','pushbutton','String','Save job','FontSize',14,'Units','Normalized','Position',[0.51 0.27 0.235 0.1],'Callback',{@FASTER_callbacks,'save_job',option_box});
bLoad = uicontrol('Parent',mainpanel,'Style','pushbutton','String','Load job','FontSize',14,'Units','Normalized','Position',[0.755 0.27 0.235 0.1],'Callback',{@FASTER_callbacks,'open_job',option_box,std_options});

% Options panel

set(optpanel,'Parent',mainpanel,'Units','Normalized','Position',[0.01 0.01 0.49 0.98],'BackgroundColor',bgcolor);
uicontrol('Parent',optpanel,'FontSize',20,'Style','text','String','Options','Units','Normalized','Position',[0.3 0.9 0.4 0.1],'BackgroundColor',bgcolor);

y=0.03;
x=0.05;
h=0.35;
w=0.9;
set(option_box,'Parent',optpanel,'Style','listbox','String','','Units','Normalized','Position',[x y w h]);
set(option_box,'Units','Pixels');
p=get(option_box,'Position');

uicontrol('Parent',optpanel,'FontSize',12,'Style','text','String','Function','Units','Normalized','Position',[0.1 0.82 0.5 0.05],'BackgroundColor',bgcolor);
uicontrol('Parent',optpanel,'FontSize',12,'Style','text','String','Save','Units','Normalized','Position',[0.72 0.82 0.12 0.05],'BackgroundColor',bgcolor);

% Set of options and corresponding window functions for each function group
list_filter={'High pass on','High pass frequency','High pass options','Low pass on','Low pass frequency','Low pass options','Notch on','Notch frequency','Notch options','Resample'};
list_channels={'Reference channel','EEG channels','External channels','Known bad channels','Channel rejection','Rejection options'};
list_epoch={'Markers for epoching','Epoch limits','Baseline subtraction','Epoch rejection','Rejection options'};
list_ICA={'Run ICA','ICA k value','ICA component rejection','Rejection options'};
list_epoch_interp={'Epoch interpolation','Rejection options'};
list_GA={'Make grand average','Grand average markers','Subject removal','Rejection options'};

set(option_box,'String',list_filter); %Set to display the filter settings initially

x1=0.1;
x2=0.71;
x3=0.76;
y=0.75;
filter_button = uicontrol('Parent',optpanel,'FontSize',14,'Style','pushbutton','String','Filter','Value',1,'Units','Normalized','Position',[x1 y 0.5 0.05],'BackgroundColor',bgcolor,'Callback',{@FASTER_callbacks,'changelist',option_box,list_filter,1},'UserData',[0 1]);
filter_save = uicontrol('Parent',optpanel,'Style','checkbox','Value',1,'Units','Normalized','Position',[x3 y 0.05 0.05],'BackgroundColor',bgcolor,'Callback',{@FASTER_callbacks,'set_save_options',1,option_box});
y=y-0.07;
channels_button = uicontrol('Parent',optpanel,'FontSize',14,'Style','pushbutton','String','Channels','Value',1,'Units','Normalized','Position',[x1 y 0.5 0.05],'BackgroundColor',bgcolor,'Callback',{@FASTER_callbacks,'changelist',option_box,list_channels,2});
channels_save = uicontrol('Parent',optpanel,'Style','checkbox','Value',1,'Units','Normalized','Position',[x3 y 0.05 0.05],'BackgroundColor',bgcolor,'Callback',{@FASTER_callbacks,'set_save_options',2,option_box});
y=y-0.07;
epoch_button = uicontrol('Parent',optpanel,'FontSize',14,'Style','pushbutton','String','Epoching','Value',1,'Units','Normalized','Position',[x1 y 0.5 0.05],'BackgroundColor',bgcolor,'Callback',{@FASTER_callbacks,'changelist',option_box,list_epoch,3});
epoch_save = uicontrol('Parent',optpanel,'Style','checkbox','Value',1,'Units','Normalized','Position',[x3 y 0.05 0.05],'BackgroundColor',bgcolor,'Callback',{@FASTER_callbacks,'set_save_options',3,option_box});
y=y-0.07;
ICA_button = uicontrol('Parent',optpanel,'FontSize',14,'Style','pushbutton','String','ICA','Value',1,'Units','Normalized','Position',[x1 y 0.5 0.05],'BackgroundColor',bgcolor,'Callback',{@FASTER_callbacks,'changelist',option_box,list_ICA,4});
ICA_save = uicontrol('Parent',optpanel,'Style','checkbox','Value',1,'Units','Normalized','Position',[x3 y 0.05 0.05],'BackgroundColor',bgcolor,'Callback',{@FASTER_callbacks,'set_save_options',4,option_box});
y=y-0.07;
epoch_interp_button = uicontrol('Parent',optpanel,'FontSize',14,'Style','pushbutton','String','Epoch Interpolation','Value',1,'Units','Normalized','Position',[x1 y 0.5 0.05],'BackgroundColor',bgcolor,'Callback',{@FASTER_callbacks,'changelist',option_box,list_epoch_interp,5});
epoch_interp_save = uicontrol('Parent',optpanel,'Style','checkbox','Value',1,'Units','Normalized','Position',[x3 y 0.05 0.05],'BackgroundColor',bgcolor,'Callback',{@FASTER_callbacks,'set_save_options',5,option_box});
y=y-0.07;
GA_button = uicontrol('Parent',optpanel,'FontSize',14,'Style','pushbutton','String','Grand Average','Value',1,'Units','Normalized','Position',[x1 y 0.5 0.05],'BackgroundColor',bgcolor,'Callback',{@FASTER_callbacks,'changelist',option_box,list_GA,6});

save_handles=[filter_save channels_save epoch_save ICA_save epoch_interp_save];
for s=1:5
    set(save_handles(s),'Value',all_options.save_options(s));
end

settings_list={'Style','String','FontSize','UserData'};

windows_filter={

{
{'text','High pass on',14,0},{'checkbox','',14,'filter_options.hpf_on'},...
},

{
{'text','High pass frequency',14,0},{'edit','',14,'filter_options.hpf_freq'},...
},

{
{'text','HP ripple (dB)',12,0},{'edit','0.01',14,'filter_options.hpf_ripple'},{'text','HP attenuation (dB)',12,0},{'edit','80',14,'filter_options.hpf_attenuation'},{'text','HP transition band width (Hz)',10,0},{'edit','1',14,'filter_options.hpf_bandwidth'},...
},

{
{'text','Low pass on',14,0},{'checkbox','',14,'filter_options.lpf_on'},...
},

{
{'text','Low pass frequency',14,0},{'edit','',14,'filter_options.lpf_freq'},...
},

{
{'text','LP ripple (dB)',12,0},{'edit','0.01',14,'filter_options.lpf_ripple'},{'text','LP attenuation (dB)',12,0},{'edit','80',14,'filter_options.lpf_attenuation'},{'text','LP transition band width (Hz)',10,0},{'edit','1',14,'filter_options.lpf_bandwidth'},...
},

{
{'text','Notch on',14,0},{'checkbox','',14,'filter_options.notch_on'},...
},

{
{'text','Notch frequency',14,0},{'edit','',14,'filter_options.notch_freq'},...
},

{
{'text','Notch band width (dB)',12,0},{'edit','0.01',14,'filter_options.notch_bandwidth1'},{'text','Notch ripple (dB)',12,0},{'edit','0.01',14,'filter_options.notch_ripple'},{'text','Notch attenuation (dB)',12,0},{'edit','80',14,'filter_options.notch_attenuation'},{'text','Notch transition band width (Hz)',10,0},{'edit','1',14,'filter_options.notch_bandwidth2'},...
},

{
{'text','Resample on',14,0},{'checkbox','',14,'filter_options.resample_on'},{'text','Resample frequency (Hz)',12,0},{'edit','512',14,'filter_options.resample_freq'},...
},

};

windows_channels={

{
{'text','Reference channel',14,0},{'edit','',14,'channel_options.ref_chan'},...
}

{
{'text','EEG channels',14,0},{'edit','',14,'channel_options.eeg_chans'},...
}

{
{'text','External channels',14,0},{'edit','',14,'channel_options.ext_chans'},...
}

{
{'text','Known bad channels',14,0},{'edit','',14,'channel_options.bad_channels'},...
}

{
{'text','Run channel rejection',14,0},{'checkbox','',14,'channel_options.channel_rejection_on'},...
}

{
{'text','Channel correlation',14,0},{'checkbox','',14,'channel_options.rejection_options.measure(1)'},{'text','Z threshold',14,0},{'edit','',14,'channel_options.rejection_options.z(1)'},{'text','Channel variance',14,0},{'checkbox','',14,'channel_options.rejection_options.measure(2)'},{'text','Z threshold',14,0},{'edit','',14,'channel_options.rejection_options.z(2)'},{'text','Hurst exponent',14,0},{'checkbox','',14,'channel_options.rejection_options.measure(3)'},{'text','Z threshold',14,0},{'edit','',14,'channel_options.rejection_options.z(3)'},...
},

};

windows_epochs={

{
{'text','Epoch markers',14,0},{'edit','',14,'epoch_options.epoch_markers'},...
},

{
{'text','Epoch limits',14,0},{'edit','-1 1',14,'epoch_options.epoch_limits'},...
},

{
{'text','Baseline subtraction',14,0},{'edit',[-0.1 0],14,'epoch_options.baseline_sub'},...
},

{
{'text','Epoch rejection',14,0},{'checkbox','',14,'epoch_options.epoch_rejection_on'},...
},

{
{'text','Deviation from mean',14,0},{'checkbox','',14,'epoch_options.rejection_options.measure(1)'},{'text','Z threshold',14,0},{'edit','',14,'epoch_options.rejection_options.z(1)'},{'text','Variance',14,0},{'checkbox','',14,'epoch_options.rejection_options.measure(2)'},{'text','Z threshold',14,0},{'edit','',14,'epoch_options.rejection_options.z(2)'},{'text','Amplitude range',14,0},{'checkbox','',14,'epoch_options.rejection_options.measure(3)'},{'text','Z threshold',14,0},{'edit','',14,'epoch_options.rejection_options.z(3)'},...
},

};

windows_ICA={

{
{'text','Run ICA',14,0},{'checkbox','',14,'ica_options.run_ica'},...
}

{
{'text','ICA k value',14,0},{'edit',25,14,'ica_options.k_value'},...
}

{
{'text','Reject ICA components',12,0},{'checkbox','',14,'ica_options.component_rejection_on'},...
}

{
{'text','Median gradient',14,0},{'checkbox','',14,'ica_options.rejection_options.measure(1)'},{'text','Z threshold',14,0},{'edit','',14,'ica_options.rejection_options.z(1)'},{'text','Spectral slope',14,0},{'checkbox','',14,'ica_options.rejection_options.measure(2)'},{'text','Z threshold',14,0},{'edit','',14,'ica_options.rejection_options.z(2)'},{'text','Spatial kurtosis',14,0},{'checkbox','',14,'ica_options.rejection_options.measure(3)'},{'text','Z threshold',14,0},{'edit','',14,'ica_options.rejection_options.z(3)'},{'text','Hurst exponent',14,0},{'checkbox','',14,'ica_options.rejection_options.measure(4)'},{'text','Z threshold',14,0},{'edit','',14,'ica_options.rejection_options.z(4)'},{'text','EOG correlation',14,0},{'checkbox','',14,'ica_options.rejection_options.measure(5)'},{'text','Z threshold',14,0},{'edit','',14,'ica_options.rejection_options.z(5)'},{'text','EOG channels',14,0},{'edit',129:132,12,'ica_options.EOG_channels'},...
}

};

windows_epoch_interp={

{
{'text','Epoch interpolation',14,0},{'checkbox','',14,'epoch_interp_options.epoch_interpolation_on'},...
}

{
{'text','Median gradient',14,0},{'checkbox','',14,'epoch_interp_options.rejection_options.measure(1)'},{'text','Z threshold',14,0},{'edit','',14,'epoch_interp_options.rejection_options.z(1)'},{'text','Variance',14,0},{'checkbox','',14,'epoch_interp_options.rejection_options.measure(2)'},{'text','Z threshold',14,0},{'edit','',14,'epoch_interp_options.rejection_options.z(2)'},{'text','Amplitude range',14,0},{'checkbox','',14,'epoch_interp_options.rejection_options.measure(3)'},{'text','Z threshold',14,0},{'edit','',14,'epoch_interp_options.rejection_options.z(3)'},{'text','Deviation from mean',14,0},{'checkbox','',14,'epoch_interp_options.rejection_options.measure(4)'},{'text','Z threshold',14,0},{'edit','',14,'epoch_interp_options.rejection_options.z(4)'},...
}

};

windows_GA={

{
{'text','Make grand average',14,0},{'checkbox','',14,'averaging_options.make_GA'},...
},

{
{'text','Grand average markers',12,0},{'edit','',14,'averaging_options.GA_markers'},...
},

{
{'text','Subject removal on',12,0},{'checkbox','',14,'averaging_options.subject_removal_on'},...
},

{
{'text','Deviation from mean',14,0},{'checkbox','',14,'averaging_options.rejection_options.measure(1)'},{'text','Z threshold',14,0},{'edit','',14,'averaging_options.rejection_options.z(1)'},{'text','Variance',14,0},{'checkbox','',14,'averaging_options.rejection_options.measure(2)'},{'text','Z threshold',14,0},{'edit','',14,'averaging_options.rejection_options.z(2)'},{'text','Amplitude range',14,0},{'checkbox','',14,'averaging_options.rejection_options.measure(3)'},{'text','Z threshold',14,0},{'edit','',14,'averaging_options.rejection_options.z(3)'},{'text','Max EOG value',14,0},{'checkbox','',14,'averaging_options.rejection_options.measure(4)'},{'text','Z threshold',14,0},{'edit','',14,'averaging_options.rejection_options.z(4)'},...
},

};

all_windows = {windows_filter, windows_channels, windows_epochs, windows_ICA, windows_epoch_interp, windows_GA};

option_wrapper=struct;
option_wrapper.options=all_options;
option_wrapper.current_group=1;
option_wrapper.last_value=1;
option_wrapper.window_handles=all_windows;
option_wrapper.save_handles=save_handles;
option_wrapper.other_handles=other_handles;

set(option_box,'Callback',{@FASTER_callbacks,'pop_up',@make_window},'UserData',option_wrapper);

set(fh,'CloseRequestFcn',{@FASTER_callbacks,'main_window_close',option_box});

hmenu = uimenu('Label','More Options');
uimenu(hmenu,'Label','Save as default options','Callback',{@FASTER_callbacks,'save_defaults',option_box});
uimenu(hmenu,'Label','Load default option','Callback',{@FASTER_callbacks,'get_defaults',option_box});

FASTER_callbacks([],[],'update_controls',option_box);
set(option_box,'Position',p);

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% OPTIONS WINDOW %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

    function nf=make_window(controls2,src)
        controls1={'Style','String','FontSize','UserData'};
        nf = figure;
        N=length(controls2);
        w=400;
        h=40 * (N/2) + 40;
        set(nf,'Units','Pixels','Position',[(screensize(1)-w)/2 (screensize(2)-h)/2 w h],'Color',bgcolor,'WindowStyle','modal');
        hcontrols=zeros(size(controls2));
        for u=1:N
            hcontrols(u)=uicontrol;
            set(hcontrols(u),controls1,controls2{u});
            set(hcontrols(u),'Units','Pixels','BackgroundColor',bgcolor);
            x = (mod(u-1,2)*200);
            y = (20*N)-40*(round(u/2))+40;
            set(hcontrols(u),'Position',[x y 200 40]+get_offset(get(hcontrols(u),'Style')));
            option_wrapper=get(src,'UserData');
            subgroup=get(hcontrols(u),'UserData');
            if ischar(subgroup)
                set(hcontrols(u),'Value',e('option_wrapper.options',subgroup));
                if (strcmpi(get(hcontrols(u),'Style'),'edit'))
                    r=e('option_wrapper.options',subgroup);
                    if (~ischar(r))
                        if (any(mod(r,1)))
                            s=sprintf('%.2f ', r);
                            if (s(end)==' ')
                                s=s(1:end-1);
                            end
                            set(hcontrols(u),'String',s);
                        else
                            if (~isempty(r) && all(diff(r)==1) && length(r)>1)
                                set(hcontrols(u),'String',sprintf('%d:%d', r(1),r(end)));
                            else
                                s=sprintf('%d ',r);
                                if (s(end)==' ')
                                    s=s(1:end-1);
                                end
                                set(hcontrols(u),'String',s);
                            end
                        end
                    else
                        set(hcontrols(u),'String',e('option_wrapper.options',subgroup));
                    end
                end
            else
                set(hcontrols(u),'Value',0);
            end
            set(hcontrols(u),'Callback',{@FASTER_callbacks,'set_window_value',src});
        end

        uicontrol('style','pushbutton','Units','Pixels','BackgroundColor',bgcolor,'Position',[175 10 50 20],'String','OK','Callback',{@FASTER_callbacks,'option_window_close',src,hcontrols,nf},'FontSize',12);
        set(nf,'CloseRequestFcn',{@FASTER_callbacks,'do_nothing'});
    end

    function out=get_offset(uicontrol_type)
        % Lines up text correctly
        switch (uicontrol_type)
            case 'text'
                out=[0 -2 0 -8];
            case 'checkbox'
                out=[80 2 0 0];
            case 'edit'
                out=[0 4 -2 -4];
            otherwise
                out=[0 0 0 0];
        end
        out = out + [0 -5 0 0];
    end

    function out=e(part1,part2)
        out=eval(sprintf('%s.%s',part1,part2));
    end

    function init_options()
        % Provides the default options.
        if (exist('FASTER_defaults.mat','file'))
            def_options=FASTER_callbacks([],[],'get_defaults',option_box);
            %return;
        end

        all_options.job_filename='';
        all_options.current_file=[];
        all_options.current_file_num=1;

        all_options.save_options=ones(1,5);

        all_options.file_options.folder_name='';
        all_options.file_options.current_file='';
        all_options.file_options.current_file_num=1;
        all_options.file_options.channel_locations='';
        all_options.file_options.searchstring='';
        all_options.file_options.cutoff_markers=[];
        all_options.file_options.is_bdf=1;
        all_options.file_options.resume=0;
        all_options.file_options.file_prefix='';
        all_options.file_options.plist=cell(0);
        all_options.file_options.nlist=cell(0);
        

        all_options.filter_options.hpf_on=1;
        all_options.filter_options.hpf_freq=1;
        all_options.filter_options.hpf_ripple=0.05;
        all_options.filter_options.hpf_attenuation=80;
        all_options.filter_options.hpf_bandwidth=1;
        all_options.filter_options.lpf_on=1;
        all_options.filter_options.lpf_freq=95;
        all_options.filter_options.lpf_ripple=0.01;
        all_options.filter_options.lpf_attenuation=40;
        all_options.filter_options.lpf_bandwidth=5;
        all_options.filter_options.notch_on=1;
        all_options.filter_options.notch_freq=50;
        all_options.filter_options.notch_bandwidth1=3;
        all_options.filter_options.notch_ripple=0.05;
        all_options.filter_options.notch_attenuation=80;
        all_options.filter_options.notch_bandwidth2=1;
        all_options.filter_options.resample_on=0;
        all_options.filter_options.resample_freq=0;

        all_options.channel_options.do_reref=1;
        all_options.channel_options.ref_chan=85;
        all_options.channel_options.eeg_chans=1:128;
        all_options.channel_options.ext_chans=129:136;
        all_options.channel_options.bad_channels=[];
        all_options.channel_options.channel_rejection_on=1;
        all_options.channel_options.rejection_options=struct;
        all_options.channel_options.rejection_options.measure(1)=1;
        all_options.channel_options.rejection_options.z(1)=3;
        all_options.channel_options.rejection_options.measure(2)=1;
        all_options.channel_options.rejection_options.z(2)=3;
        all_options.channel_options.rejection_options.measure(3)=1;
        all_options.channel_options.rejection_options.z(3)=3;

        all_options.epoch_options.epoch_markers=[1 2 3];
        all_options.epoch_options.epoch_limits=[-0.2 0.8];
        all_options.epoch_options.baseline_sub=[-0.1 0];
        all_options.epoch_options.epoch_rejection_on=1;
        all_options.epoch_options.rejection_options=struct;
        all_options.epoch_options.rejection_options.measure(1)=1;
        all_options.epoch_options.rejection_options.z(1)=3;
        all_options.epoch_options.rejection_options.measure(2)=1;
        all_options.epoch_options.rejection_options.z(2)=3;
        all_options.epoch_options.rejection_options.measure(3)=1;
        all_options.epoch_options.rejection_options.z(3)=3;

        all_options.ica_options.run_ica=1;
        all_options.ica_options.k_value=25;
        all_options.ica_options.component_rejection_on=1;
        all_options.ica_options.rejection_options=struct;
        all_options.ica_options.rejection_options.measure(1)=1;
        all_options.ica_options.rejection_options.z(1)=3;
        all_options.ica_options.rejection_options.measure(2)=1;
        all_options.ica_options.rejection_options.z(2)=3;
        all_options.ica_options.rejection_options.measure(3)=1;
        all_options.ica_options.rejection_options.z(3)=3;
        all_options.ica_options.rejection_options.measure(4)=1;
        all_options.ica_options.rejection_options.z(4)=3;
        all_options.ica_options.rejection_options.measure(5)=1;
        all_options.ica_options.rejection_options.z(5)=3;
        all_options.ica_options.EOG_channels=129:132;

        all_options.epoch_interp_options.epoch_interpolation_on=1;
        all_options.epoch_interp_options.rejection_options=struct;
        all_options.epoch_interp_options.rejection_options.measure(1)=1;
        all_options.epoch_interp_options.rejection_options.z(1)=3;
        all_options.epoch_interp_options.rejection_options.measure(2)=1;
        all_options.epoch_interp_options.rejection_options.z(2)=3;
        all_options.epoch_interp_options.rejection_options.measure(3)=1;
        all_options.epoch_interp_options.rejection_options.z(3)=3;
        all_options.epoch_interp_options.rejection_options.measure(4)=1;
        all_options.epoch_interp_options.rejection_options.z(4)=3;

        all_options.averaging_options.make_GA=1;
        all_options.averaging_options.GA_markers=[];
        all_options.averaging_options.subject_removal_on=1;
        all_options.averaging_options.rejection_options=struct;
        all_options.averaging_options.rejection_options.measure(1)=1;
        all_options.averaging_options.rejection_options.z(1)=3;
        all_options.averaging_options.rejection_options.measure(2)=1;
        all_options.averaging_options.rejection_options.z(2)=3;
        all_options.averaging_options.rejection_options.measure(3)=1;
        all_options.averaging_options.rejection_options.z(3)=3;
        all_options.averaging_options.rejection_options.measure(4)=1;
        all_options.averaging_options.rejection_options.z(4)=3;

        if (exist('def_options','var'))
            names=fieldnames(all_options);
            for v=1:length(names)
                if ~isfield(def_options,names{v})
                    def_options.(names{v})=all_options.(names{v});
                elseif isstruct(all_options.(names{v}))
                    names_2 = fieldnames(all_options.(names{v}));
                    for t=1:length(names_2)
                        if ~isfield(def_options.(names{v}),names_2{t})
                            def_options.(names{v}).(names_2{t})=all_options.(names{v}).(names_2{t});
                        elseif isstruct(all_options.(names{v}).(names_2{t})) % Max three levels of structs
                            names_3 = fieldnames(all_options.(names{v}).(names_2{t}));
                            for r=1:length(names_3)
                                if ~isfield(def_options.(names{v}).(names_2{t}),names_3{r}) || ~all(size(def_options.(names{v}).(names_2{t}).(names_3{r}))==size(all_options.(names{v}).(names_2{t}).(names_3{r})))
                                    def_options.(names{v}).(names_2{t}).(names_3{r})=all_options.(names{v}).(names_2{t}).(names_3{r});
                                end
                            end
                        end
                    end
                end
            end

            std_options=all_options;
            all_options=def_options;
        else
            std_options=all_options;
        end
    end

end