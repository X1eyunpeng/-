data = xlsread('shuju.xlsx','B2:M117');
year = xlsread('shuju.xlsx','A2:A117');
Q = mean(data(:));  % 多年平均径流量
pk = [200 100 60 40 30 20 10 10];
pf = [200 100 60 60 50 40 30 10];
qk = zeros(8, 1);  % 10月-翌年3月生态流量
qf = zeros(8, 1);  % 4月-9月生态流量
for i=1:size(pk,2)
    qk(i) = pk(i) * Q * 0.01;
    qf(i) = pf(i) * Q * 0.01;
end
%Tessman法
Q_m = mean(data, 1); % 多年平均月径流量
P = Q_m / Q; % 各月计算频率P
Q_T = zeros(12,1); % 各月最小生态流量值
for i = 1:12
    if P(i) < 0.4
        Q_T(i) = Q_m(i);
    elseif P(i) >= 0.4 & P(i) <= 1
        Q_T(i) = 0.4 * Q;
    else
        Q_T(i) = 0.4 * Q_m(i);
    end
end
%基流比例法
FSN = []; FSN_data = []; FSN_data_fpk = []; % 丰水年
PSN = []; PSN_data = []; PSN_data_fpk = []; % 平水年
KSN = []; KSN_data = []; KSN_data_fpk = []; % 枯水年
TKSN = []; TKSN_data = []; TKSN_data_fpk = []; % 特枯水年
Q_y = mean(data, 2); % 各年平均径流量
E = (Q_y - Q) / Q; % 距据百分率
Q_nx = zeros(1, 4); % 各年型平均流量
aa = zeros(1, 4); % 比例倍数
T = zeros(1, 4); % 基流比例
Q_jl = zeros(1, 4); % 最小生态流量
P_jl = zeros(1, 4); % 占多年平均流量比例


for i = 1:116
    if E(i) > 0.2
        FSN = [FSN ;year(i)];
        FSN_data = [FSN_data ;Q_y(i)];
        x = fun(i, data);
        FSN_data_fpk = [FSN_data_fpk; x];
    elseif E(i) <= 0.2 & E(i) > -0.2
        PSN = [PSN ;year(i)];
        PSN_data = [PSN_data ; Q_y(i)];
        x = fun(i, data);
        PSN_data_fpk = [PSN_data_fpk; x];
    elseif E(i) <= -0.2 & E(i) > -0.6
        KSN = [KSN ;year(i)];
        KSN_data = [KSN_data ;Q_y(i)];
        x = fun(i, data);
        KSN_data_fpk = [KSN_data_fpk; x];
    else
        TKSN = [TKSN ;year(i)];
        TKSN_data = [TKSN_data ;Q_y(i)];
        x = fun(i, data);
        TKSN_data_fpk = [TKSN_data_fpk; x];
    end
end

Q_nx = [mean(FSN_data(:)) mean(PSN_data(:)) mean(KSN_data(:)) mean(TKSN_data(:))];
T(1) = 0.05;
for i = 1:4
    if i ~= 4
        aa(i+1) = 1 + (Q_nx(i)/Q_nx(i+1) - 1) * 0.4;
        T(i+1) = aa(i+1) * T(i);
    end
    Q_jl(i) = Q_nx(i) * T(i);
end
P_jl = Q_jl / Q;
    

a = mean(FSN_data_fpk, 1); % 丰
b = mean(PSN_data_fpk, 1); % 平
c = mean(KSN_data_fpk, 1); % 枯
d = mean(TKSN_data_fpk, 1); % 特枯

Q_fpk = [a*T(1); b*T(2); c*T(3); d*T(4)]; % 最小生态流量
P_fpk = [a*T(1)/Q_nx(1); b*T(2)/Q_nx(2); c*T(3)/Q_nx(3); d*T(4)/Q_nx(4)]; % 占多年平均流量比例
    
