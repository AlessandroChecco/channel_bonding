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

precision = 1e-2;
% policies_index = find(p>0)';
% for i=1:C
%     progress(i,C)
%     for j=i+1:C
% %         ii = policies_index(i);
% %         jj = policies_index(j);
%         if isequal(T(:,i),T(:,j)) %&& p(ii)>precision
%             p(j) = p(j) + p(i);
%             p(i) = 0;
%         end
%     end
% end
% fprintf('\n')
policies_index = find(p>precision)';

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

% create corresponding per station probability
ps = zeros(numel(channel_lexic),N);
for i=1:N
    for j=1:size(allocations,1)
        ps(allocations(j,i),i) =  ps(allocations(j,i),i) + p(j);
    end
end


all802 = find(all(bsxfun(@eq,olda,ch),2)); %find allocations that correspond
disp(['Total throughput of legacy: ' num2str(sum(sum(oldT(:,all802)))/1e6) ' Mb/s']);
disp(oldT(:,all802)/1e6)
disp('-------------------------------END---------------------------------')
fprintf('\n')
if c==19 && ~exist(['solution' num2str(N) '.mat'],'file')
    save(['solution' num2str(N) '.mat'])
end

end