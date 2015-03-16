function myNode = abp_features(varargin)
% ABP_FEATURES - Extraction of Arterial Blood Pressure features

import meegpipe.node.*;

featNames = {...
    'systolic_bp',  ...
    'diastolic_bp', ...
    'pulse_pressure',  ...
    'mean_pressure', ...
    'mean_dyneg', ...
    'area_under_systole1', ...
    'area_under_systole2',  ...
    'heart_rate', ...
    'co' ...
    };

mySel = physioset.event.class_selector('Class', 'abp_onset');

auxVars = {...
    @(data, ev, sel) get_sample(select(mySel, get_event(data))) ...
    };

featList = {...
    @(data, ev, sel, aux) abp_features.systolic_bp(data, aux); ...
    @(data, ev, sel, aux) abp_features.diastolic_bp(data, aux); ...
    @(data, ev, sel, aux) abp_features.pulse_pressure(data, aux); ...
    @(data, ev, sel, aux) abp_features.mean_pressure(data, aux); ...
    @(data, ev, sel, aux) abp_features.mean_dyneg(data, aux); ...
    @(data, ev, sel, aux) abp_features.area_under_systole1(data, aux); ...
    @(data, ev, sel, aux) abp_features.area_under_systole2(data, aux); ...
    @(data, ev, sel, aux) abp_features.heart_rate(data, aux); ...
    @(data, ev, sel, aux) abp_features.co(data, aux) ...
    };


myNode = generic_features.new(...
    'Name',         'abp_features', ...
    'FirstLevel',   featList, ...
    'FeatureNames', featNames, ...
    'AuxVars',      auxVars, ...
    'DataSelector', pset.selector.sensor_label('^BP'), ...
    varargin{:} ...
    );

end