function [points] = create_grid(N, range)
% Given a number of points, this function creates a grid to dispose the
% points. Range is optional ([0,1] if not specified).

if nargin < 2
    range = [0 1];
end

x = linspace(range(1),range(2),ceil(sqrt(N)));
y = linspace(range(1),range(2),ceil(sqrt(N)));
[y,x] = meshgrid(x,y);
points = [x(:) y(:)];