% �ڶ���NOMA�����������жϸ����������ʶԱ�
clc;
clf;
all clear;
d1 = 10;
d2 = 20;
a = 3;        %·�����ָ��

thres = 5;      %���������
p1 = 0.15;
p2 = 0.85;

%�����ź�
x1 = ones(1,10000);
x2 = ones(1,10000);


%�����ŵ�
h11 = sqrt(0.5)*(randn(1,10000)+1j*randn(1,10000));
h12 = sqrt(0.5)*(randn(1,10000)+1j*randn(1,10000));


out_total = zeros(1,30);
out_analysis = zeros(1,30);


for loop=1:30
    sigma = 10^(-loop/10)/20^a;      %��������
    %����ֵ
    % �û������жϸ���
    y1 = sqrt(p1)*d2^(-0.5*a)*(h12.*x1);
    y1 = abs(y1);
    y2 = sqrt(p2)*d2^(-0.5*a)*(h12.*x2);
    y2 = abs(y2);
    out1 = sum(y2.^2<thres*(y1.^2+sigma))/10000;
    
    % �û�һ���жϸ���
     y3 = sqrt(p1)*d1^(-0.5*a)*(h11.*x1);
     y3 = abs(y3);
    out2 = sum(y3.^2<thres*sigma)/10000;
    
    out_total(loop) = out1+out2;
    
    %����ֵ
    p_total1 = 1 - exp(-1*sigma*thres*d1^a/p1);
    p_total2 = 1 - exp(sigma*thres*d2^a/(thres*p1-p2));
    out_analysis(loop) = p_total1 + p_total2;
    
end

figure(1);
semilogy(out_total,'*'),hold on;
semilogy(out_analysis,'r');
legend('Simulation','Analysis');
ylabel('Outage probability');
xlabel('SNR');
