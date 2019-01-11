all clear;
clc;
clf;
d1 = 15;
d2 = 30;
a = 3;
thres = 5;
% �ֱ���ú���find_noma1_min_outage��find_noma2_min_outage��find_oma_min_outage������Ӧ���������С�жϸ���
% �����ʷ���
x_axis = zeros(8,1);
out_noma_1 = zeros(1,8);
out_noma_2 = zeros(1,8);
out_oma = zeros(1,8);

% ����find_noma1_min_asymp���㽥����������С�жϸ���
out_noma_1_asymp = zeros(1,8);
for loop = 1:8
    %������
    x_axis(loop) = loop*5+50;
    sigma= 10^(-(loop*5+50)/10);  %����������Ϊ51dB��90dB
    [outage1,~] = find_noma1_min_outage(sigma,d1,d2,a,thres);
%     [outage2,~] = find_noma2_min_outage(sigma,d1,d2,a,thres);
%     [outage_oma,~] = find_oma_min_outage(sigma,d1,d2,a,thres);
    [outage_1_asymp,~] = find_noma1_min_asymp(sigma,d1,d2,a,thres);
    position = 2/3*ones(4,1);
    outage_oma = OMA_outage(sigma,d1,d2,a,thres,position);
    
    out_oma(loop) = outage_oma;
    out_noma_1(loop) = outage1;
%     out_noma_2(loop) = outage2;
    out_noma_1_asymp(loop) = outage_1_asymp;
end
semilogy(x_axis,out_noma_1,'b-*','LineWidth',2,'MarkerSize',10);hold on;grid on;
% semilogy(x_axis,out_noma_2,'r','LineWidth','2','MarkerSize','10');
semilogy(x_axis,out_oma,'r-*','LineWidth',2,'MarkerSize',10);
semilogy(x_axis,out_noma_1_asymp,'c--*','LineWidth',2,'MarkerSize',10);
legend('NOMA1','OMA','NOMA1-asymp');
ylabel('Outage probability(%)');
xlabel('Transmitter SNR(dB)');
    