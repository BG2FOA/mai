% Author: BG2FOA

%% Annoyance Correction
%三分之一倍频程中心频率
centfrq = [50, 63, 80, 100, 125, 160, 200, 250, 315, 400, ...
           500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, ...
           5000, 6300, 8000, 10000];
%三分之一倍频程中心频率对应声压级（根据个人数据）
SPL_k= [93.5, 94, 97, 96.9, 95.3, 95.9, 96.1, 95.3, 94.6, 92.2, ...
       91.3, 91.1, 92, 92.8, 90.2, 91, 93.5, 101.4, 91.3, 90.9, ...
       92.9, 88.6, 87, 82.7];
%三分之一倍频程中心频率与声压级确定noys值（查表）
n_k = [18.4, 19.7, 27.9, 32.0, 29.9, 4.3, 39.4, 39.4, 42.2, 36.8, ...
       34.3, 34.3, 36.8, 39.4, 36.8, 51.0, 720, 134, 72.0, 72.0, ...
       77.2, 54.7, 38.7, 23.9];
%总感觉噪声
N_k = 0.85 * max(n_k) + 0.15 * sum(n_k);
%感觉噪声级
PNL_k = 40.0 + 10 / log(2) * log(N_k);
%% Tone Correction
%Step 1
s_k = zeros(24, 1);
for i = 4:24
    s_k(i) = SPL_k(i) - SPL_k(i - 1);
end
%Step 2
delta_s_k = zeros(24, 1);
enc2 = zeros(24, 1); %圈出第i个slpoe
for i = 5:24
    delta_s_k(i) = s_k(i) - s_k(i - 1);
    if abs(delta_s_k(i)) > 5
        enc2(i) = 1;
    end
end
%Step 3
enc3 = zeros(24, 1); %圈出第i个SPL
for i = 1:24
    if enc2(i) == 1
        if s_k(i) > 0 && delta_s_k(i) > 0
            enc3(i) = 1;
        elseif s_k(i) <= 0 && s_k(i - 1) > 0
            enc3(i) = 1;
        end
    end
end
%Step 4
SPL1_k = zeros(24, 1);
for i = 1:23
    if enc3(i) == 0
        SPL1_k(i) = SPL_k(i);
    else
        SPL1_k(i) = 0.5 * (SPL_k(i - 1) + SPL_k(i + 1));
    end
end
SPL1_k(24) = SPL_k(23) + s_k(23);
%Step 5
s1_k = zeros(24, 1);
for i = 4:24
    s1_k(i) = SPL1_k(i) - SPL1_k(i - 1);
end
s1_k(3) = s1_k(4);
s1_k(25) = s1_k(24);
%Step 6
s_k_avg = zeros(24, 1);
for i = 3:23
    s_k_avg(i) = (s1_k(i) + s1_k(i + 1) + s1_k(i + 2)) / 3;
end
%Step 7
SPL2_k = zeros(24, 1);
SPL2_k(3) = SPL_k(3);
for i = 4:24
    SPL2_k(i) = SPL2_k(i - 1) + s_k_avg(i - 1);
end
%Step 8
F_k = zeros(24, 1);
for i = 3:24
    F_k(i) = SPL_k(i) - SPL2_k(i);
end
%Step 9
C_k = zeros(24, 1);
for i = 3:24
    if centfrq(i) >= 50 && centfrq(i) <= 500
        if F_k(i) >= 1.5 && F_k(i) < 3
            C_k(i) = F_k(i) / 3 - 0.5;
        elseif F_k(i) >= 3 && F_k(i) < 20
            C_k(i) = F_k(i) / 6;
        elseif F_k(i) >= 20
            C_k(i) = 10 / 3;
        end
    elseif centfrq(i) >= 500 && centfrq(i) <= 5000
        if F_k(i) >= 1.5 && F_k(i) < 3
            C_k(i) = 2 * F_k(i) / 3 - 1;
        elseif F_k(i) >= 3 && F_k(i) < 20
            C_k(i) = F_k(i) / 3;
        elseif F_k(i) >= 20
            C_k(i) = 20 / 3;
        end
    elseif centfrq(i) >= 5000 && centfrq(i) <= 10000
        if F_k(i) >= 1.5 && F_k(i) < 3
            C_k(i) = F_k(i) / 3 - 0.5;
        elseif F_k(i) >= 3 && F_k(i) < 20
            C_k(i) = F_k(i) / 6;
        elseif F_k(i) >= 20
            C_k(i) = 10 / 3;
        end
    end
end
%Step 10
PNLT_k = PNL_k + max(C_k);
PNLTM = max(PNLT_k);
%% Duration Correction
D = 10 * log10(sum(10 ^ (PNL_k / 10))) - PNLTM - 13;
%% Final Objective
EPNL = PNLTM + D;
disp(EPNL);
