function [p ps T channel_lexic allocations] = solve_optim(N,c,T,allocations, channel_lexic,oldT, olda)
% p = solve_optim(N,C,T,allocations, channel_lexic)
% N is the number of stations
% C is the number of real channels (excluding dummy)
% the ~of original channels
% T is a matrixthat gives the throughput for each station, given a p
% p is a matrix: each column refer to one basestation
if nargin == 2
    if c==19 && exist(['throughput' num2str(N) '.mat'],'file')
        disp('loading file...')
        load(['throughput' num2str(N) '.mat'],'T')
        load(['throughput' num2str(N) '.mat'],'channel_lexic')
        load(['throughput' num2str(N) '.mat'],'allocations')
        load(['throughput' num2str(N) '.mat'],'oldT')
        load(['throughput' num2str(N) '.mat'],'olda')
        fprintf('done!')
    else
        [T channel_lexic allocations oldT olda] = throughput(N,c);
        save(['throughput' num2str(N) '.mat'])
    end
end


% T = T+eps;

C = size(allocations,1);
fprintf('\n')
disp('-------------------------------START-------------------------------')
disp(['Solving problem with: '])
disp([num2str(N) ' BSSs, ' num2str(c) ' channels.' ])
disp(['Each basestations has ' num2str(numel(channel_lexic)) ' possible choices (including no transmission)'])
disp(['The system has ' num2str(C) ' total combinations'])

% cc = numel(channel_lexic);



cvx_begin
%     cvx_precision best
    variable p(C)
    maximize ( sum(log(sum(repmat(p,1,N)'.*T,2))  ) ) 
    % bad maximize ( sum(p'.*sum(log(T),1))   ) 
    %test maximize ( sum(log(sum(p(allocations)'.*T,2))  ) ) 
    subject to
    p >= 0
    p' * ones(C,1)  == 1
cvx_end

% create corresponding per station probability
ps = zeros(numel(channel_lexic),N);
for i=1:N
    for j=1:size(allocations,1)
        ps(allocations(j,i),i) =  ps(allocations(j,i),i) + p(j);
    end
end
displayresults([],1e-2,30,p,N,channel_lexic,allocations,T,c,olda,oldT,ps)

end 
