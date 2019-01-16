dt = 5*10^6;      %ÿ���û�һ֡���������������1Mbits
rate_noma = 20*10^6;        %�������ʣ�20Mbits/s
rate_oma = 20*10^6;         %
time_duration = 0.01;       %ʱ϶���ȣ�10ms

t_noma = zeros(1,8);
t_oma = zeros(1,8);
x_axis = zeros(1,8);
for loop = 1:8
    r = loop/8;
    x_axis(loop) = r;
    if r<=0.5
        t_n = ceil((2*dt*r/rate_noma+dt*(1-2*r)/rate_noma)/time_duration);
    else
        t_n = ceil((2*dt*(1-r)/rate_noma+dt*(2*r-1)/rate_noma)/time_duration);
    end
    t_noma(loop) = t_n;
    t_oma(loop) = ceil((2*dt*(1-r)/rate_oma+dt*r/rate_oma)/time_duration);
end
plot(x_axis,t_noma,'b-*','LineWidth',2,'MarkerSize',10),hold on;
plot(x_axis,t_oma,'r-*','LineWidth',2,'MarkerSize',10);
xlabel('�ص��������(%)');
ylabel('ʱ϶��');
legend('NOMA','OMA');