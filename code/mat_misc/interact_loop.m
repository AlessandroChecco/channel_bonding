function interact_loop{CHECK_EVERY,vector_loop, varargin}
% call this function as a wrapper in your simulation instead of a long for loop
% pass the function call with "i" inside
% touch debug to interrupt simulation and enter in interactive mode
% to resume return (dont forget to temporarily rename or remove the file).
% In order to exit, use dbquit

tic
for i=vector_loop
    if rem(i,CHECK_EVERY) == 0 && exist('debug','file')
        fprintf('%f seconds since last time.\n', toc)
        keyboard
        tic
    end

eval(varargin);
end

end
