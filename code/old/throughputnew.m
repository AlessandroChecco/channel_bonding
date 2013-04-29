function [T channel_lexic allocations oldT olda] = throughputnew(N,C,widths)
% [T channel_lexic allocations] = throughput(N,C)

isequalRel = @(x,y,tol) ( abs(x-y) <= ( tol*max(abs(x),abs(y)) + eps) );
isequalAbs = @(x,y,tol) ( abs(x-y) <= tol );

if nargin  == 2
    widths = 2.^([0:3]);
end
    channel_lexic = create_channel(widths);
    
allh = nextstring(max_element,N);
% allocations = combinator(int8(max_element),N); %change ** TODO with nextcomb or nextchoose
    
%T(i,j) represent the throughput of station i when using channel allocation j

through = memoize(@BSSThroughput); % avoid to recompute same values over and over
% comb = memoize(@combinator);
% check_inters = @(a,b) ~isempty(intersect(a,b));
combs = combinator(N,2,'c');

    function out = check_inters(a,b)
        out = ~isempty(intersect(channel_lexic(a).index,channel_lexic(b).index));
    end
T = zeros(N,max_element);
count = 0;
mmm = max_element^N;
for iii = 1:mmm
    progress(iii,mmm); % display the progress
    count = count + 1;
    allocation = allh();
    allocations(count,:) = allocation;
    N_Ov = zeros(N,N);
    for j=1:size(combs,1)
                BSS1 = combs(j,1);
                BSS2 = combs(j,2);
                N_Ov(BSS1,BSS2) = ~isempty(intersect(channel_lexic(allocation(BSS1)).index,channel_lexic(allocation(BSS2)).index));
                %hlp_microcache('cachedintersect',@check_inters,BSS,j); %sum one if they overlap *memoize this, maybe putting variable in a temp is needed
                N_Ov(BSS2,BSS1) = N_Ov(BSS1,BSS2);
    end
    for BSS=1:N
          if sum(N_Ov(BSS,:)) > 0
            T(BSS, count) = 0; %put this on temp!
          else
              %disp (channel_lexic(allocations(allocation,BSS)).width)
%               disp(channel_lexic(allocations(allocation,BSS)).index)
              T(BSS,count) = through(channel_lexic(allocation(BSS)).width); %put this on temp!
          end
    end
    for i = 1:count-1
        if isequal(T(:,count),T(:,i))%isequalAbs(T(:,count),T(:,i),1e-8)
            T(:,count) = []; %nooooooooooooo
            allocations(count,:) = [];
            count = count -1;
            break;
        end
    end
            
end


[qq ii jj] = unique(T','rows','first');
T = qq';
allocations = allocations(ii,:);

if nargout > 4
olda = allocations;
oldT = T;
end


toremove = find(all(bsxfun(@eq,T,zeros(N,1))));
allocations(toremove,:) = [];
T(:,toremove) = [];

    function channel_lexic = create_channel(varargin)
        if nargin < 1
            widths = 2.^([0:3]);
        else
            widths = varargin{1};
        end
    max_element = 1; %fix this 2^C
    channel_lexic = set_struct('channel_lexic','width',zeros(1,max_element));
    channel_lexic(max_element).index = [];
    channel(C).index = -1;
    channel(C).number = -1;
    element = 1;
    for width = widths
        channel(width).index = generate_continguous(width);
        channel(width).number = size(channel(width).index,1);
        for j = 1:channel(width).number
            element = element + 1;
            channel_lexic(element).index = channel(width).index(j,:);
            channel_lexic(element).width = width;
        end
    end
    
        function out = generate_continguous(width)
            %generate contiguous combinations given a certain width
            for i=1:C-width
                out(i,:) = i:i+width-1;
            end
        end
        
%         disp('to fix')
%     disp(numel(channel_lexic))
%         i = 1;
%     while i < numel(channel_lexic) %REMOVE NON CONTIGUOUS
%         if  ((max(diff(channel_lexic(i).index)) > 1) | (isempty(channel_lexic(i).index)) )
%           %  disp([ 'removed' num2str(channel_lexic(i).index)])
%             channel_lexic(i) = [];
%         else
%             i = i+1;
%         end
%     end
% disp('done')
    max_element = numel(channel_lexic);
    end

    function S=BSSThroughput(W)
    % N_Ov how many  stations on same channel
%     if N_Ov > 1
%         S = 0;
%         return
%     end
        if W == 0
            S= 0;
            return
        end
    M=1;
    L=12000;
    A=1;

    Ts=Ts80211ac(M,L,A,3/4,6,W*52,M,1);

    SLOT = 9E-6;   

    S=L/(15.5*SLOT+Ts);




    function TxD = Ts80211ac(s,L,N,Coding,Mod,subcarriers,M,Ng)

    SIFS = 16E-6;
    DIFS = 34E-6;
    SLOT = 9E-6;  
    Ts=4E-6;

	PHY_h_MU=    8E-6 + 8E-6 + 4E-6 + 8E-6 + 4E-6 + M*4E-6 + 4E-6;
	PHY_h=       8E-6 + 8E-6 + 4E-6 + 8E-6 + 4E-6 + 4E-6 + 4E-6;

%	CSI_feedback = ceil(16*M*234/Ng);
    CSI_feedback = 0;
	MU_RTS = 20*8+(M-1)*6*8;
	MU_CTS = 14*8+CSI_feedback; 
	
	MAC_h=36*8;
	FCS=4*8;

	MPDU_Del=4*8;
	BACK=32*8; 

	MPDU=MAC_h+L+FCS;

	ServiceField=16; 
	Tail_bits=6;

	PSDU = -1;


	if(N==1) PSDU = ServiceField + MPDU + Tail_bits;
	else PSDU = ServiceField + N*(MPDU_Del+MPDU) + Tail_bits;
    end
        
	TxPSDU = PHY_h_MU+ceil(PSDU/(subcarriers*Mod*Coding))*Ts;

	PSDU_RTS = ServiceField + MU_RTS +Tail_bits;
	PSDU_CTS = ServiceField + MU_CTS +Tail_bits;
	PSDU_BAK = ServiceField + BACK +Tail_bits;

	TxRTS = PHY_h_MU+ceil(PSDU_RTS/(subcarriers*Mod*Coding))*Ts;
	TxCTS = PHY_h+ceil(PSDU_CTS/(subcarriers*Mod*Coding))*Ts;
	TxBAK = PHY_h+ceil(PSDU_BAK/(subcarriers*Mod*Coding))*Ts;

	TxD = TxPSDU+s*(SIFS+TxBAK)+DIFS+SLOT;

    end
end
    

end
