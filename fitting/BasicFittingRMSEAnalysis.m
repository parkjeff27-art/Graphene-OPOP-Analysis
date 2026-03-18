function BasicFittingRMSEAnalysis()
    %{
    기본 TTM Biexponential Fit + RMSE 분석
    - 박준수 AGI혁신가님 요청사항: 문법 오류 없이 돌아가는 통합 버전
    - 아래 local function들을 한 파일에 넣어서 함수형으로 구성
    - MATLAB R2016b 이상 환경에서 정상 동작
    %}

    clear; close all; clc;

    %% 1. 엑셀 파일 불러오기
    file_path = 'Fittinginputdata.xlsx';
    data = readtable(file_path, 'Sheet', 'Sheet1');

    % 시간 축 추출 및 단위 변환
    x_all = table2array(data(:,1));
    if abs(x_all(1)) < 1e-10
        x_all = x_all * 1e12; % 초 -> 피코초 변환
    end

    % Gate voltage 컬럼들 추출
    gate_cols = data.Properties.VariableNames(2:end);

    %% 정확한 전압 매핑 (엑셀 컬럼명 -> 실제 전압)
    fprintf('=== 기본 성공 코드 + RMSE 분석 ===\n');
    voltage_mapping = containers.Map();
    voltage_mapping('x_15V')    = -15;
    voltage_mapping('x_6V')     = -6;
    voltage_mapping('x_1V')     = -1;
    voltage_mapping('x4V_DP_')  = 4;
    voltage_mapping('x9V')      = 9;
    voltage_mapping('x14V')     = 14;
    voltage_mapping('x20V')     = 20;

    % 결과 저장용 Map (필요하다면 사용)
    normalized_signals = containers.Map();
    x_values = containers.Map();
    results = {};  % cell로 저장

    %% 2. 기본 피팅 루프
    figure('Position', [100, 100, 1200, 600]);
    colors = lines(length(gate_cols));
    result_idx = 1;

    for i = 1:length(gate_cols)
        col = gate_cols{i};
        if ~isKey(voltage_mapping, col)
            fprintf('\n⚠️ "%s"는 voltage_mapping에 없음 -> 스킵\n', col);
            continue;
        end

        vg = voltage_mapping(col);
        fprintf('\n########## %.0fV 피팅 시작 ##########\n', vg);

        % 데이터 추출
        y_raw = table2array(data(:, i+1));
        y_raw = y_raw(~isnan(y_raw));  % NaN 제거
        x = x_all(1:length(y_raw));    % 길이 맞춰서 짝지어줌

        if length(x) < 5
            fprintf('데이터 길이 %d -> 너무 짧아서 스킵\n', length(x));
            continue;
        end

        % 정규화
        baseline = median(y_raw(1:round(length(x) * 0.1)));
        y_shifted = y_raw - baseline;
        max_val = max(y_shifted);
        min_val = min(y_shifted);

        % 그래프 기준: 음의 픽이 더 크면 graphene_on_au로 가정
        if abs(min_val) > abs(max_val)
            system_type = 'graphene_on_au';
            norm_factor = abs(min_val);
        else
            system_type = 'graphene';
            norm_factor = max_val;
        end

        if abs(norm_factor) <= 1e-10
            norm_factor = 1.0;
        end

        y_norm = y_shifted / norm_factor;
        normalized_signals(col) = y_norm;
        x_values(col) = x;

        % 🔧 기본 피팅
        [p0, y_fit, rmse] = simple_working_fitting(x, y_norm, system_type);

        if ~isempty(p0)
            tau = p0(4);

            % 결과 저장
            results{result_idx, 1} = col;
            results{result_idx, 2} = vg;
            results{result_idx, 3} = system_type;
            results{result_idx, 4} = tau;
            results{result_idx, 5} = rmse;
            result_idx = result_idx + 1;

            % 플롯
            plot(x, y_norm, 'o', 'MarkerSize', 3, 'Color', colors(i,:), ...
                 'MarkerFaceColor', colors(i,:));
            hold on;
            plot(x, y_fit, '-', 'LineWidth', 2, 'Color', colors(i,:), ...
                'DisplayName', sprintf('%.0fV (tau=%.3f, RMSE=%.4f)', vg, tau, rmse));

            fprintf('%.0fV | %s | tau=%.3f ps | RMSE=%.4f ✅\n', vg, system_type, tau, rmse);
        else
            fprintf('%.0fV | 피팅 실패 ❌\n', vg);
        end
    end

    title('기본 TTM Biexponential Fit (tau & RMSE 표시)');
    xlabel('Delay Time (ps)');
    ylabel('Normalized Intensity');
    grid on;
    legend('show', 'Location', 'best');
    hold off;

    %% 3. 결과 분석 + RMSE 시각화
    if ~isempty(results)
        fprintf('\n=== 최종 결과 (RMSE 포함) ===\n');

        vg_values  = cell2mat(results(:,2));
        tau_values = cell2mat(results(:,4));
        rmse_values= cell2mat(results(:,5));

        [vg_sorted, sort_idx] = sort(vg_values);
        tau_sorted  = tau_values(sort_idx);
        rmse_sorted = rmse_values(sort_idx);

        for j = 1:length(vg_sorted)
            fprintf('%.0fV: tau=%.3f ps | RMSE=%.4f\n', ...
                vg_sorted(j), tau_sorted(j), rmse_sorted(j));
        end

        % 🎨 RMSE 포함 이중 그래프
        figure('Position', [200, 200, 1200, 500]);

        % 서브플롯 1: Gate Voltage vs tau (RMSE 에러바)
        subplot(1,2,1);
        errorbar(vg_sorted, tau_sorted, rmse_sorted, 'o-', 'LineWidth', 2, ...
            'MarkerSize', 8, 'MarkerFaceColor', 'blue', 'CapSize', 6);
        title('Gate Voltage vs tau (RMSE 에러바)');
        xlabel('Gate Voltage (V)');
        ylabel('tau (ps)');
        grid on;
        xlim([min(vg_sorted)-2, max(vg_sorted)+2]);

        % tau 값 표시
        for j = 1:length(vg_sorted)
            text(vg_sorted(j), tau_sorted(j) + max(rmse_sorted)*0.3, ...
                sprintf('%.3f', tau_sorted(j)), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 9);
        end

        % 서브플롯 2: Gate Voltage vs RMSE
        subplot(1,2,2);
        bar(vg_sorted, rmse_sorted, 'FaceColor', [0.8 0.2 0.2], ...
            'EdgeColor', 'black', 'LineWidth', 1);
        title('Gate Voltage vs RMSE (피팅 품질)');
        xlabel('Gate Voltage (V)');
        ylabel('RMSE');
        grid on;

        % RMSE 값 표시
        for j = 1:length(vg_sorted)
            text(vg_sorted(j), rmse_sorted(j) + max(rmse_sorted)*0.05, ...
                sprintf('%.4f', rmse_sorted(j)), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 9);
        end

        % RMSE 품질 평가 선 추가 (원하시면 유지)
        hold on;
        yline(0.01, '--g', 'LineWidth', 2, 'Label', '우수 (RMSE < 0.01)');
        yline(0.05, '--y', 'LineWidth', 2, 'Label', '양호 (RMSE < 0.05)');
        yline(0.1, '--r', 'LineWidth', 2, 'Label', '개선필요 (RMSE > 0.1)');
        hold off;

        % 📊 RMSE 통계 요약
        fprintf('\n=== RMSE 품질 분석 ===\n');
        fprintf('평균 RMSE: %.4f\n', mean(rmse_sorted));
        fprintf('최소 RMSE: %.4f (%.0fV)\n', ...
            min(rmse_sorted), vg_sorted(rmse_sorted == min(rmse_sorted)));
        fprintf('최대 RMSE: %.4f (%.0fV)\n', ...
            max(rmse_sorted), vg_sorted(rmse_sorted == max(rmse_sorted)));
        fprintf('RMSE 표준편차: %.4f\n', std(rmse_sorted));

        % 품질 등급 분류
        excellent = sum(rmse_sorted < 0.01);
        good      = sum(rmse_sorted >= 0.01 & rmse_sorted < 0.05);
        fair      = sum(rmse_sorted >= 0.05 & rmse_sorted < 0.1);
        poor      = sum(rmse_sorted >= 0.1);

        fprintf('\n=== 피팅 품질 등급 ===\n');
        fprintf('우수 (RMSE < 0.01): %d개 전압\n', excellent);
        fprintf('양호 (0.01 ≤ RMSE < 0.05): %d개 전압\n', good);
        fprintf('보통 (0.05 ≤ RMSE < 0.1): %d개 전압\n', fair);
        fprintf('개선필요 (RMSE ≥ 0.1): %d개 전압\n', poor);

        % 전체 평가
        avg_rmse = mean(rmse_sorted);
        if avg_rmse < 0.01
            fprintf('\n🎉 전체 피팅 품질: 우수! (평균 RMSE < 0.01)\n');
        elseif avg_rmse < 0.05
            fprintf('\n✅ 전체 피팅 품질: 양호 (평균 RMSE < 0.05)\n');
        else
            fprintf('\n⚠️ 전체 피팅 품질: 개선 권장 (평균 RMSE ≥ 0.05)\n');
        end
    end

    %% 4. 결과 저장 (RMSE 포함)
    if ~isempty(results)
        results_table = cell2table(results, 'VariableNames', ...
            {'Column_Name','Gate_Voltage_V','System_Type','Tau_ps','RMSE'});
        writetable(results_table, 'Working_FittingResults_with_RMSE.xlsx');
        fprintf('\n✅ Working_FittingResults_with_RMSE.xlsx 저장 완료\n');
    end

    fprintf('\n=== 기본 피팅 + RMSE 분석 완료 ===\n');
