all clear;
clc;
clf;
d1 = 15;
d2 = 30;
a = 3;
thres = 5;
% �ֱ���ú���find_noma1_min_outage��find_noma2_min_outage��find_oma_min_outage������Ӧ���������С�жϸ���
% �����ʷ���
x_axis = zeros(1,8);
out_noma_1 = zeros(1,8);
out_noma_2 = zeros(1,8);
out_oma = zeros(1,8);
% OMA���õȹ��ʷ���
position = 2/3*ones(1,4);
% ����find_noma1_min_asymp���㽥����������С�жϸ���
out_noma_1_asymp = zeros(1,8);

% �ɴ����ʶԱ�
rate_noma_1 = zeros(1,8);
rate_noma_2 = zeros(1,8);
rate_noma_1_asymp = zeros(1,8);
rate_oma = zeros(1,8);

for loop = 1:8
    %������
    x_axis(loop) = loop*5 + 50;
    sigma= 10^(-(loop*5 + 50)/10);  %����������Ϊ55dB��90dB
    
    % �жϸ��ʶԱ�
    [outage1,position1] = find_noma1_min_outage(sigma,d1,d2,a,thres);
    [outage2,position2] = find_noma2_min_outage(sigma,d1,d2,a,thres);
    % [outage_oma,~] = find_oma_min_outage(sigma,d1,d2,a,thres);
    outage_oma = OMA_outage(sigma,d1,d2,a,thres,position);
    [outage_1_asymp,position3] = find_noma1_min_asymp(sigma,d1,d2,a,thres);
%     position = 2/3*ones(4,1);
%     outage_oma = OMA_outage(sigma,d1,d2,a,thres,position);
    out_oma(loop) = outage_oma;
    out_noma_1(loop) = outage1;
    out_noma_2(loop) = outage2;
    out_noma_1_asymp(loop) = outage_1_asymp;
    
    % ƽ���ɴ����ʶԱ�
    p1 = 1 - position1(1);
    p2 = 1 - position1(2);
    p3 = position1(1);
    p4 = position1(2);
    rate_noma1 = 0.5*(log2(1+p1/(p3+d1^a*sigma)) + log2(1+(p3+p4)/(d1^a*sigma)) + log2(1+p2/(p4+d2^a*sigma)) + log2(1+(p3+p4)/(d2^a*sigma)));
    
    p1 = 1 - position3(1);
    p2 = 1 - position3(2);
    p3 = position3(1);
    p4 = position3(2);
    rate_noma3 = 0.5*(log2(1+p1/(p3+d1^a*sigma)) + log2(1+(p3+p4)/(d1^a*sigma)) + log2(1+p2/(p4+d2^a*sigma)) + log2(1+(p3+p4)/(d2^a*sigma)));
    
    p1 = position2(1);
    p2 = position2(2);
    rate_noma2 = 0.5*(log2(1+p1/(d1^a*sigma)) + log2(1+p2/(p1+d2^a*sigma)) + 0.5*(log2(1+1/(d1^a*sigma)) + log2(1+1/(d2^a*sigma))));
   
    
    rate_oma_temp = 0.5*(log2(1+d1^(-a)/sigma) + log2(1+d2^(-a)/sigma));
    
    rate_noma_1(loop) = rate_noma1;
    rate_noma_1_asymp(loop) = rate_noma3;
    rate_noma_2(loop) = rate_noma2;
    rate_oma(loop) = rate_oma_temp;
    
end
figure(1)
semilogy(x_axis,out_noma_1,'b-*','LineWidth',2,'MarkerSize',10),hold on;grid on;
semilogy(x_axis,out_noma_2,'g-*','LineWidth',2,'MarkerSize',10);
semilogy(x_axis,out_oma,'r-*','LineWidth',2,'MarkerSize',10);
semilogy(x_axis,out_noma_1_asymp,'c--*','LineWidth',2,'MarkerSize',10);
legend('NOMA1','NOMA2','OMA','NOMA-asymp');
ylabel('Outage probability(%)');
xlabel('SNR(dB)');
% title('��ͬ�����Ա�');
figure(2)
plot(x_axis,rate_noma_1,'b-*','LineWidth',2,'MarkerSize',10),hold on;grid on;
plot(x_axis,rate_noma_2,'g-*','LineWidth',2,'MarkerSize',10);
plot(x_axis,rate_oma,'r-*','LineWidth',2,'MarkerSize',10);
plot(x_axis,rate_noma_1_asymp,'c--*','LineWidth',2,'MarkerSize',10);
legend('NOMA1','NOMA2','OMA','NOMA-asymp');
ylabel('Average Achievable Rate(bit/s/Hz)');
xlabel('SNR(dB)');