function index = cycle(i,N)
% return the index cycling through an array of length N
index = mod(i-1,N)+1;