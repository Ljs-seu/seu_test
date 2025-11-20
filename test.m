clc; clear;

% ===== 自定义参数组 =====
params.Kp = 1.2;
params.Ki = 0.1;
params.Kd = 0.1;
params.omega = 2*pi/40;
params.sigma_p = 0.01;
params.sigma_theta_drift = 0.1;
params.sigma_theta_noise = 0.05;
params.delay_steps = 1;  
params.gimbal_delay_steps = 1;  
params.dt = 0.03;  % 控制频率

% ===== 执行基准仿真 =====
rng(42);
result = simulate_tracking(params, false);  % 不考虑延迟
mean_u = mean(result.spatial_error_u);
mean_t = mean(result.spatial_error_t);

fprintf("[参数仿真完成]\n");
fprintf("无人机空间误差均值: %.5f m\n", mean_u);
fprintf("目标空间误差均值  : %.5f m\n", mean_t);

% ===== 进行 ±50% 灵敏度分析 =====
param_fields = fieldnames(params);
exclude_fields = {"dt", "delay_steps", "gimbal_delay_steps"};
results = {};
for i = 1:length(param_fields)
    field = param_fields{i};
    if any(strcmp(field, exclude_fields)); continue; end

    base_val = params.(field);
    delta = 0.5 * base_val;

    % -50%
    p1 = params;
    p1.(field) = base_val - delta;
    rng(42);
    res1 = simulate_tracking(p1, false);
    err1 = mean(res1.spatial_error_u);

    % +50%
    p2 = params;
    p2.(field) = base_val + delta;
    rng(42);
    res2 = simulate_tracking(p2, false);
    err2 = mean(res2.spatial_error_u);

    results(end+1, :) = {field, base_val, err1, err2, err1-mean_u, err2-mean_u};
end

% 显示表格
T = cell2table(results, 'VariableNames', {'参数', '默认值', '误差_-50', '误差_+50', '变化_-50', '变化_+50'});
disp(T);



