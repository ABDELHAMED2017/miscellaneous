function [outage,position] = find_noma3_min_max(sigma,d1,d2,a,thres)

% ������minmax�����µĵ�����NOMA�����жϸ��ʼ���ѹ��ʷ���

% d1 = 15;
% d2 = 30;
% a = 3;
% thres = 5;
% sigma = 1/10^5;

position = zeros(1,4);
% ��һ��ʱ϶
% �Ƚ��x3���ٽ��x1
fun1 = @(x)[1 - exp(sigma*thres*d2^a/(thres*x+x-1));...
    1 - exp(-1*sigma*thres*d1^a/x)];
      

x0 = 0.1;
lb = 0 + sigma;
ub = 1/(1+thres)-sigma;
[x,fval1] = fminimax(fun1,x0,[],[],[],[],lb,ub);

position(1) = x;
position(3) = 1 - x;

% �ڶ���ʱ϶
fun2 = @(x)[1 - exp(sigma*thres*d2^a/(thres*x+x-1));...
    1 - exp(-1*sigma*thres*d2^a/x)];
      

x0 = 0.1;
lb = 0 + sigma;
ub = 1/(1+thres)-sigma;
[x,fval2] = fminimax(fun2,x0,[],[],[],[],lb,ub);

position(2) = x;
position(4) = 1 - x;

outage = 0.5*(max(fval1) + max(fval2));
