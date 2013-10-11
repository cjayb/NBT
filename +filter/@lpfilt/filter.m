function [x, obj] = filter(obj, x, varargin)
% FILTER - Digital filtering operation
%
% x = filter(obj, x)
%
% where
%
% OBJ is a filter.lpfilt object
%
% X is the KxM data matrix to be filtered. X can be a numeric data matrix
% or an object of any class with suitably overloaded subsref and subsasgn
% operators.
%
% See also: hpfilt, bpfilt


import misc.eta;

verboseLabel = get_verbose_label(obj);
verbose      = is_verbose(obj);

if verbose,
    if isa(x, 'pset.mmappset'),
        name = get_name(x);
    else
        name = '';
    end
    fprintf([verboseLabel 'LP-filtering %s...'], name);
    tinit = tic;
    by100 = floor(size(x,1)/100);
    clear +misc/eta;
end

for i = 1:size(x, 1)
    if (isa(obj, 'physioset.physioset') && obj.BadChan(i)),
        continue;
    end
    x(i, :) = filter(obj.H, x(i,:));
    if verbose && ~mod(i, by100),
        eta(tinit, size(x,1), i, 'remaintime', false);
    end
end
if verbose,
    fprintf('\n\n');
end

