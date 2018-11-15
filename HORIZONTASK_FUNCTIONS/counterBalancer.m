function [var, T, N] = counterBalancer(var, R)
% [var, T, N] = counterBalancer(var, R)
% R = number of repeats
% var(i).x    = values of variable i to be considered
% var(i).type = 1 - fully counterbalance
%             = 2 - random counterbalance
%             = 3 - fully random (not implemented yet)
% NOTE : THIS DOES NOT YET HANDLE MULTIDIMENSIONAL VARIABLES
% Robert Wilson
% 15-Aug-2011
% get type 1 variables to fully counterbalance over
ind1 = find([var.type] == 1);
for i = 1:length(ind1)
    L(i) = length(var(ind1(i)).x);
end
% total number of trials per cycle
N = prod(L);
T = N*R;
% counterbalance all type 1 variables - this could probably be more elegant!
str = 'ndgrid(';
k = length(ind1);
for i = 1:k
    str = [str 'var(ind1(' num2str(i) ')).x'];
    if i < k
        str = [str ', '];
    else
        str = [str ');'];
    end
end

str2 = '[';
for i = 1:k
    str2 = [str2 'cb{' num2str(i) '}'];
    if i < k
        str2 = [str2, ', '];
    else
        str2 = [str2 ']'];
    end
end

str3 = [str2 ' = ' str];

eval(str3);

for i = 1:length(ind1)
    var(ind1(i)).x_cb = repmat(cb{i}(:)', [1 R]);
end

r = randperm(length(var(ind1(1)).x_cb));
for i = 1:length(ind1)
    var(ind1(i)).x_cb = var(ind1(i)).x_cb(r);
end

% randomly mix up all type 2 variables
ind2 = find([var.type] == 2);
for i = 1:length(ind2)
    var(ind2(i)).x_rep = repmat(var(ind2(i)).x, ...
        [1 ceil(T/length( var(ind2(i)).x ))]);
    r = randperm(length(var(ind2(i)).x_rep));
    var(ind2(i)).x_cb = var(ind2(i)).x_rep(r(1:T));
end

