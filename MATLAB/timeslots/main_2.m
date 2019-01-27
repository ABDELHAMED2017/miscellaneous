dt = 20*10^6;        % ÿ���û�һ֡���������������10Mbits
B = 20*10^6;        % �ŵ�����
d1 = 15;            % �û�1�����վ����
d2 = 30;            % �û�2�����վ����
thres = 5;          % ��������
a = 3;              % ·�����ָ��
sigma = 1/10^9;     % ��������
time_duration = 0.01;       %ʱ϶���ȣ�10ms

t_noma = zeros(1,11);
t_oma = zeros(1,11);
x_axis = zeros(1,11);
for loop = 1:11
    r = (loop-1)/10;
    x_axis(loop) = r;
    
    r11_oma = B*log2(1+1/(d1^a*sigma));
    r22_oma = B*log2(1+1/(d2^a*sigma));
    r3_oma = min(r11_oma,r22_oma);
    time_oma = dt*(1-r)/r11_oma + dt*(1-r)/r22_oma + dt*r/r3_oma;
    t_oma(loop) = time_oma;
    
    [r11,r13,r22,r23] = find_rate(B,sigma,d1,d2,a,thres);
    r3 = min(r13,r23);
    % ��һ�׶Σ�x1��x3���ӣ�x2��x3����
    t11 = dt*(1-r)/r11;
    t22 = dt*(1-r)/r22;
    t3 = dt*r/r3;
    t_common = min([t11,t22,t3]);     %��������ʱ��1
    
    % ����t_common�Ĵ�С���ֱ��жϽ������Ĵ��䷽��
    
    % x3�����ܴ���
    if t_common == t3
        x1_remain = dt*(1-r)-r11*t_common;
        x2_remain = dt*(1-r)-r22*t_common;
        %֮��ȫ������������ʽ����
        t_2 = x1_remain/r11_oma;
        t_3 = x2_remain/r22_oma;
        
    elseif t_common == t11
        % x1�����ܴ���
        x3_remain = dt*r-r3*t_common;
        x2_remain = dt*(1-r)-r22*t_common;
       %֮��ȫ������OMA����
       t_2 = x2_remain/r22_oma;
       t_3 = x3_remain/r3_oma;
        
    else
        % x2�ܴ���
        x3_remain = dt*r-r3*t_common;
        x1_remain = dt*(1-r)-r11*t_common;
        %֮��ȫ������OMA����
        t_2 = x1_remain/r11_oma;
        t3 = x3_remain/r3_oma;
    end
    time_slots = (2*t_common) + (t_2) + (t_3);
    t_noma(loop) = time_slots;  
    
    
    
end
plot(x_axis,t_noma,'b-*','LineWidth',2,'MarkerSize',10),hold on;
plot(x_axis,t_oma,'r-*','LineWidth',2,'MarkerSize',10);
xlabel('�ص��������(%)');
ylabel('����ʱ��');
legend('NOMA','OMA');