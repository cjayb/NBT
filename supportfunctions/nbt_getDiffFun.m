
function DiffFunH=nbt_getDiffFun(DiffFun)
switch DiffFun
    case 'regular'
        DiffFunH = @(d1,d2) d1-d2;
    case 'absolute'
        DiffFunH = @(d1,d2) abs(d1-d2); % abs difference
    case 'squared'
        DiffFunH = @(d1,d2) (d1-d2).^2; % square difference
end
end