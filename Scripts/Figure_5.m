function plotDynamicData(taskPositions, humanStates, actionLabels)
    minusSign = char(8722); % Unicode U+2212 for minus sign
    figure('Name', ['Figure 3: Dynamic Task Allocation'], 'Position', [100 100 800 600]);
    hold on;
    % Define colors for 5 tasks
    colors = ['r', 'g', 'b', 'm', 'c']; % Red, Green, Blue, Magenta, Cyan for 5 tasks
    taskLabels = {'Task 1', 'Task 2', 'Task 3', 'Task 4', 'Task 5'}; % Labels for 5 tasks
    for i = 1:size(taskPositions, 1)
        scatter3(taskPositions(i, 1), taskPositions(i, 2), taskPositions(i, 3), 200, ...
            colors(i), 'filled', 'LineWidth', 2, 'DisplayName', taskLabels{i});
        text(taskPositions(i, 1), taskPositions(i, 2), taskPositions(i, 3) + 10, ...
            sprintf('F: %.0f%%', humanStates(i).fatigue*100), ...
            'Color', 'black', 'FontName', 'Palatino Linotype', 'FontSize', 14, 'FontWeight', 'bold');
    end
    legend('Location', 'best', 'FontName', 'Palatino Linotype', 'FontSize', 14);
    title(['Dynamic Task Allocation in HRC Environment'], 'FontName', 'Palatino Linotype', 'FontSize', 16);
    xlabel('X (mm)', 'FontName', 'Palatino Linotype', 'FontSize', 14);
    ylabel('Y (mm)', 'FontName', 'Palatino Linotype', 'FontSize', 14);
    zlabel('Z (mm)', 'FontName', 'Palatino Linotype', 'FontSize', 14);
    set(gca, 'FontName', 'Palatino Linotype', 'FontSize', 14);
    grid on;
    view(3);
    % Customize axis tick labels to use minus sign
    xticks = get(gca, 'XTick');
    yticks = get(gca, 'YTick');
    zticks = get(gca, 'ZTick');
    xticklabels = arrayfun(@(x) strrep(num2str(x), '-', minusSign), xticks, 'UniformOutput', false);
    yticklabels = arrayfun(@(y) strrep(num2str(y), '-', minusSign), yticks, 'UniformOutput', false);
    zticklabels = arrayfun(@(z) strrep(num2str(z), '-', minusSign), zticks, 'UniformOutput', false);
    set(gca, 'XTickLabel', xticklabels);
    set(gca, 'YTickLabel', yticklabels);
    set(gca, 'ZTickLabel', zticklabels);
    % Add test text to verify minus sign
    text(mean(taskPositions(:,1)), mean(taskPositions(:,2)), max(taskPositions(:,3)) + 20, ...
        ['Test' minusSign 'Dash'], 'FontName', 'Palatino Linotype', 'FontSize', 14, 'Color', 'black');
    hold off;
end

% Call the function after defining taskPositions and humanStates
plotDynamicData(taskPositions, humanStates, {'Human', 'Robot', 'Collaborative'});