end


%% ===================== [아래는 subfunction들] ========================
function out = ttm_model_simple(params, x)
    % 기본 TTM 모델
    A_e   = params(1);
    A_l   = params(2);
    tau_e = params(3);
    tau   = params(4);
    tau_l = params(5);
    y0    = params(6);
    x0    = params(7);

    out = y0 * ones(size(x));
    mask = x >= x0;

    if any(mask)
        t = x(mask) - x0;
        tau_e = max(tau_e, 1e-6);
        tau   = max(tau,   1e-6);
        tau_l = max(tau_l, 1e-6);

        e_term = A_e * (1 - exp(-t / tau_e)) .* exp(-t / tau);
        l_term = A_l * (1 - exp(-t / tau))   .* exp(-t / tau_l);
        out(mask) = e_term + l_term + y0;
    end
end

function width = simple_measure_width(x, y, threshold, system_type)
    % 폭 측정
    try
        [x_unique, unique_idx] = unique(x, 'stable');
        y_unique = y(unique_idx);

        if length(x_unique) < 3
            width = NaN;
            return;
        end

        x_fine = linspace(x_unique(1), x_unique(end), 5000);
        y_fine = interp1(x_unique, y_unique, x_fine, 'linear', 'extrap');

        if strcmp(system_type, 'graphene')
            idx = find(y_fine >= threshold);
        else
            idx = find(y_fine <= threshold);
        end

        if length(idx) < 2
            width = NaN;
            return;
        end

        width = x_fine(idx(end)) - x_fine(idx(1));
    catch
        width = NaN;
    end
