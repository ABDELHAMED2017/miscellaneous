% �ڶ���NOMA�������жϸ�������
all clear;
clc;
clf;
d1 = 15;
d2 = 30;
a = 3;
sigma = 1/10^6;
thres = 5;
p1 = 0:0.0001:1/(1+thres);
p_out = 2 - exp(-1*d1^a*thres*sigma./p1) - exp(d2^a*thres*sigma./(p1*thres+p1-1));
p_out2 = 2 - exp(-1*d1^a*thres*sigma) - exp(-1*d2^a*thres*sigma);
plot(p1,p_out);
% ������Сֵ
[M,I] = min(p_out(:));
[I_row, I_col] = ind2sub(size(p_out),I);
p1_min = p1(I_col);
fprintf('��СֵΪ��%0.6f\n',M + p_out2);
fprintf('λ��P1 = %0.3f, P2 = %0.3f\n',p1_min,1-p1_min);
