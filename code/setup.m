function setup()
    cd cvx
    cvx_setup
    cd ..
    addpath('mat_misc')
    addpath_recurse('mat_misc')
    disp('Use savepath to keep installation at next Matlab run')
end