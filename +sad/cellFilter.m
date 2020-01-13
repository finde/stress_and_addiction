function [outputArg1] = cellFilter(column, groupData, isNegate)
%FILTER Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    isNegate = false;
end

outputArg1 = cellfun(@(x) ismember(x, groupData), column, 'UniformOutput', 1);

disp(isNegate)
if isNegate == true
    outputArg1 = ~outputArg1;
end
    
end

