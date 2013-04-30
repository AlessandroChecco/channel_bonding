function displayresults(filename,precision, max_chunks,p,N,channel_lexic,allocations,T,c,olda,oldT,ps)
if ~isempty(filename)
    load(filename)
end

    policies_index = find(p>precision)';
disp('-------------------------------START-------------------------------')
disp([num2str(N) ' BSSs, ' num2str(c) ' channels.' ])
disp(['Each basestations has ' num2str(numel(channel_lexic)) ' possible choices (including no transmission)'])
disp(['The system has ' num2str(C) ' total combinations'])
    disp('SOLUTION (it is not unique)')
    if numel(policies_index) < max_chunks
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
    fprintf('\n\n')
    disp('----------------------------------------------')
    disp('COMPARISON with standard 802.11, stations using a single channel (evenly')
    disp('           distributed amongst the channels available)')
    for i=1:N
        ch(i) = mod(i-1,c) + 2;
        disp(['User ' num2str(i) ' uses channel ' num2str(ch(i)-1) ' all the time.'])
    end
    all802 = find(all(bsxfun(@eq,olda,ch),2)); %find allocations that correspond
    disp(['Total throughput of legacy: ' num2str(sum(sum(oldT(:,all802)))/1e6) ' Mb/s']);
    disp(oldT(:,all802)/1e6)
    disp('-------------------------------------------------------------------')
    fprintf('\n')
    if c==19 && ~exist(['solution' num2str(N) '.mat'],'file')
        save(['solution' num2str(N) '.mat'])
    end
    
        disp('--------------------------PER BSS POLICY---------------------------')
    
    %channel_index = find(ps>precision);
    for i=1:N
        fprintf('\n')
        disp(['BSS ' num2str(i) ' will spend:' ])
        for j=find(ps(:,i)>precision)'
            disp([num2str(ps(j,i)) ' of the time on channel ' num2str(channel_lexic(j).index)])
        end
    end
        disp('-------------------------------END---------------------------------')
end