widths = [1 2];
C = 4;
for N=2:8
[T channel_lexic allocations oldT olda] = throughput(N,C,widths);
[p ps T channel_lexic allocations] = solve_optim(N,C,T,allocations, channel_lexic,oldT, olda);
save(['small_sim' num2str(N)])
end