% 数据选择
Q_m_p = mean(Q_m(:)); % 多年月平均流量均值
[C, L] = max(data);
[D, K] = min(data);
month_max = [year(L) C']; % 月平均流量最大值和出现月份
month_min = [year(K) D']; % 月平均流量最小值和出现月份


% 数据写入，基流比例法粘贴
xlswrite('shuju.xlsx',qk,'计算结果', 'B2:B9');
xlswrite('shuju.xlsx',qf,'计算结果', 'C2:C9');
xlswrite('shuju.xlsx',Q_T,'计算结果', 'F2:F13');
xlswrite('shuju.xlsx',Q_fpk(1,:),'计算结果', 'J4:L4');
xlswrite('shuju.xlsx',Q_fpk(2,:),'计算结果', 'J7:L7');
xlswrite('shuju.xlsx',Q_fpk(3,:),'计算结果', 'J10:L10');
xlswrite('shuju.xlsx',Q_fpk(4,:),'计算结果', 'J13:L13');

% 枯水年基流比例法计算
FSN_k = []; FSN_k_data = [];
PSN_k = []; PSN_k_data = [];
KSN_k = []; KSN_k_data = [];
TKSN_k = []; TKSN_k_data = [];
Q_y_k = mean(data(:,[1 2 3 11 12]), 2); % 枯水期各年平均径流量
Q_k = mean(Q_y_k(:)); % 枯水期多年平均流量
E_k = (Q_y_k - Q_k) / Q_k;
Q_nx_k = zeros(1, 4);
aa_k = zeros(1, 4);
T_k = zeros(1, 4);
Q_jl_k = zeros(1, 4);
P_jl_k = zeros(1, 4);

for i = 1:116
    if E_k(i) > 0.2
        FSN_k = [FSN_k ;year(i)];
        FSN_k_data = [FSN_k_data ;Q_y_k(i)];
    elseif E_k(i) <= 0.2 & E_k(i) > -0.2
        PSN_k = [PSN_k ;year(i)];
        PSN_k_data = [PSN_k_data ; Q_y_k(i)];
    elseif E_k(i) <= -0.2 & E_k(i) > -0.6
        KSN_k = [KSN_k ;year(i)];
        KSN_k_data = [KSN_k_data ;Q_y_k(i)];
    else
        TKSN_k = [TKSN_k ;year(i)];
        TKSN_k_data = [TKSN_k_data ;Q_y_k(i)];
    end
end

Q_nx_k = [mean(FSN_k_data(:)) mean(PSN_k_data(:)) mean(KSN_k_data(:)) mean(TKSN_k_data(:))];
T_k(1) = 0.05;
for i = 1:4
    if i ~= 4
        aa_k(i+1) = 1 + (Q_nx_k(i)/Q_nx_k(i+1) - 1) * 0.4;
        T_k(i+1) = aa_k(i+1) * T_k(i);
    end
    Q_jl_k(i) = Q_nx_k(i) * T_k(i);
end
P_jl_k = Q_jl_k / Q_k;

% 多种方法计算成果比较
month = 1:12;
figure(1)
y1 = xlsread('shuju.xlsx','计算结果','D18:D29'); % Tennant
y2 = xlsread('shuju.xlsx','计算结果','E18:E29'); % Tessman
y3 = xlsread('shuju.xlsx','计算结果','F18:F29'); % 基流比例法丰水年
y4 = xlsread('shuju.xlsx','计算结果','G18:G29'); % 基流比例法平水年
y5 = xlsread('shuju.xlsx','计算结果','H18:H29'); % 基流比例法枯水年
y6 = xlsread('shuju.xlsx','计算结果','I8:I29'); % 基流比例法特枯水年

plot(month,Q_m,':k','MarkerSize',2,'linewidth',1.2);
hold on
plot(month,y1,'-k*','MarkerSize',2,'linewidth',0.6);
plot(month,y2,'-ko','MarkerSize',2,'linewidth',0.6);
plot(month,y3,'-ks','MarkerSize',2,'linewidth',0.6);
plot(month,y4,'-kp','MarkerSize',2,'linewidth',0.6);
plot(month,y5,'-k^','MarkerSize',2,'linewidth',0.6);
plot(month,y6,'-kx','MarkerSize',2,'linewidth',0.6);

xlabel('月份','FontSize',10);
ylabel('生态流量/（m^3/s）','FontSize',10);
xlim([1 12])
set(gca,'XTick',1:1:12);
%set(gca,'XTicklabel',{'1','2','3','4','5','6','7','8','9','10','11','12'});
legend('各月平均流量','Tennant法','Tessman法','基流比例法丰水年','基流比例法平水年','基流比例法枯水年','基流比例法特枯水年');

% 生态流量保证程度分析
qa = length(data(:));
Q_tennant = y1; tennant = 0; % 生态流量值
Q_tessman = y2; tessman = 0;
Q_jiliu_f = y3; jiliu = 0; 
Q_jiliu_p = y4; 
Q_jiliu_k = y5; 
Q_jiliu_tk = y6; 
for i = 1:116
    q = 0; w = 0; e = 0;
    for o = 1:12
        if data(i, o) >= Q_tennant(o)
            tennant = tennant + 1;
            q=q+1;
        end
        if data(i, o) >= Q_tessman(o)
            tessman = tessman + 1;
            w=w+1;
        end
        if E(i) > 0.2
            if data(i, o) >= Q_jiliu_f(o)
                jiliu = jiliu + 1;
                e=e+1;
            end
        elseif E(i) <= 0.2 & E_k(i) > -0.2
            if data(i, o) >= Q_jiliu_p(o)
                jiliu = jiliu + 1;
                e=e+1;
            end
        elseif E(i) <= -0.2 & E_k(i) > -0.6
            if data(i, o) >= Q_jiliu_k(o)
                jiliu = jiliu + 1;
                e=e+1;
            end
        else
            if data(i, o) >= Q_jiliu_tk(o)
                jiliu = jiliu + 1;
                e=e+1;
            end
        end
    end  
    
end

P_fx = [tennant tessman jiliu] / qa




ten = mean(Q_tennant); ten_p = 0;
tes = mean(Q_tessman); tes_p = 0;
jlb_f = mean(Q_jiliu_f);jlb_f_p = 0;
jlb_p = mean(Q_jiliu_p);
jlb_k = mean(Q_jiliu_k);
jlb_tk = mean(Q_jiliu_tk);
for i = 1:116
    if Q_y(i) >= ten
        ten_p = ten_p + 1;
    end
    if Q_y(i) >= tes
        tes_p = tes_p +1;
    end
    if E(i) > 0.2
        if Q_y(i) >= jlb_f
            jlb_f_p = jlb_f_p + 1;
        end
    elseif E(i) <= 0.2 & E_k(i) > -0.2
        if Q_y(i) >= jlb_p
            jlb_f_p = jlb_f_p + 1;
        end
    elseif E(i) <= -0.2 & E_k(i) > -0.6
        if Q_y(i) >= jlb_k
            jlb_f_p = jlb_f_p + 1;
        end
    else
        if Q_y(i) >= jlb_tk
            jlb_f_p = jlb_f_p + 1;
        end
    end
end
pp = [ten_p tes_p jlb_f_p] / 116;
    







        
function x = fun(i, data)
y = data(i,:);
q1 = [y(6) y(7) y(8) y(9)];
q2 = [y(4) y(5) y(10)];
q3 = [y(1) y(2) y(3) y(11) y(12)];
x = [mean(q1(:)) mean(q2(:)) mean(q3(:))];
end





