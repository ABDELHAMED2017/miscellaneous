dt = 1*10^6;        % ÿ���û�һ֡���������������1Mbits
B = 1.4*10^6/72;       % �ŵ�����
d1 = 20;            % �û�1�����վ����
d2 = 40;            % �û�2�����վ����
thres = 5;          % ��������
a = 3;              % ·�����ָ��
sigma = 1/10^8;     % ��������
time_duration = 0.01;       %ʱ϶���ȣ�10ms

t_noma = zeros(1,11);
t_oma = zeros(1,11);
x_axis = zeros(1,11);
r11_oma = B*log2(1+1/(d1^a*sigma));
r22_oma = B*log2(1+1/(d2^a*sigma));
r3_oma = min(r11_oma,r22_oma);

% ֻ�ڵ�һ�׶�ʹ��NOMA
for loop = 1:11
    r = (loop-1)/10;
    x_axis(loop) = r*100;
    [r11,r22] = find_noma_rate_12(B,sigma,d1,d2,a,thres);

    % ��һ�׶Σ�x1��x2���ӣ�x3oma�ಥ
    t11 = dt*(1-r)/r11;
    t22 = dt*(1-r)/r22;
    t_common = min([t11,t22]);     %��������ʱ��
    
    % ����t_common�Ĵ�С���ֱ��жϽ������Ĵ��䷽��
    
    % x1�����ܴ���
    if t_common == t11
        x2_remain = dt*(1-r)-r22*t_common;
        t_common_new = x2_remain/r22_oma;
        t_last = dt*r/r3_oma;
        
    else
        % x2�ܴ���
        x1_remain = dt*(1-r)-r11*t_common;
        t_common_new = x1_remain/r11_oma;
        t_last = dt*r/r3_oma;
    end
    time_slots = (t_common) + (t_common_new) + (t_last);
    t_noma(loop) = time_slots;  

    time_oma = dt*(1-r)/r11_oma + dt*(1-r)/r22_oma + dt*r/r3_oma;
    t_oma(loop) = time_oma;
    
end
plot(x_axis,t_noma,'b-*','LineWidth',2,'MarkerSize',10),hold on;
plot(x_axis,t_oma,'r-*','LineWidth',2,'MarkerSize',10);
xlabel('�ص��������(%)');
ylabel('����ʱ��(s)');
legend('NOMA','OMA');