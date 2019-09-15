dt = 1*10^6;        % ÿ���û�һ֡���������������1Mbits
B = 1.4*10^6/72;       % �ŵ�����
d1 = 15;            % �û�1�����վ����
d2 = 30;            % �û�2�����վ����
thres = 5;          % ��������
a = 3;              % ·�����ָ��
r = 0.5;            % �ص��������
time_duration = 0.0005;       %ʱ϶���ȣ�0.5ms��ÿ��ʱ϶����20bits

qpskModulator = comm.QPSKModulator;
qpskDemodulator = comm.QPSKDemodulator;

t_noma = zeros(1,6);
t_oma = zeros(1,6);
x_axis = zeros(1,6);



parfor loop = 1:6
    SNR = loop*5+50;
    sigma = 10^(-1*SNR/10);
    x_axis(loop) = SNR;
    slots = 0;
    trans_1 = 0;
    trans_2 = 0;
    trans_3 = 0;
    % ��һ�׶�
    % ���Ź��ʷ���
    [p3, p4] = solveFunction(sigma,d1,d2,a,thres);
    p1 = 1-p3;
    p2 = 1-p4;
    while trans_1<dt*(1-r) && trans_2<dt*(1-r) && trans_3<dt*r
        % ���͸�20���ŵ���������֡
        txData1 = randi([0,1],20,1);
        txData2 = randi([0,1],20,1);
        txData3 = randi([0,1],20,1);
        txData4 = txData3;
        
        % �����ŵ�
        h11 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
        h21 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
        h12 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
        h22 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
    
        % ������˹������
        noise1 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
        noise2 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
        noise3 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
        noise4 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
        
        % ��������
        modSig1 = qpskModulator(txData1);
        modSig2 = qpskModulator(txData2);
        modSig3 = qpskModulator(txData3);
        modSig4 = qpskModulator(txData4);

        % ��������
        rxSig11 = d1^(-0.5*a)*h11.*(sqrt(p1)*modSig1+sqrt(p3)*modSig3)+noise1;
        rxSig21 = d2^(-0.5*a)*h21.*(sqrt(p1)*modSig1+sqrt(p3)*modSig3)+noise2;
        rxSig12 = d1^(-0.5*a)*h12.*(sqrt(p2)*modSig2+sqrt(p4)*modSig4)+noise3;
        rxSig22 = d2^(-0.5*a)*h22.*(sqrt(p2)*modSig2+sqrt(p4)*modSig4)+noise4;

        % ��������
        rxData11 = qpskDemodulator((h11.^(-1)).*rxSig11);
        rxData21 = qpskDemodulator((h21.^(-1)).*rxSig21);
        rxData12 = qpskDemodulator((h12.^(-1)).*rxSig12);
        rxData22 = qpskDemodulator((h22.^(-1)).*rxSig22);

        % �û�1���û�2�ɹ����͵�����
        [num_11,~] = biterr(rxData11,txData1);
        [num_22,~] = biterr(rxData22,txData2);
        trans_1 = trans_1 + 20 - num_11;
        trans_2 = trans_2 + 20 - num_22;
        
        % SIC
        rxData_11 = qpskModulator(rxData11);
        rxData_21 = qpskModulator(rxData21);
        rxData_12 = qpskModulator(rxData12);
        rxData_22 = qpskModulator(rxData22);
        
        remainData11 = d1^(-0.5*a)*h11.*(sqrt(p1)*modSig1+sqrt(p3)*modSig3)-d1^(-0.5*a)*sqrt(p1)*h11.*rxData_11+noise1;
        remainData21 = d2^(-0.5*a)*h21.*(sqrt(p1)*modSig1+sqrt(p3)*modSig3)-d2^(-0.5*a)*sqrt(p1)*h21.*rxData_21+noise2;
        remainData12 = d1^(-0.5*a)*h12.*(sqrt(p2)*modSig2+sqrt(p4)*modSig4)-d1^(-0.5*a)*sqrt(p2)*h12.*rxData_12+noise3;
        remainData22 = d2^(-0.5*a)*h22.*(sqrt(p2)*modSig2+sqrt(p4)*modSig4)-d2^(-0.5*a)*sqrt(p2)*h22.*rxData_22+noise4;

        % MRC Combining
        data_13 = conj(h11).*remainData11 + conj(h12).*remainData12;
        data_23 = conj(h21).*remainData21 + conj(h22).*remainData22;

        rxData_13 = qpskDemodulator(data_13);
        rxData_23 = qpskDemodulator(data_23);
        
        % �ص����ֳɹ����͵�����
        [num_13,~] = biterr(rxData_13,txData3);
        [num_23,~] = biterr(rxData_23,txData3);
        trans_3 = trans_3 + 20 - num_13 - num_23;
        
        slots = slots + 2;
    end
    % �ص����ַ�����ɣ�������x1��x2���ӷ���
    [p1,p2] = find_noma2_power(B,sigma,d1,d2,a,thres);
    if trans_3>=dt*r
        remain_1 = dt*(1-r)-trans_1;
        remain_2 = dt*(1-r)-trans_2;
        trans_1_new = 0;
        trans_2_new = 0;
        while trans_1_new<remain_1 && trans_2_new<remain_2
            txData1 = randi([0,1],20,1);
            txData2 = randi([0,1],20,1);
            
            h1 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
            h2 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
            noise1 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
            noise2 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
        
            modSig1 = qpskModulator(txData1);
            modSig2 = qpskModulator(txData2);
        
            rxSig1 = d1^(-0.5*a)*h1.*(sqrt(p1)*modSig1+sqrt(p2)*modSig2)+noise1;
            rxSig2 = d2^(-0.5*a)*h2.*(sqrt(p1)*modSig1+sqrt(p2)*modSig2)+noise2;
            
            % �Ƚ���x2���ٽ���SIC�õ�x1
            rxData1 = qpskDemodulator((h1.^(-1)).*rxSig1);
            rxData2 = qpskDemodulator((h2.^(-1)).*rxSig2);
            
            [num_22,~] = biterr(rxData2,txData2);
            trans_2_new = trans_2_new + 20 - num_22;
            
            rxData1 = qpskModulator(rxData1);
            remainData1 = rxSig1 - d1^(-0.5*a)*sqrt(p2)*h1.*rxData1;
            rxData1 = qpskDemodulator((h1.^(-1)).*remainData1);
            
            [num_11,~] = biterr(rxData1,txData1);
            trans_1_new = trans_1_new + 20 - num_11;
            slots = slots +1;
        end
        % x1������ϣ�������x2��������
        if trans_1_new >= remain_1
            remain_2 = remain_2 - trans_2_new;
            trans_2_new = 0;
            while trans_2_new <remain_2
                txData2 = randi([0,1],20,1);
                h2 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
                noise2 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));

                modSig2 = qpskModulator(txData2);
                rxSig2 = d2^(-0.5*a)*h2.*modSig2+noise2;

                rxData2 = qpskDemodulator((h2.^(-1)).*rxSig2);
                [num_22,~] = biterr(rxData2,txData2);
                trans_2_new = trans_2_new + 20 - num_22;
                slots = slots + 1;
            end
        % x2������ϣ�������x1��������
        else
            remain_1 = remain_1 - trans_1_new;
            trans_1_new = 0;
            while trans_1_new <remain_1
                txData1 = randi([0,1],20,1);
                h1 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
                noise1 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));

                modSig1 = qpskModulator(txData1);
                rxSig1 = d1^(-0.5*a)*h1.*modSig1+noise1;

                rxData1 = qpskDemodulator((h1.^(-1)).*rxSig1);
                [num_11,~] = biterr(rxData1,txData1);
                trans_1_new = trans_1_new + 20 - num_11;
                slots = slots + 1;
            end
        end
    % x1���ַ�����ϣ�������x2��x3���ӷ���
    [p2,p3] = find_noma3_power(B,sigma,d1,d2,a,thres);
    elseif trans_1>=dt*(1-r)
        remain_2 = dt*(1-r)-trans_2;
        remain_3 = dt*r-trans_3;
        trans_2_new = 0;
        trans_3_new = 0;
        while trans_2_new<remain_2 && trans_3_new<remain_3
            txData2 = randi([0,1],20,1);
            txData3 = randi([0,1],20,1);
            
            h1 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
            h2 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
            noise1 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
            noise2 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
        
            modSig2 = qpskModulator(txData2);
            modSig3 = qpskModulator(txData3);
        
            rxSig1 = d1^(-0.5*a)*h1.*(sqrt(p2)*modSig2+sqrt(p3)*modSig3)+noise1;
            rxSig2 = d2^(-0.5*a)*h2.*(sqrt(p2)*modSig2+sqrt(p3)*modSig3)+noise2;
            
            % �Ƚ���x2���ٽ���SIC�õ�x3
            rxData12 = qpskDemodulator((h1.^(-1)).*rxSig1);
            rxData22 = qpskDemodulator((h2.^(-1)).*rxSig2);
            
            [num_22,~] = biterr(rxData22,txData2);
            trans_2_new = trans_2_new + 20 - num_22;
            
            rxData12 = qpskModulator(rxData12);
            rxData22 = qpskModulator(rxData22);
            
            remainData13 = rxSig1 - d1^(-0.5*a)*sqrt(p2)*h1.*rxData12;
            remainData23 = rxSig2 - d2^(-0.5*a)*sqrt(p2)*h2.*rxData22;
            
            rxData13 = qpskDemodulator(h1.^(-1).*remainData13);
            rxData23 = qpskDemodulator(h2.^(-1).*remainData23);
            [num_13,~] = biterr(rxData13,txData3);
            [num_23,~] = biterr(rxData23,txData3);
            trans_3_new = trans_3_new + 20 - num_13 - num_23;
            slots = slots +1;
        end
        % x3������ϣ�������x2��������
        if trans_3_new >= remain_3
            remain_2 = remain_2 - trans_2_new;
            trans_2_new = 0;
            while trans_2_new <remain_2
                txData2 = randi([0,1],20,1);
                h2 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
                noise2 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));

                modSig2 = qpskModulator(txData2);
                rxSig2 = d2^(-0.5*a)*h2.*modSig2+noise2;

                rxData2 = qpskDemodulator((h2.^(-1)).*rxSig2);
                [num_22,~] = biterr(rxData2,txData2);
                trans_2_new = trans_2_new + 20 - num_22;
                slots = slots + 1;
            end
        % x2������ϣ�������x3��������
        else
            remain_3 = remain_3 - trans_3_new;
            trans_3_new = 0;
            while trans_3_new <remain_3
                txData3 = randi([0,1],20,1);
                h1 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
                h2 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
                noise1 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
                noise2 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
                modSig13 = qpskModulator(txData3);
                modSig23 = modSig13;
                
                rxSig13 = d1^(-0.5*a)*h1.*modSig13+noise1;
                rxSig23 = d2^(-0.5*a)*h2.*modSig23+noise2;
                rxData13 = qpskDemodulator((h1.^(-1)).*rxSig13);
                rxData23 = qpskDemodulator((h2.^(-1)).*rxSig23);
                [num_13,~] = biterr(rxData13,txData3);
                [num_23,~] = biterr(rxData23,txData3);
                trans_3_new = trans_3_new + 20 - num_13 - num_23;
                slots = slots + 1;
            end
        end
    else
        [p1,p3] = find_noma3_power_2(B,sigma,d1,d2,a,thres);
        % x2���ַ�����ϣ�������x1��x3���ӷ���
        remain_1 = dt*(1-r)-trans_1;
        remain_3 = dt*r-trans_3;
        trans_1_new = 0;
        trans_3_new = 0;
        while trans_1_new<remain_1 && trans_3_new<remain_3
            txData1 = randi([0,1],20,1);
            txData3 = randi([0,1],20,1);
            
            h1 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
            h2 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
            noise1 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
            noise2 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
        
            modSig1 = qpskModulator(txData1);
            modSig3 = qpskModulator(txData3);
        
            rxSig1 = d1^(-0.5*a)*h1.*(sqrt(p1)*modSig1+sqrt(p3)*modSig3)+noise1;
            rxSig2 = d2^(-0.5*a)*h2.*(sqrt(p1)*modSig1+sqrt(p3)*modSig3)+noise2;
            
            % �Ƚ���x1���ٽ���SIC�õ�x3
            rxData11 = qpskDemodulator((h1.^(-1)).*rxSig1);
            rxData21 = qpskDemodulator((h2.^(-1)).*rxSig2);
            
            [num_11,~] = biterr(rxData11,txData1);
            trans_1_new = trans_1_new + 20 - num_11;
            
            rxData11 = qpskModulator(rxData11);
            rxData21 = qpskModulator(rxData21);
            
            remainData13 = rxSig1 - d1^(-0.5*a)*sqrt(p1)*h1.*rxData11;
            remainData23 = rxSig2 - d2^(-0.5*a)*sqrt(p1)*h2.*rxData21;
            
            rxData13 = qpskDemodulator(h1.^(-1).*remainData13);
            rxData23 = qpskDemodulator(h2.^(-1).*remainData23);
            [num_13,~] = biterr(rxData13,txData3);
            [num_23,~] = biterr(rxData23,txData3);
            trans_3_new = trans_3_new + 20 - num_13 - num_23;
            slots = slots +1;
        end
        % x3������ϣ�������x1��������
        if trans_3_new >= remain_3
            remain_1 = remain_1 - trans_1_new;
            trans_1_new = 0;
            while trans_1_new <remain_1
                txData1 = randi([0,1],20,1);
                h1 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
                noise1 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));

                modSig1 = qpskModulator(txData1);
                rxSig1 = d1^(-0.5*a)*h1.*modSig1+noise1;

                rxData1 = qpskDemodulator((h1.^(-1)).*rxSig1);
                [num_11,~] = biterr(rxData1,txData1);
                trans_1_new = trans_1_new + 20 - num_11;
                slots = slots + 1;
            end
        % x1������ϣ�������x3��������
        else
            remain_3 = remain_3 - trans_3_new;
            trans_3_new = 0;
            while trans_3_new <remain_3
                txData3 = randi([0,1],20,1);
                h1 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
                h2 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
                noise1 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
                noise2 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
                modSig13 = qpskModulator(txData3);
                modSig23 = modSig13;
                
                rxSig13 = d1^(-0.5*a)*h1.*modSig13+noise1;
                rxSig23 = d2^(-0.5*a)*h2.*modSig23+noise2;
                rxData13 = qpskDemodulator((h1.^(-1)).*rxSig13);
                rxData23 = qpskDemodulator((h2.^(-1)).*rxSig23);
                [num_13,~] = biterr(rxData13,txData3);
                [num_23,~] = biterr(rxData23,txData3);
                trans_3_new = trans_3_new + 20 - num_13 - num_23;
                slots = slots + 1;
            end
        end       
    end
    t_noma(loop) = slots*time_duration;
    
    % OMA
    trans_1 = 0;
    slots_oma = 0;
    while trans_1 < dt*(1-r)
        txData1 = randi([0,1],20,1);
        h1 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
        noise1 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
        modSig1 = qpskModulator(txData1);
        rxSig1 = d1^(-0.5*a)*h1.*modSig1+noise1;
        rxData1 = qpskDemodulator((h1.^(-1)).*rxSig1);
        [num_1,~] = biterr(rxData1,txData1);
        trans_1 = trans_1 + 20 - num_1;
        slots_oma = slots_oma + 1;
    end
    trans_2 = 0;
    while trans_2 < dt*(1-r)
        txData2 = randi([0,1],20,1);
        h2 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
        noise2 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
        modSig2 = qpskModulator(txData2);
        rxSig2 = d2^(-0.5*a)*h2.*modSig2+noise2;
        rxData2 = qpskDemodulator((h2.^(-1)).*rxSig2);
        [num_2,~] = biterr(rxData2,txData2);
        trans_2 = trans_2 + 20 - num_2;
        slots_oma = slots_oma + 1;
    end
    trans_3 = 0;
    while trans_3 < dt*r
        txData3 = randi([0,1],20,1);
        h1 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
        h2 = sqrt(0.5)*(randn(20,1)+1j*randn(20,1));
        noise1 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
        noise2 = sqrt(sigma/2)*(randn(20,1)+1j*randn(20,1));
        modSig3 = qpskModulator(txData3);
        
        rxSig13 = d1^(-0.5*a)*h1.*modSig3+noise1;
        rxSig23 = d2^(-0.5*a)*h2.*modSig3+noise2;
        rxData13 = qpskDemodulator((h1.^(-1)).*rxSig13);
        rxData23 = qpskDemodulator((h2.^(-1)).*rxSig23);
        [num_13,~] = biterr(rxData13,txData3);
        [num_23,~] = biterr(rxData23,txData3);
        trans_3 = trans_3 + 20 - num_13 - num_23;
        slots_oma = slots_oma +1;
    end
    t_oma(loop) = slots_oma*time_duration;
end

plot(x_axis,t_noma,'b-*');hold on;grid on;
plot(x_axis,t_oma,'r-o');
xlabel('Transmitter SNR(dB)');
ylabel('����ʱ��(s)');
title('����������������ʱ��Ա�');
legend('NOMA','OMA');

        