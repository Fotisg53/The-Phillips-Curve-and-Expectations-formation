%% Numerical Assignment 3

%  EXERCISE 1 
%  Data: Eurostat Inflation & Unemployment 1993-2023
%  Countries: Greece (GR) and Germany (DE)

clear; clc;
rng(42);
years = (1993:2023)';

inflation_greece = [14.4; 10.9; 8.9; 7.9; 5.5; 4.5; 3.2; 2.9; 3.4; 3.7;
                     3.5;  3.3; 3.0; 2.2; 4.2; 1.3; 3.3; 1.5; 1.2;-1.7;
                    -1.1; -0.8; 0.0; 0.6; 0.2; 0.6; 1.2; 0.6; 9.3; 9.6; 3.5];

unemployment_greece = [ 8.6;  8.9;  9.2;  9.6; 10.3; 12.0; 11.3; 10.7;  9.7;  9.7;
                         9.9;  9.8;  8.9;  7.7;  7.7;  9.4; 12.7; 17.9; 27.5; 26.5;
                        24.9; 23.5; 21.5; 19.3; 17.3; 16.3; 13.2; 11.1;  8.7;  9.0; 11.1];

inflation_germany = [4.1; 3.0; 1.8; 1.4; 1.9; 1.0; 0.6; 1.4; 2.0; 1.4;
                     1.9; 1.1; 1.8; 2.3; 2.8; 0.4; 1.2; 2.5; 2.1; 1.7;
                     0.8; 0.1; 0.4; 1.7; 1.4; 1.4; 1.8; 0.5; 3.2; 8.7; 6.0];

unemployment_germany = [7.8;  8.5;  8.2;  8.9;  9.8; 10.5; 10.3; 10.4;  9.3;  8.7;
                         9.8; 10.5; 11.2; 11.3;  8.7;  7.8;  7.1;  5.9;  5.5;  5.3;
                         5.1;  4.6;  3.8;  3.4;  3.2;  3.0;  3.1;  5.9;  3.6;  3.0; 3.0];

subperiod_names  = {'Pre-Euro (1993-2000)', 'Euro boom (2001-2008)', 
                    'Crisis (2009-2015)',   'Recovery (2016-2023)'};
subperiod_bounds = [1993 2000; 2001 2008; 2009 2015; 2016 2023];
n_subperiods     = 4;

subperiod_mask = false(length(years), n_subperiods);
for k = 1:n_subperiods
    subperiod_mask(:,k) = (years >= subperiod_bounds(k,1)) & ...
                          (years <= subperiod_bounds(k,2));
end

country_names     = {'Greece', 'Germany'};
inflation_data    = {inflation_greece,    inflation_germany};
unemployment_data = {unemployment_greece, unemployment_germany};

for country = 1:2
    inflation    = inflation_data{country};
    unemployment = unemployment_data{country};
    fprintf('\n  %s\n', country_names{country});
    fprintf('  %-22s  %8s  %8s  %8s  %6s\n','Period','alpha','beta','t-stat','R2');
    fprintf('  %s\n', repmat('-',1,58));
    [slope, intercept, tstat, r_squared] = run_ols(inflation, unemployment);
    fprintf('  %-22s  %8.3f  %8.4f  %8.3f  %6.3f\n', ...
            'Full (1993-2023)', intercept, slope, tstat, r_squared);
    for k = 1:n_subperiods
        mask = subperiod_mask(:,k);
        [slope_k, intercept_k, tstat_k, r2_k] = run_ols(inflation(mask), unemployment(mask));
        fprintf('  %-22s  %8.3f  %8.4f  %8.3f  %6.3f\n', ...
                subperiod_names{k}, intercept_k, slope_k, tstat_k, r2_k);
    end
end

for country = 1:2
    inflation        = inflation_data{country};
    unemployment     = unemployment_data{country};
    change_inflation = diff(inflation);
    unemployment_lag = unemployment(2:end);
    fprintf('\n  %s\n', country_names{country});
    [slope, intercept, tstat, r_squared] = run_ols(change_inflation, unemployment_lag);
    fprintf('  Full sample: alpha=%.4f  beta=%.4f  t=%.3f  R2=%.3f\n', ...
            intercept, slope, tstat, r_squared);
end

for country = 1:2
    inflation          = inflation_data{country};
    unemployment       = unemployment_data{country};
    expected_inflation = compute_ar1_expectations(inflation);
    valid              = ~isnan(expected_inflation);
    inflation_gap      = inflation(valid) - expected_inflation(valid);
    [slope, intercept, tstat, r_squared] = run_ols(inflation_gap, unemployment(valid));
    fprintf('\n  %s: alpha=%.4f  beta=%.4f  t=%.3f  R2=%.3f\n', ...
            country_names{country}, intercept, slope, tstat, r_squared);
end

%% Figures for Exercise 1

color_greece     = [0.84 0.18 0.15];
color_germany    = [0.20 0.55 0.74];
color_subperiods = [0.20 0.55 0.74;
                    0.17 0.63 0.30;
                    0.86 0.37 0.22;
                    0.55 0.25 0.65];
markers = {'o','s','^','d'};