end

function [best_params, best_fit, best_rmse] = simple_working_fitting(x, y, system_type)
    % 기본 피팅 함수
    % 파라미터 순서: [A_e, A_l, tau_e, tau, tau_l, y0, x0]
    y0 = median(y(1:max(1, round(length(x) * 0.1))));

    if strcmp(system_type, 'graphene')
        [~, peak_idx] = max(y);
        thresholds = [0.2, 0.3, 0.4, 0.5, 0.6];
    else
        [~, peak_idx] = min(y);
        thresholds = [-0.2, -0.3, -0.4, -0.5, -0.6];
    end

    x0    = max(min(x(peak_idx) - 0.15, 2.5), 1.4);
    A_e   = (y(peak_idx) - y0) * 0.9;
    tau_e = 0.15;
    tau_l = 4.0;

    best_rmse   = inf;
    best_params = [];
    best_fit    = [];

    for i = 1:length(thresholds)
        th = thresholds(i);
        tau = simple_measure_width(x, y, th, system_type);

        if isnan(tau)
            continue;
        end
        tau = max(min(tau, 3.0), 0.1);

        p0 = [A_e, 0.2, tau_e, tau, tau_l, y0, x0];

        % 경계 조건
        lb = [-3, -1, 0.01, 0.05, 1, -0.2, 1.4];
        ub = [ 3,  3, 0.5,  3.0, 10,  0.2, 2.6];

        if any(p0 < lb) || any(p0 > ub)
            p0 = max(min(p0, ub), lb);
        end

        % lsqcurvefit 옵션
        options = optimoptions('lsqcurvefit', ...
            'Display','off', 'MaxIterations',3000);

        try
            [popt, ~, ~, exitflag] = lsqcurvefit(@ttm_model_simple, ...
                p0, x, y, lb, ub, options);

            if exitflag <= 0
                continue;
            end

            y_fit = ttm_model_simple(popt, x);
            if any(isnan(y_fit)) || any(isinf(y_fit))
                continue;
            end

            rmse = sqrt(mean((y - y_fit).^2));
            if rmse < best_rmse
                best_rmse   = rmse;
                best_params = popt;
                best_fit    = y_fit;
            end
        catch
            continue;
        end
    end
end
