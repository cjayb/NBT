function [status, MEh] = test_eeglab_fir()
% TEST_EEGLAB_FIR - Tests eeglab_fir filter
import mperl.file.spec.*;
import filter.*;
import test.simple.*;
import pset.session;
import datahash.DataHash;

MEh     = [];

initialize(6);

%% Create a new session
try

    name = 'create new session';
    warning('off', 'session:NewSession');
    session.instance;
    warning('on', 'session:NewSession');
    hashStr = DataHash(randn(1,100));
    session.subsession(hashStr(1:5));
    ok(true, name);

catch ME

    ok(ME, name);
    status = finalize();
    return;

end

%% constructor
try
    
    name = 'constructor';
    filter.eeglab_fir;
    obj  = filter.eeglab_fir([0 20], 'Verbose', false);
    obj2 = filter.eeglab_fir('Fp', [0 20]);
    ok(...
        isa(obj, 'filter.eeglab_fir') & ~is_verbose(obj) & ...
        all(obj2.Fp == [0 20]) & all(obj.Fp == [0 20]), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% band-pass filter
try
    
    name = 'band-pass filter';
    X = randn(5, 1000);
    
    X = filter(filter.bpfilt('Fp', [5 15]/(250/2)), X);
    
    N = 0.1*randn(5, 1000);   
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    myFilt = filter.eeglab_fir('Fp', [5 15], 'Notch', false);
    filter(myFilt, data);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(data(i,:) - X(i,:));
    end
    ok(snr1 > 5*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% low-pass filter
try
    
    name = 'low-pass filter';
    X = randn(5, 1000);
    
    X = filter(filter.lpfilt('fc', 10/(250/2)), X);
    
    N = 0.1*randn(5, 1000);   
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    myFilt = filter.eeglab_fir('Fp', [0 10]);
    filter(myFilt, data);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(data(i,:) - X(i,:));
    end
    ok(snr1 > 5*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% high-pass filter
try
    
    name = 'low-pass filter';
    X = randn(5, 1000);
    
    X = filter(filter.lpfilt('fc', 10/(250/2)), X);
    
    N = 0.1*randn(5, 1000);   
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(N(i,:))/var(X(i,:));
    end
    
    myFilt = filter.eeglab_fir('Fp', [0 10], 'Notch', true);
    filter(myFilt, data);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(N(i,:))/var(data(i,:) - N(i,:));
    end
    ok(snr1 > 5*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try

    name = 'cleanup';   
    clear data dataCopy ans myCfg myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);

catch ME
    ok(ME, name);
end



%% Testing summary
status = finalize();