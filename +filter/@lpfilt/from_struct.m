function obj = from_struct(str)
% FROM_STRUCT - Construction from a struct
%
% obj = from_struct(str)
%
% Where
%
% STR is a struct generated by method struct()
%
% OBJ is the equivalent filter.lpfilt object
%
% See also: struct


import misc.split;

specs = split(',', str.Specs.Specification);

keyVals = {};
for i = 1:numel(specs)
    switch lower(specs{i}),
        case 'fp'
            keyVals = [keyVals {'Fp', str.Specs.Fpass}]; %#ok<*AGROW>
            
        case 'fst'
            keyVals = [keyVals {'Fst', str.Specs.Fstop}];
            
        case 'ap'
            keyVals = [keyVals {'Ap', str.Specs.Apass}];
            
        case 'ast'
            keyVals = [keyVals {'Ast', str.Specs.Astop}];
            
        otherwise
            % Ignore            
        
    end
end

obj = filter.lpfilt(...
    'Order',        str.Order, ...
    'DesignMethod', str.DesignMethod, ...
    'Persistent',   str.Persistent, ...
    'Verbose',      str.Verbose, ...
    'VerboseLabel', str.VerboseLabel, ...
    'StdOut',       str.StdOut, keyVals{:});



end