figure('Name','Ex1 Fig1 - Static PC','NumberTitle','off','Position',[60 60 1200 500]);
for country = 1:2
    inflation    = inflation_data{country};
    unemployment = unemployment_data{country};
    subplot(1,2,country);
    hold on;
    for k = 1:n_subperiods
        mask = subperiod_mask(:,k);
        scatter(unemployment(mask), inflation(mask), 55, ...
                color_subperiods(k,:), markers{k}, 'filled', ...
                'DisplayName', subperiod_names{k});
    end
    [slope, intercept] = run_ols(inflation, unemployment);
    u_range = linspace(min(unemployment)*0.97, max(unemployment)*1.03, 100)';
    plot(u_range, intercept + slope*u_range, 'k-', 'LineWidth', 2.2, ...
         'DisplayName', sprintf('OLS: beta=%.3f', slope));
    for t = 1:length(years)
        if mod(years(t),5)==0 || years(t)==2009 || years(t)==2020
            text(unemployment(t)+0.15, inflation(t), num2str(years(t)), ...
                 'FontSize', 6.5, 'Color', [0.45 0.45 0.45]);
        end
    end
    yline(0, '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 0.9, 'HandleVisibility', 'off');
    xlabel('Unemployment Rate (%)', 'FontSize', 11);
    ylabel('HICP Inflation (%)',    'FontSize', 11);
    title([country_names{country} ' - Static Phillips Curve (1993-2023)'], ...
          'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 8, 'Box', 'off');
    grid on; box on;
end
sgtitle('Static Phillips Curve: Greece vs Germany', 'FontSize', 14, 'FontWeight', 'bold');

figure('Name','Ex1 Fig2 - Slope Comparison','NumberTitle','off','Position',[80 80 950 420]);
hold on;
period_labels = [{'Full'}, subperiod_names];
beta_greece  = zeros(1, n_subperiods+1);
beta_germany = zeros(1, n_subperiods+1);
[beta_greece(1),~,~,~]  = run_ols(inflation_greece,  unemployment_greece);
[beta_germany(1),~,~,~] = run_ols(inflation_germany, unemployment_germany);
for k = 1:n_subperiods
    mask = subperiod_mask(:,k);
    [beta_greece(k+1),~,~,~]  = run_ols(inflation_greece(mask),  unemployment_greece(mask));
    [beta_germany(k+1),~,~,~] = run_ols(inflation_germany(mask), unemployment_germany(mask));
end
x_pos    = 1:length(period_labels);
bar_data = [beta_greece', beta_germany'];
hb = bar(x_pos, bar_data, 0.65);
hb(1).FaceColor = color_greece;  hb(1).EdgeColor = 'none';
hb(2).FaceColor = color_germany; hb(2).EdgeColor = 'none';
hb(1).DisplayName = 'Greece';
hb(2).DisplayName = 'Germany';
yline(0, 'k-', 'LineWidth', 1.2, 'HandleVisibility', 'off');
set(gca, 'XTick', x_pos, 'XTickLabel', period_labels, ...
         'XTickLabelRotation', 18, 'FontSize', 9);
ylabel('PC Slope (beta)', 'FontSize', 11);
title('Phillips Curve Slope across Countries and Subperiods', ...
      'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'southwest', 'FontSize', 10, 'Box', 'off');
grid on; box on;

figure('Name','Ex1 Fig3 - Adaptive PC','NumberTitle','off','Position',[80 80 1200 500]);
for country = 1:2
    inflation        = inflation_data{country};
    unemployment     = unemployment_data{country};
    change_inflation = diff(inflation);
    unemployment_lag = unemployment(2:end);
    subplot(1,2,country);
    hold on;
    for k = 1:n_subperiods
        mask_k = subperiod_mask(2:end, k);
        scatter(unemployment_lag(mask_k), change_inflation(mask_k), 55, ...
                color_subperiods(k,:), markers{k}, 'filled', ...
                'DisplayName', subperiod_names{k});
    end
    [slope, intercept] = run_ols(change_inflation, unemployment_lag);
    u_range = linspace(min(unemployment_lag)*0.97, max(unemployment_lag)*1.03, 100)';
    plot(u_range, intercept + slope*u_range, 'k-', 'LineWidth', 2.2, ...
         'DisplayName', sprintf('OLS: beta=%.4f', slope));
    yline(0, '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 0.9, 'HandleVisibility', 'off');
    xlabel('Unemployment Rate (%)', 'FontSize', 11);
    ylabel('Change in Inflation (pi_t - pi_{t-1})', 'FontSize', 11);
    title([country_names{country} ' - Adaptive PC'], 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 8, 'Box', 'off');
    grid on; box on;
end
sgtitle('Adaptive Expectations PC: pi_e = pi_{t-1}', 'FontSize', 13, 'FontWeight', 'bold');

figure('Name','Ex1 Fig4 - Time Series','NumberTitle','off','Position',[100 100 1200 440]);
for country = 1:2
    inflation    = inflation_data{country};
    unemployment = unemployment_data{country};
    subplot(1,2,country);
    yyaxis left;
    plot(years, inflation, '-o', 'Color', color_greece, 'LineWidth', 1.6, ...
         'MarkerFaceColor', color_greece, 'MarkerSize', 3.5, 'DisplayName', 'Inflation (LHS)');
    ylabel('HICP Inflation (%)', 'FontSize', 10);
    set(gca, 'YColor', color_greece);
    yyaxis right;
    plot(years, unemployment, '--s', 'Color', color_germany, 'LineWidth', 1.6, ...
         'MarkerFaceColor', color_germany, 'MarkerSize', 3.5, 'DisplayName', 'Unemployment (RHS)');
    ylabel('Unemployment Rate (%)', 'FontSize', 10);
    set(gca, 'YColor', color_germany);
    title([country_names{country} ' - Inflation and Unemployment'], ...
          'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Year', 'FontSize', 10);
    legend('Location', 'northeast', 'FontSize', 9, 'Box', 'off');
    grid on; box on;
end
sgtitle('Data Overview: Inflation and Unemployment 1993-2023', 'FontSize', 13, 'FontWeight', 'bold');

%% EXERCISE 2

alpha  = 1.5;
u_n    = 0.05;
mu0    = 0.000;
mu1    = 0.005;
pi_bar = 0.0;
pi_ini = 0.0;
T      = 20;
t_shock= 10;

t_vec = (1:T)';

pi_A = zeros(T+1,1);  u_A = zeros(T,1);
pi_B = zeros(T+1,1);  u_B = zeros(T,1);
pi_C = zeros(T+1,1);  u_C = zeros(T,1);

pi_A(1) = pi_ini;
pi_B(1) = pi_ini;
pi_C(1) = pi_ini;

for t = 1:T
    mu_t = mu0 + (t >= t_shock)*(mu1 - mu0);

    pi_A(t+1)  = mu_t + pi_A(t);
    pi_e_A     = pi_bar;
    u_A(t)     = u_n + (pi_e_A - pi_A(t+1)) / alpha;

    pi_B(t+1)  = mu_t + pi_B(t);
    pi_e_B     = pi_B(t);
    u_B(t)     = u_n + (pi_e_B - pi_B(t+1)) / alpha;

    pi_C(t+1)  = mu_t + pi_C(t);
    pi_e_C     = mu_t + pi_C(t);
    u_C(t)     = u_n + (pi_e_C - pi_C(t+1)) / alpha;
end

pi_A_plot = pi_A(2:end);
pi_B_plot = pi_B(2:end);
pi_C_plot = pi_C(2:end);

fprintf('\n  %3s  %6s  | %-8s  %-8s  | %-8s  %-8s  | %-8s  %-8s\n', ...
        't','mu_t','pi(A)','u(A)','pi(B)','u(B)','pi(C)','u(C)');
fprintf('  %s\n', repmat('-',1,76));
for t = 1:T
    mu_t = mu0 + (t >= t_shock)*(mu1-mu0);
    fprintf('  %3d  %6.3f  | %8.4f  %8.4f  | %8.4f  %8.4f  | %8.4f  %8.4f\n', ...
            t, mu_t, pi_A_plot(t), u_A(t), pi_B_plot(t), u_B(t), pi_C_plot(t), u_C(t));
end

clr_A  = [0.84  0.18  0.15];
clr_B  = [0.20  0.55  0.74];
clr_C  = [0.17  0.63  0.30];
clr_sh = [0.98  0.95  0.88];

fig1 = figure('Name','Fig1 - Policy Change Dynamics','NumberTitle','off',...
              'Position',[60 60 1200 520]);

ax1 = subplot(1,2,1);
hold(ax1,'on');
fill(ax1, [t_shock T T t_shock], [-0.002 -0.002 0.065 0.065], ...
     clr_sh, 'EdgeColor','none','FaceAlpha',0.6,'HandleVisibility','off');
plot(ax1, t_vec, pi_A_plot, '-o', 'Color',clr_A, 'LineWidth',2.0,...
     'MarkerFaceColor',clr_A, 'MarkerSize',5, 'DisplayName','(A) Constant');
plot(ax1, t_vec, pi_B_plot, '--s', 'Color',clr_B, 'LineWidth',2.0,...
     'MarkerFaceColor',clr_B, 'MarkerSize',5, 'DisplayName','(B) Static');
plot(ax1, t_vec, pi_C_plot, ':^', 'Color',clr_C, 'LineWidth',2.0,...
     'MarkerFaceColor',clr_C, 'MarkerSize',5, 'DisplayName','(C) Rational');
xline(ax1, t_shock-0.5, '--', 'Color',[0.5 0.5 0.5], 'LineWidth',1.2,...
      'HandleVisibility','off');
text(ax1, t_shock+0.2, 0.055, 'Policy shock', 'FontSize',8,...
     'Color',[0.5 0.5 0.5]);
xlabel(ax1,'Period t','FontSize',11);
ylabel(ax1,'Inflation','FontSize',11);
title(ax1,'Inflation Dynamics','FontSize',12,'FontWeight','bold');
legend(ax1,'Location','northwest','FontSize',9,'Box','off');
grid(ax1,'on'); box(ax1,'on');
xlim(ax1,[0.5 T+0.5]);

ax2 = subplot(1,2,2);
hold(ax2,'on');
y_lo = min([u_A; u_B; u_C]) - 0.002;
y_hi = max([u_A; u_B; u_C]) + 0.002;
fill(ax2, [t_shock T T t_shock], [y_lo y_lo y_hi y_hi], ...
     clr_sh, 'EdgeColor','none','FaceAlpha',0.6,'HandleVisibility','off');
plot(ax2, t_vec, u_A, '-o', 'Color',clr_A, 'LineWidth',2.0,...
     'MarkerFaceColor',clr_A, 'MarkerSize',5, 'DisplayName','(A) Constant');
plot(ax2, t_vec, u_B, '--s', 'Color',clr_B, 'LineWidth',2.0,...
     'MarkerFaceColor',clr_B, 'MarkerSize',5,...
     'DisplayName',sprintf('(B) Static: u=%.4f', u_n-mu1/alpha));
plot(ax2, t_vec, u_C, ':^', 'Color',clr_C, 'LineWidth',2.0,...
     'MarkerFaceColor',clr_C, 'MarkerSize',5,...
     'DisplayName',sprintf('(C) Rational: u=%.2f (Lucas)', u_n));
yline(ax2, u_n, 'k-', 'LineWidth',1.2,...
      'DisplayName',sprintf('u_n = %.2f',u_n));
xline(ax2, t_shock-0.5, '--', 'Color',[0.5 0.5 0.5],'LineWidth',1.2,...
      'HandleVisibility','off');
xlabel(ax2,'Period t','FontSize',11);
ylabel(ax2,'Unemployment u_t','FontSize',11);
title(ax2,'Unemployment Dynamics','FontSize',12,'FontWeight','bold');
legend(ax2,'Location','southwest','FontSize',8.5,'Box','off');
grid(ax2,'on'); box(ax2,'on');
xlim(ax2,[0.5 T+0.5]);

figure(fig1);
sgtitle(sprintf('Policy Change (mu: %.3f -> %.3f at t=%d) - Three Expectation Regimes',...
        mu0,mu1,t_shock), 'FontSize',13,'FontWeight','bold');

fig2 = figure('Name','Fig2 - PC Trace','NumberTitle','off',...
              'Position',[80 80 900 500]);
ax3 = axes(fig2);
hold(ax3,'on');
pre  = t_vec  < t_shock;
post = t_vec >= t_shock;
cases  = {pi_A_plot, pi_B_plot, pi_C_plot};
u_cases= {u_A, u_B, u_C};
clrs   = {clr_A, clr_B, clr_C};
labels = {'(A) Constant','(B) Static','(C) Rational'};
for k = 1:3
    plot(ax3, cases{k}(pre), u_cases{k}(pre), ['-o'], 'Color',clrs{k},...
         'LineWidth',1.4,'MarkerFaceColor',clrs{k},'MarkerSize',6,...
         'DisplayName',[labels{k} ' (pre-shock)']);
    plot(ax3, cases{k}(post), u_cases{k}(post), ['--o'], 'Color',clrs{k}*0.75,...
         'LineWidth',2.0,'MarkerFaceColor','w',...
         'MarkerEdgeColor',clrs{k},'MarkerSize',7,...
         'DisplayName',[labels{k} ' (post-shock)']);
end
yline(ax3, u_n,'k--','LineWidth',1.2,...
      'DisplayName',sprintf('Natural rate u_n = %.2f',u_n));
xlabel(ax3,'Inflation','FontSize',11);
ylabel(ax3,'Unemployment u_t','FontSize',11);
title(ax3,'Phillips Curve Trace - Policy Shock at t=10','FontSize',12,'FontWeight','bold');
legend(ax3,'Location','best','FontSize',8.5,'Box','off','NumColumns',2);
grid(ax3,'on'); box(ax3,'on');

%% Part 2 - Stochastic Simulation
%  Simulate all THREE expectation regimes with eps_t ~ N(0,0.01)
%  mu = 0 (as stated in assignment), T=1000, burn-in=100, keep 900

T_total   = 1000;
T_burnin  = 100;
T_keep    = T_total - T_burnin;
mu_sim    = mu1;          % mu=0.005, same as policy change section
sigma_eps = sqrt(0.01);

eps_all = sigma_eps * randn(T_total, 1);

% Preallocate all three regimes
pi_sim_A = zeros(T_total+1, 1);   % Constant expectations
pi_sim_B = zeros(T_total+1, 1);   % Static expectations
pi_sim_C = zeros(T_total+1, 1);   % Rational expectations
u_sim_A  = zeros(T_total, 1);
u_sim_B  = zeros(T_total, 1);
u_sim_C  = zeros(T_total, 1);

pi_sim_A(1) = pi_ini;
pi_sim_B(1) = pi_ini;
pi_sim_C(1) = pi_ini;

for t = 1:T_total
    eps_t = eps_all(t);

    % (A) Constant: pi_e = 0
    pi_sim_A(t+1) = mu_sim + pi_sim_A(t) + eps_t;
    u_sim_A(t)    = u_n + (0 - pi_sim_A(t+1)) / alpha;

    % (B) Static: pi_e = pi_{t-1}
    pi_sim_B(t+1) = mu_sim + pi_sim_B(t) + eps_t;
    u_sim_B(t)    = u_n + (pi_sim_B(t) - pi_sim_B(t+1)) / alpha;

    % (C) Rational: pi_e = mu + pi_{t-1}
    pi_sim_C(t+1) = mu_sim + pi_sim_C(t) + eps_t;
    u_sim_C(t)    = u_n + ((mu_sim + pi_sim_C(t)) - pi_sim_C(t+1)) / alpha;
end

% Drop burn-in — keep periods 101..1000
pi_kept_A = pi_sim_A(T_burnin+2 : end);
pi_kept_B = pi_sim_B(T_burnin+2 : end);
pi_kept_C = pi_sim_C(T_burnin+2 : end);
u_kept_A  = u_sim_A(T_burnin+1 : end);
u_kept_B  = u_sim_B(T_burnin+1 : end);
u_kept_C  = u_sim_C(T_burnin+1 : end);
t_sim     = (1:T_keep)';

% Use rational expectations as the "main" series for compatibility
pi_sim = pi_kept_C;
u_sim  = u_kept_C;

fprintf('\n  Simulation Summary (900 post-burn-in obs):\n');
fprintf('  %-10s  %10s  %10s\n', 'Regime', 'mean(pi)', 'mean(u)');
fprintf('  %s\n', repmat('-',1,35));
fprintf('  %-10s  %10.4f  %10.4f\n', 'Constant',  mean(pi_kept_A), mean(u_kept_A));
fprintf('  %-10s  %10.4f  %10.4f\n', 'Static',    mean(pi_kept_B), mean(u_kept_B));
fprintf('  %-10s  %10.4f  %10.4f\n', 'Rational',  mean(pi_kept_C), mean(u_kept_C));

clr_pi = [0.20 0.55 0.74];
clr_u  = [0.84 0.18 0.15];

%% Sxhma 2.1 - Inflation for all regimes
fig_21 = figure('Name','Sxhma 2.1 - Inflation all regimes','NumberTitle','off',...
                'Position',[60 60 1200 420]);

trend_line = mu_sim * (T_burnin + (1:T_keep))';

subplot(1,3,1);
plot(t_sim, pi_kept_A, '-', 'Color', clr_pi, 'LineWidth', 0.9, 'DisplayName', 'pi_t');
hold on;
plot(t_sim, trend_line, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2, 'DisplayName', 'Trend: mu*t');
ylabel('Inflation pi_t', 'FontSize', 10);
xlabel('Period (post burn-in)', 'FontSize', 10);
title('(A) Constant Expectations', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 8, 'Box', 'off');
grid on; box on; xlim([1 T_keep]);

subplot(1,3,2);
plot(t_sim, pi_kept_B, '-', 'Color', clr_pi, 'LineWidth', 0.9, 'DisplayName', 'pi_t');
hold on;
plot(t_sim, trend_line, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2, 'DisplayName', 'Trend: mu*t');
ylabel('Inflation pi_t', 'FontSize', 10);
xlabel('Period (post burn-in)', 'FontSize', 10);
title('(B) Static Expectations', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 8, 'Box', 'off');
grid on; box on; xlim([1 T_keep]);

subplot(1,3,3);
plot(t_sim, pi_kept_C, '-', 'Color', clr_pi, 'LineWidth', 0.9, 'DisplayName', 'pi_t');
hold on;
plot(t_sim, trend_line, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2, 'DisplayName', 'Trend: mu*t');
ylabel('Inflation pi_t', 'FontSize', 10);
xlabel('Period (post burn-in)', 'FontSize', 10);
title('(C) Rational Expectations', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 8, 'Box', 'off');
grid on; box on; xlim([1 T_keep]);

figure(fig_21);
sgtitle(sprintf('Sxhma 2.1 - Inflation: Stochastic Simulation (T=900, after %d burn-in)', T_burnin),...
        'FontSize', 12, 'FontWeight', 'bold');

%% Sxhma 2.2 - Unemployment for all regimes
fig_22 = figure('Name','Sxhma 2.2 - Unemployment all regimes','NumberTitle','off',...
                'Position',[80 80 1200 420]);

subplot(1,3,1);
plot(t_sim, u_kept_A, '-', 'Color', clr_u, 'LineWidth', 0.9);
hold on;
yline(u_n, 'k--', 'LineWidth', 1.2, 'DisplayName', sprintf('u_n=%.2f', u_n));
ylabel('Unemployment u_t', 'FontSize', 10);
xlabel('Period (post burn-in)', 'FontSize', 10);
title('(A) Constant Expectations', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 8, 'Box', 'off');
grid on; box on; xlim([1 T_keep]);

subplot(1,3,2);
plot(t_sim, u_kept_B, '-', 'Color', clr_u, 'LineWidth', 0.9);
hold on;
yline(u_n, 'k--', 'LineWidth', 1.2, 'DisplayName', sprintf('u_n=%.2f', u_n));
ylabel('Unemployment u_t', 'FontSize', 10);
xlabel('Period (post burn-in)', 'FontSize', 10);
title('(B) Static Expectations', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 8, 'Box', 'off');
grid on; box on; xlim([1 T_keep]);

subplot(1,3,3);
plot(t_sim, u_kept_C, '-', 'Color', clr_u, 'LineWidth', 0.9);
hold on;
yline(u_n, 'k--', 'LineWidth', 1.2, 'DisplayName', sprintf('u_n=%.2f', u_n));
yline(u_n + sigma_eps/alpha, ':', 'Color', clr_u*0.8, 'LineWidth', 1.0, ...
      'DisplayName', 'u_n +/- std/alpha');
yline(u_n - sigma_eps/alpha, ':', 'Color', clr_u*0.8, 'LineWidth', 1.0, ...
      'HandleVisibility', 'off');
ylabel('Unemployment u_t', 'FontSize', 10);
xlabel('Period (post burn-in)', 'FontSize', 10);
title('(C) Rational Expectations', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 8, 'Box', 'off');
grid on; box on; xlim([1 T_keep]);

figure(fig_22);
sgtitle(sprintf('Sxhma 2.2 - Unemployment: Stochastic Simulation (T=900, after %d burn-in)', T_burnin),...
        'FontSize', 12, 'FontWeight', 'bold');

%% Sxhma 2.3 - Inflation AND Unemployment side by side (2 panels per regime)
sim_titles = {'(A) Constant','(B) Static','(C) Rational'};
pi_all = {pi_kept_A, pi_kept_B, pi_kept_C};
u_all  = {u_kept_A,  u_kept_B,  u_kept_C};

%% Sxhma 2.3 - One figure per regime: Inflation + Unemployment
regime_names = {'Constant Expectations', 'Static Expectations', 'Rational Expectations'};

for k = 1:3
    fig_regime = figure('Name', sprintf('Sxhma 2.3 - %s', sim_titles{k}), ...
                        'NumberTitle', 'off', 'Position', [60+k*20 60 900 520]);

    % Top: Inflation
    subplot(2,1,1);
    plot(t_sim, pi_all{k}, '-', 'Color', clr_pi, 'LineWidth', 0.9, 'DisplayName', 'pi_t');
    hold on;
    plot(t_sim, trend_line, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2, ...
         'DisplayName', 'Trend: mu*t');
    ylabel('Inflation pi_t', 'FontSize', 10);
    title(sprintf('Inflation - %s', regime_names{k}), 'FontSize', 11, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 9, 'Box', 'off');
    grid on; box on;
    set(gca, 'XTickLabel', []);
    xlim([1 T_keep]);

    % Bottom: Unemployment
    subplot(2,1,2);
    plot(t_sim, u_all{k}, '-', 'Color', clr_u, 'LineWidth', 0.9, 'DisplayName', 'u_t');
    hold on;
    yline(u_n, 'k--', 'LineWidth', 1.4, 'DisplayName', sprintf('u_n = %.2f', u_n));
    ylabel('Unemployment u_t', 'FontSize', 10);
    xlabel('Period (post burn-in)', 'FontSize', 10);
    title(sprintf('Unemployment - %s', regime_names{k}), 'FontSize', 11, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 9, 'Box', 'off');
    grid on; box on;
    xlim([1 T_keep]);

    sgtitle(sprintf('Sxhma 2.3 - Stochastic Simulation: %s\n(T=900, after %d burn-in)', ...
            regime_names{k}, T_burnin), 'FontSize', 12, 'FontWeight', 'bold');
end

%% Sxhma 2.4 - Distributions (histogram + normal pdf) for all regimes
fig_24 = figure('Name','Sxhma 2.4 - Distributions','NumberTitle','off',...
                'Position',[100 100 1200 460]);

for k = 1:3
    pi_k = pi_all{k};
    u_k  = u_all{k};

    ax_h1 = subplot(2,3,k);
    histogram(ax_h1, pi_k, 30, 'FaceColor', clr_pi, 'EdgeColor', 'w', ...
              'FaceAlpha', 0.85, 'Normalization', 'pdf');
    hold(ax_h1, 'on');
    xg_k  = linspace(min(pi_k)-0.1, max(pi_k)+0.1, 300);
    mu_k  = mean(pi_k); sig_k = std(pi_k);
    pdf_k = (1/(sig_k*sqrt(2*pi))) * exp(-0.5*((xg_k-mu_k)/sig_k).^2);
    plot(ax_h1, xg_k, pdf_k, 'k-', 'LineWidth', 1.8);
    xlabel(ax_h1, 'Inflation', 'FontSize', 9);
    ylabel(ax_h1, 'Density',   'FontSize', 9);
    title(ax_h1, sim_titles{k}, 'FontSize', 10, 'FontWeight', 'bold');
    grid(ax_h1,'on'); box(ax_h1,'on');

    ax_h2 = subplot(2,3,k+3);
    histogram(ax_h2, u_k, 30, 'FaceColor', clr_u, 'EdgeColor', 'w', ...
              'FaceAlpha', 0.85, 'Normalization', 'pdf');
    hold(ax_h2, 'on');
    xg2_k  = linspace(min(u_k)-0.005, max(u_k)+0.005, 300);
    mu2_k  = mean(u_k); sig2_k = std(u_k);
    pdf2_k = (1/(sig2_k*sqrt(2*pi))) * exp(-0.5*((xg2_k-mu2_k)/sig2_k).^2);
    plot(ax_h2, xg2_k, pdf2_k, 'k-', 'LineWidth', 1.8);
    xline(ax_h2, u_n, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2);
    xlabel(ax_h2, 'Unemployment', 'FontSize', 9);
    ylabel(ax_h2, 'Density',      'FontSize', 9);
    grid(ax_h2,'on'); box(ax_h2,'on');
end

figure(fig_24);
sgtitle('Sxhma 2.4 - Distributions of Inflation (top) and Unemployment (bottom) - All Regimes',...
        'FontSize', 11, 'FontWeight', 'bold');

%% =========================================================
%  SECTION 3 - DATA: FIGURES
%  Fig 5:  Static PC scatter (Greece & Germany)
%  Fig 6:  PC Slope bar chart across subperiods
%  Fig 7:  Real vs Projected Inflation (full period)
%  Fig 8:  Real vs Projected by Subperiod - Greece
%  Fig 9:  Real vs Projected by Subperiod - Germany
%% =========================================================

color_subperiods_s3 = [0.20 0.55 0.74;
                       0.17 0.63 0.30;
                       0.86 0.37 0.22;
                       0.55 0.25 0.65];
markers_s3 = {'o','s','^','d'};

%% Fig 5 - Static Phillips Curve scatter
figure('Name','Fig5 - Static PC','NumberTitle','off','Position',[60 60 1300 520]);
for country = 1:2
    inflation    = inflation_data{country};
    unemployment = unemployment_data{country};
    subplot(1,2,country);
    hold on;
    for k = 1:n_subperiods
        mask = subperiod_mask(:,k);
        scatter(unemployment(mask), inflation(mask), 60, ...
                color_subperiods_s3(k,:), markers_s3{k}, 'filled', ...
                'DisplayName', subperiod_names{k});
    end
    [slope_s3, intercept_s3] = run_ols(inflation, unemployment);
    u_range_s3 = linspace(min(unemployment)*0.97, max(unemployment)*1.03, 100)';
    plot(u_range_s3, intercept_s3 + slope_s3*u_range_s3, 'k-', 'LineWidth', 2.2, ...
         'DisplayName', sprintf('OLS: beta=%.3f', slope_s3));
    for t = 1:length(years)
        if mod(years(t),5)==0 || years(t)==2009 || years(t)==2020
            text(unemployment(t)+0.15, inflation(t), num2str(years(t)), ...
                 'FontSize', 6.5, 'Color', [0.45 0.45 0.45]);
        end
    end
    yline(0, '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 0.9, 'HandleVisibility', 'off');
    xlabel('Unemployment Rate (%)', 'FontSize', 11);
    ylabel('HICP Inflation (%)',    'FontSize', 11);
    title([country_names{country} ' - Static Phillips Curve (1993-2023)'], ...
          'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 8, 'Box', 'off');
    grid on; box on;
end
sgtitle('Sxhma 3.1 - Static Phillips Curve: Greece vs Germany', ...
        'FontSize', 13, 'FontWeight', 'bold');

%% Fig 6 - Slope comparison bar chart
figure('Name','Fig6 - Slope Comparison S3','NumberTitle','off','Position',[80 80 950 420]);
hold on;
beta_gr_s3 = zeros(1, n_subperiods+1);
beta_de_s3 = zeros(1, n_subperiods+1);
[beta_gr_s3(1),~,~,~] = run_ols(inflation_greece,  unemployment_greece);
[beta_de_s3(1),~,~,~] = run_ols(inflation_germany, unemployment_germany);
for k = 1:n_subperiods
    mask = subperiod_mask(:,k);
    [beta_gr_s3(k+1),~,~,~] = run_ols(inflation_greece(mask),  unemployment_greece(mask));
    [beta_de_s3(k+1),~,~,~] = run_ols(inflation_germany(mask), unemployment_germany(mask));
end
x_s3      = 1:length(period_labels);
bar_s3    = [beta_gr_s3', beta_de_s3'];
hb_s3     = bar(x_s3, bar_s3, 0.65);
hb_s3(1).FaceColor = [0.84 0.18 0.15]; hb_s3(1).EdgeColor = 'none';
hb_s3(2).FaceColor = [0.20 0.55 0.74]; hb_s3(2).EdgeColor = 'none';
hb_s3(1).DisplayName = 'Greece';
hb_s3(2).DisplayName = 'Germany';
yline(0, 'k-', 'LineWidth', 1.2, 'HandleVisibility', 'off');
set(gca, 'XTick', x_s3, 'XTickLabel', period_labels, ...
         'XTickLabelRotation', 18, 'FontSize', 9);
ylabel('PC Slope (beta)', 'FontSize', 11);
title('Sxhma 3.2 - Phillips Curve Slope across Countries and Subperiods', ...
      'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'southwest', 'FontSize', 10, 'Box', 'off');
grid on; box on;

%% Fig 7 - Real vs Projected Inflation (full period)
figure('Name','Fig7 - Real vs Projected','NumberTitle','off','Position',[80 80 1300 460]);
for country = 1:2
    inflation    = inflation_data{country};
    pi_e_ar1     = compute_ar1_expectations(inflation);
    valid_s3     = ~isnan(pi_e_ar1);
    years_valid  = years(valid_s3);
    pi_valid     = inflation(valid_s3);
    pie_valid    = pi_e_ar1(valid_s3);

    subplot(1,2,country);
    hold on;
    plot(years_valid, pi_valid,  'b-',  'LineWidth', 1.5, 'DisplayName', 'Realised Inflation');
    plot(years_valid, pie_valid, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Projected Inflation');
    xlabel('Year',              'FontSize', 10);
    ylabel('Inflation (%)',     'FontSize', 10);
    title(country_names{country}, 'FontSize', 11, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 9, 'Box', 'off');
    grid on; box on;
end
sgtitle('Sxhma 3.3 - Distance between Realised and Projected Inflation', ...
        'FontSize', 12, 'FontWeight', 'bold');

%% Fig 8 - Real vs Projected by Subperiod - Greece
figure('Name','Fig8 - Subperiods Greece','NumberTitle','off','Position',[60 60 1300 380]);
pi_e_gr  = compute_ar1_expectations(inflation_greece);
valid_gr = ~isnan(pi_e_gr);
yrs_gr   = years(valid_gr);
pi_gr_v  = inflation_greece(valid_gr);
pie_gr_v = pi_e_gr(valid_gr);

for k = 1:n_subperiods
    mask_k = (yrs_gr >= subperiod_bounds(k,1)) & (yrs_gr <= subperiod_bounds(k,2));
    subplot(1, n_subperiods, k);
    hold on;
    plot(yrs_gr(mask_k), pi_gr_v(mask_k),  'b-',  'LineWidth', 1.5, 'DisplayName', 'Realised');
    plot(yrs_gr(mask_k), pie_gr_v(mask_k), 'r--', 'LineWidth', 1.5, 'DisplayName', 'Projected');
    title(subperiod_names{k}, 'FontSize', 9, 'FontWeight', 'bold');
    xlabel('Year',             'FontSize', 8);
    ylabel('Inflation (%)',    'FontSize', 8);
    legend('Location', 'best', 'FontSize', 7, 'Box', 'off');
    grid on; box on;
end
sgtitle('Sxhma 3.4 - Real vs Projected Inflation by Subperiod: Greece', ...
        'FontSize', 11, 'FontWeight', 'bold');

%% Fig 9 - Real vs Projected by Subperiod - Germany
figure('Name','Fig9 - Subperiods Germany','NumberTitle','off','Position',[80 80 1300 380]);
pi_e_de  = compute_ar1_expectations(inflation_germany);
valid_de = ~isnan(pi_e_de);
yrs_de   = years(valid_de);
pi_de_v  = inflation_germany(valid_de);
pie_de_v = pi_e_de(valid_de);

for k = 1:n_subperiods
    mask_k = (yrs_de >= subperiod_bounds(k,1)) & (yrs_de <= subperiod_bounds(k,2));
    subplot(1, n_subperiods, k);
    hold on;
    plot(yrs_de(mask_k), pi_de_v(mask_k),  'b-',  'LineWidth', 1.5, 'DisplayName', 'Realised');
    plot(yrs_de(mask_k), pie_de_v(mask_k), 'r--', 'LineWidth', 1.5, 'DisplayName', 'Projected');
    title(subperiod_names{k}, 'FontSize', 9, 'FontWeight', 'bold');
    xlabel('Year',             'FontSize', 8);
    ylabel('Inflation (%)',    'FontSize', 8);
    legend('Location', 'best', 'FontSize', 7, 'Box', 'off');
    grid on; box on;
end
sgtitle('Sxhma 3.5 - Real vs Projected Inflation by Subperiod: Germany', ...
        'FontSize', 11, 'FontWeight', 'bold');

fprintf('\n  All done. 9 figures generated.\n\n');

%% LOCAL FUNCTIONS

function [slope, intercept, tstat, r_squared] = run_ols(y, x)
    y = y(:); x = x(:);
    n = length(y);
    X = [ones(n,1), x];
    b = (X'*X) \ (X'*y);
    intercept = b(1);
    slope     = b(2);
    residuals = y - X*b;
    s_squared = (residuals'*residuals) / (n-2);
    std_slope = sqrt(s_squared / sum((x - mean(x)).^2));
    tstat     = slope / std_slope;
    ss_tot    = sum((y - mean(y)).^2);
    r_squared = 1 - (residuals'*residuals) / ss_tot;
end

function expected_inflation = compute_ar1_expectations(inflation)
    T = length(inflation);
    expected_inflation = NaN(T,1);
    for t = 2:T
        if t < 4, continue; end
        y_dep = inflation(2:t);
        X_reg = [ones(t-1,1), inflation(1:t-1)];
        b_ar  = (X_reg'*X_reg) \ (X_reg'*y_dep);
        expected_inflation(t) = b_ar(1) + b_ar(2)*inflation(t-1);
    end
end
