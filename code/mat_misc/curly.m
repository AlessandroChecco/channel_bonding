function out =  curly(x, varargin)
% allow to index the output of another function
    out = x{varargin{:}};
end