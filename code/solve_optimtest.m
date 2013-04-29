function [p T channel_lexic allocations p2] = solve_optimtest(N,c,T,allocations, channel_lexic)
% p = solve_optim(N,C,T,allocations, channel_lexic)
% N is the number of stations
% C is the number of real channels (excluding dummy)
% the ~of original channels
% T is a matrixthat gives the throughput for each station, given a p
% p is a matrix: each column refer to one basestation
if nargin == 2
    [T channel_lexic allocations oldT olda] = throughput(N,c);
end


% T = T+eps;

C = size(allocations,1);
fprintf('\n')
disp('-------------------------------START-------------------------------')
disp(['Solving problem with: '])
disp([num2str(N) ' BSSs, ' num2str(c) ' channels.' ])
disp(['Each basestations has ' num2str(2^c) ' possible choices (including no transmission)'])
disp(['The system has ' num2str(C) ' total combinations'])

cc = numel(channel_lexic);

cvx_begin
    variable p(cc,N) % each column is a bss
    for i=1:N
        p2(:,i) = p(allocations(:,i),i);
    end
%     size(allocations)
     %good maximize ( sum(log(sum(repmat(p,1,N)'.*T,2))  ) ) 
% bad maximize ( sum(p'.*sum(log(T),1))   ) 
maximize ( sum(log(sum(p2'.*T,2))  ) ) 
    subject to
    p >= 0
    p' * ones(cc,N) <= 1
cvx_end
disp(p2)
return
policies_index = find(p>10e8*eps)';

for i=1:numel(policies_index)
    for j=i+1:numel(policies_index)
        ii = policies_index(i);
        jj = policies_index(j);
        if isequal(T(:,ii),T(:,jj)) && p(ii)>10e8*eps
            p(jj) = p(jj) + p(ii);
            p(ii) = 0;
        end
    end
end
policies_index = find(p>10e8*eps)';

disp('SOLUTION (it is not unique)')
if numel(policies_index) < 20
    for i=policies_index
        disp(['spending ' num2str(p(i)) ' of the time in' ])
        for j=1:N
           disp(['channels [' num2str(channel_lexic(allocations(i,j)).index) '] for node ' num2str(j) ])
       end
       disp(['throughput of this chunk: ' num2str(sum(T(:,i)')/1e6) ' Mb/s.   (' num2str(T(:,i)'/1e6) ')' ])
       disp('----------------------------------------------')
    end
else
    disp('Too many chunks. Will show only total throughput')
end
disp(['Total throughput: ' num2str(sum(p(policies_index)'.*sum(T(:,policies_index)))/1e6) ' Mb/s']);
disp(T(:,policies_index)/1e6)
disp('----------------------------------------------')
disp('----------------------------------------------')
disp('----------------------------------------------')
disp('----------------------------------------------')
disp('COMPARISON with standard 802.11, stations using a single channel (evenly')
disp('           distributed amongst the channels available)')
for i=1:N
    ch(i) = mod(i-1,c) + 2;
    disp(['User ' num2str(i) ' uses channel ' num2str(ch(i)-1) ' all the time'])
end

all802 = find(all(bsxfun(@eq,olda,ch),2)); %find allocations that correspond
disp(['Total throughput of legacy: ' num2str(sum(sum(oldT(:,all802)))/1e6) ' Mb/s']);
disp(oldT(:,all802)/1e6)
disp('-------------------------------END---------------------------------')
fprintf('\n')