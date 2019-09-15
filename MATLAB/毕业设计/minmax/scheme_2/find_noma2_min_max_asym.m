function [outage,position] = find_noma2_min_max_asym(sigma,d1,d2,a,thres)

% ������minmax�����µĵڶ���NOMA�����жϸ��ʼ���ѹ��ʷ���

% d1 = 15;
% d2 = 30;
% a = 3;
% thres = 5;
% sigma = 1/10^5;


fun = @(x)[-1*sigma*thres*d2^a/(thres*x(1)+x(1)-1);...
    sigma*thres*d1^a/x(1)];
          

x0 = [0.1;0.1];
lb = [0+sigma;0+sigma];
ub = [1/(1+thres)-sigma;1/(1+thres)-sigma];
[x,fval] = fminimax(fun,x0,[],[],[],[],lb,ub);

outage = max(fval);
position = x;

