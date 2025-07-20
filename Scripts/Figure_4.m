function plotConditionalHeatmaps(metrics, actionLog)
    % Plotting conditional heatmaps for task allocation frequencies by action
    % Input: metrics (table from HRC_Simulation_Results.csv), actionLog (array of actions for each episode)
    figure('Name', 'Figure 1b: Conditional Heatmaps of Task Allocation Frequencies', 'Position', [100 100 800 400]);
    
    % Define action labels
    actionLabels = {'Human', 'Robot', 'Collaborative'};
    
    % Filter data for low-fatigue, expert workers (stateIdx = 3)
    lowFatigueExpert = metrics(metrics.StateIndex == 3, :);
    lowFatigueExpertActions = actionLog(metrics.StateIndex == 3);
    subplot(1, 2, 1);
    % Compute throughput by action
    heatmap_data = zeros(3, 1); % 3 actions x 1 state
    for a = 1:3
        idx = lowFatigueExpertActions == a;
        if any(idx)
            heatmap_data(a) = mean(lowFatigueExpert.Throughput(idx));
        else
            heatmap_data(a) = 0; % No assignments for this action
        end
    end
    disp('Debug: heatmap_data for Low-Fatigue, Expert Workers:');
    disp(heatmap_data);
    imagesc(heatmap_data);
    title('(a) Low-Fatigue, Expert Workers', 'FontName', 'Palatino Linotype', 'FontSize', 14);
    xlabel('State', 'FontName', 'Palatino Linotype', 'FontSize', 12);
    ylabel('Action', 'FontName', 'Palatino Linotype', 'FontSize', 12);
    set(gca, 'YTick', 1:3, 'YTickLabel', actionLabels, 'FontName', 'Palatino Linotype', 'FontSize', 12);
    set(gca, 'XTick', 1, 'XTickLabel', {'StateIdx = 3'});
    colorbar;
    
    % Filter data for high-fatigue, novice workers (stateIdx = 7)
    highFatigueNovice = metrics(metrics.StateIndex == 7, :);
    highFatigueNoviceActions = actionLog(metrics.StateIndex == 7);
    subplot(1, 2, 2);
    % Compute throughput by action
    heatmap_data_high = zeros(3, 1); % 3 actions x 1 state
    for a = 1:3
        idx = highFatigueNoviceActions == a;
        if any(idx)
            heatmap_data_high(a) = mean(highFatigueNovice.Throughput(idx));
        else
            heatmap_data_high(a) = 0; % No assignments for this action
        end
    end
    disp('Debug: heatmap_data for High-Fatigue, Novice Workers:');
    disp(heatmap_data_high);
    imagesc(heatmap_data_high);
    title('(b) High-Fatigue, Novice Workers', 'FontName', 'Palatino Linotype', 'FontSize', 14);
    xlabel('State', 'FontName', 'Palatino Linotype', 'FontSize', 12);
    ylabel('Action', 'FontName', 'Palatino Linotype', 'FontSize', 12);
    set(gca, 'YTick', 1:3, 'YTickLabel', actionLabels, 'FontName', 'Palatino Linotype', 'FontSize', 12);
    set(gca, 'XTick', 1, 'XTickLabel', {'StateIdx = 7'});
    colorbar;
    
    % Set common color limits for both subplots
    all_data = [heatmap_data(:); heatmap_data_high(:)];
    cmin = min(all_data(all_data > 0)); % Exclude zeros
    cmax = max(all_data);
    disp(['Debug: Common CLim set to [' num2str(cmin) ', ' num2str(cmax) ']']);
    set(gca, 'CLim', [cmin cmax]);
    subplot(1, 2, 1);
    set(gca, 'CLim', [cmin cmax]);
    
    rng(10);
    colormap('jet');
    
    % Add text annotations with dynamic contrast
    cmap = jet; % Get colormap
    for a = 1:3
        % Subplot 1: Low-Fatigue, Expert Workers
        subplot(1, 2, 1);
        if heatmap_data(a) > 0
            % Normalize value to colormap range
            norm_val = (heatmap_data(a) - cmin) / (cmax - cmin);
            idx = round(norm_val * (size(cmap, 1) - 1)) + 1;
            idx = max(1, min(idx, size(cmap, 1))); % Ensure index is valid
            bgColor = cmap(idx, :);
            % Compute luminance for contrast
            luminance = 0.299*bgColor(1) + 0.587*bgColor(2) + 0.114*bgColor(3);
            textColor = [1 1 1]; % White
            if luminance > 0.5
                textColor = [0 0 0]; % Black
            end
            text(1, a, sprintf('%.2f', heatmap_data(a)), 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'Color', textColor, 'FontName', 'Palatino Linotype', 'FontSize', 13);
        end
        
        % Subplot 2: High-Fatigue, Novice Workers
        subplot(1, 2, 2);
        if heatmap_data_high(a) > 0
            norm_val = (heatmap_data_high(a) - cmin) / (cmax - cmin);
            idx = round(norm_val * (size(cmap, 1) - 1)) + 1;
            idx = max(1, min(idx, size(cmap, 1))); % Ensure index is valid
            bgColor = cmap(idx, :);
            luminance = 0.299*bgColor(1) + 0.587*bgColor(2) + 0.114*bgColor(3);
            textColor = [1 1 1]; % White
            if luminance > 0.5
                textColor = [0 0 0]; % Black
            end
            text(1, a, sprintf('%.2f', heatmap_data_high(a)), 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'Color', textColor, 'FontName', 'Palatino Linotype', 'FontSize', 13);
        end
    end
end

% Call the function with metrics and action log
metrics = readtable('HRC_Simulation_Results.csv');
plotConditionalHeatmaps(metrics, metrics.Action);