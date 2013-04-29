function RConvergence = Test1(W,SSat)

MaxBasicChannels=19;
MaxBSSs = 15;
%W=2;

MaxIter=1000;
MaxTests=10;

RConvergence = zeros(1,MaxBSSs);  
RS = zeros(1,MaxBSSs);

% Enable the reduction of W.
Amax=floor(MaxIter/W);
% Disable the reduction of W.
%Amax=2*MaxIter;

for N=1:MaxBSSs 
    
    %S_min = max(1,W);
    S_min = BSSThroughput(SSat,1); %Alex comparing it with what?
    %S_min = SSat;
    
    Convergence=-1*ones(1,MaxTests);
    S_test = zeros(1,MaxTests);

    for t=1:MaxTests

        BSS_Sat = zeros(1,N);
        Ws = W.*ones(1,N);
        a = zeros(1,N);
        w = zeros(1,N);	
        p = zeros(1,N);	
        S = zeros(1,N);

        for i=1:MaxIter
            OvChannels = zeros(1,MaxBasicChannels);
            Channels = zeros(N,MaxBasicChannels);
            OvBSS = zeros(1,N);
            for n=1:N
                if(BSS_Sat(n) == 0)
                    if(a(n)==Amax)
                        Ws(n)=max(SSat,Ws(n)-1); % Alex Is SSat a throughput threshold? Why do we put here in comparison with the frequency?
                        a(n)=0;
                    end
                    w(n)=Ws(n);	
 
                    p(n)=ceil((MaxBasicChannels-w(n)+1)*rand);
                    a(n)=a(n)+1;
                end

                for j=0:w(n)-1
                    Channels(n,p(n)+j)=1;
                    OvChannels(p(n)+j)=OvChannels(p(n)+j)+1;
                end
            end
       

            for n=1:N		
                for j=1:MaxBasicChannels
                    if(Channels(n,j)==1)
                        OvBSS(n)=max(OvBSS(n),OvChannels(j));
                    end
                end
                %S(n)=w(n)/OvBSS(n); % Assuming they share the time proportionally
                S(n)=BSSThroughput(w(n),OvBSS(n));
                %disp([N i n S(n) S_min]);
                %pause
                if(S(n) >= S_min)
                    BSS_Sat(n)=1;
                else
                    BSS_Sat(n)=0;
                end	
            end	
            
            S_test(t)=sum(S);

            if(sum(BSS_Sat)==N)
                
                %disp('-----------------------');	
                %disp(OvBSS);
                %disp('-----------------------');
                %disp(S);	
                %disp('-----------------------');
                %disp(BSS_Sat);	
                %pause
                %disp(Ws);
			
                Convergence(t) = i;
                break;
            else
                Convergence(t)=inf;
            end
		
        end
    end
  
    RS(N)=mean(S_test);
    disp(RS(N));
    RConvergence(N)=mean(Convergence);
    %pause
end

%figure
%plot([1 MaxBasicChannels],RConvergence);

figure
plot(RS./1E6,'ko-','MarkerSize',8);
xlabel('BSSs','fontsize',14);
ylabel('Overall Throughput (Mbps)','fontsize',14);
axis([1 MaxBSSs 0 400]);
grid

%disp(RS');
%disp(RConvergence);

function S=BSSThroughput(W,N_Ov)

M=1;
L=12000;
A=1;

Ts=Ts80211ac(M,L,A,3/4,6,W*52,M,1);

SLOT = 9E-6;   

S=L/(15.5*SLOT+Ts);
S=S/N_Ov;
%disp([S W N_Ov]);
%pause



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




