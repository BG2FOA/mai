% Author: BG2FOA

%% 主程序
u_c = [160;180;200;220;240;260;280;300;320;340;360;380;400;420;440;460;480];
Tc_total = [400;430;460;490;520;550;580;610;640;670;700;730;760;790;820;850;880];
W = zeros(size(u_c));
lighthill_p = zeros(size(u_c));
k = size(u_c,1);
k_watt = (1.5 + rand(1))*(10^(-4)); %k_watt = (1.5e-4,2.5e-4)

for i = 1:1:k
    [W(i), lighthill_p(i)] = acoustic_power_calculation(u_c(i), Tc_total(i), k_watt);
end

loglog(lighthill_p, W, '^-');
xlabel('Lighthill parameter')
ylabel('Power of Jet Noise / W')
grid on

figure; 
plot(lighthill_p, W, 'o-');
xlabel('Lighthill Parameter');
ylabel('Power of Jet Noise / W');
title('Jet Noise Power vs Lighthill Parameter (Linear Scale)');
grid on;

%% 声功率函数
function [W, lighthill_p] = acoustic_power_calculation(u_c, Tc_total, k_watt)
T0 = 293;
P0 = 1e5;
k0 = 1.4;
R0 = 287;
kc = 1.33;
Rc = 289;
m = 0.0396;
Gc = 50;

a0 = sqrt(k0 * R0 * T0);
a_cr = sqrt((2 * kc * Rc * Tc_total)/(kc + 1));
lambda_c = u_c / a_cr;
gdf_p_lambda_c = (1 - (kc - 1) * (lambda_c ^ 2)/(kc + 1)) ^ (kc / (kc - 1));
P_c_total = P0 / gdf_p_lambda_c;
gdf_e_lambda_c = ((1 - (kc - 1) * (lambda_c ^ 2) / (kc + 1)) ^ (1 / (kc - 1)));
gdf_q_lambda_c = (((kc + 1) / 2) ^ (1 / (kc - 1))) * lambda_c * gdf_e_lambda_c;
density_c = gdf_e_lambda_c * P_c_total / (Rc * Tc_total);
Mc = sqrt(((2 * lambda_c ^ 2) / (kc + 1)) / (1 - (kc - 1) * lambda_c ^ 2 / (kc + 1)));
Fc = Gc * sqrt(Tc_total)/(m * P_c_total * gdf_q_lambda_c);

if Mc < 0.5
    n = 6; exp_m = 3;  %亚声速流动系数
else
    n = 8; exp_m = 5;  %超声速流动系数
end

lighthill_p = density_c * (u_c^n) * Fc / (a0^exp_m);
W = k_watt * lighthill_p;
end