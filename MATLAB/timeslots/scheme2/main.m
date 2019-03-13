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

for loop = 1:11
    r = (loop-1)/10;
    x_axis(loop) = r*100;
    [~,p] = find_noma3_min_max(sigma,d1,d2,a,thres);
    [r11,r13,r22,r23] = find_rate_noma3(p,B,sigma,d1,d2,a,thres);
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
        % ��x1��x2���ӷ��ͣ������Ż����ʷ��估��������
        [r11_new,r22_new] = find_noma_rate_12(B,sigma,d1,d2,a,thres);
        t11_new = x1_remain/r11_new;
        t22_new = x2_remain/r22_new;
        
        t_common_new = min(t11_new,t22_new);        %��������ʱ��2
        
        %���ڶ��׶λ�ʣ���Ĳ�������
        if t11_new<t22_new
            % ��ʣ��x2
            x2_remain_new = x2_remain-r22_new*t_common_new;
            r22_new = B*log2(1+1/(d2^a*sigma));
            t_last = x2_remain_new/r22_new;
        else
            % ��ʣ��x1
            x1_remain_new = x1_remain-r11_new*t_common_new;
            r11_new = B*log2(1+1/(d1^a*sigma));
            t_last = x1_remain_new/r11_new;
        end
        
    elseif t_common == t11
        % x1�����ܴ���
        x3_remain = dt*r-r3*t_common;
        x2_remain = dt*(1-r)-r22*t_common;
        % ��x2��x3���ӷ��ͣ������Ż����ʷ��估��������
        [r13_new,r22_new,r23_new] = find_noma_rate_23(B,sigma,d1,d2,a,thres);
        
        r3_new = min(r13_new,r23_new);
        t3_new = x3_remain/r3_new;
        t2_new = x2_remain/r22_new;
        t_common_new = min(t2_new,t3_new);
        if t3_new<t2_new
            % ���ʣ��x2
            x2_remain_new = x2_remain - t_common_new*r22_new;
            r22_new = B*log2(1+1/(d2^a*sigma));
            t_last = x2_remain_new/r22_new;
        else
            % ���ʣ��x3
            x3_remain_new = x3_remain - t_common_new*r3_new;
            r3_new = B*log2(1+1/(d2^a*sigma));
            t_last = x3_remain_new/r3_new;
        end
        
    else
        % x2�ܴ���
        x3_remain = dt*r-r3*t_common;
        x1_remain = dt*(1-r)-r11*t_common;
        % ��x1��x3���ӷ��ͣ������Ż����ʷ��估��������
        [r11_new,r13_new,r23_new] = find_noma_rate_13(B,sigma,d1,d2,a,thres);
        
        r3_new = min(r13_new,r23_new);
        t3_new = x3_remain/r3_new;
        t1_new = x1_remain/r11_new;
        t_common_new = min(t1_new,t3_new);
        if t3_new<t1_new
            % ���ʣ��x1
            x1_remain_new = x1_remain - t_common_new*r11_new;
            r11_new = B*log2(1+1/(d1^a*sigma));
            t_last = x1_remain_new/r11_new;
        else
            % ���ʣ��x3
            x3_remain_new = x3_remain - t_common_new*r3_new;
            r3_new = B*log2(1+1/(d2^a*sigma));
            t_last = x3_remain_new/r3_new;
        end
    end
    time_slots = (t_common) + (t_common_new) + (t_last);
    t_noma(loop) = time_slots;  
    
    r11_oma = B*log2(1+1/(d1^a*sigma));
    r22_oma = B*log2(1+1/(d2^a*sigma));
    r3_oma = min(r11_oma,r22_oma);
    time_oma = dt*(1-r)/r11_oma + dt*(1-r)/r22_oma + dt*r/r3_oma;
    t_oma(loop) = time_oma;
    
end
plot(x_axis,t_noma,'b-*','LineWidth',2,'MarkerSize',10),hold on;
plot(x_axis,t_oma,'r-*','LineWidth',2,'MarkerSize',10);
xlabel('�ص��������(%)');
ylabel('����ʱ��(s)');
legend('NOMA','OMA');