function plotRoboDKSnapshot()
    % Updated script to simulate Figure 1: Snapshot of RoboDK assembly line
    % Based on real RoboDK capture; use as fallback if RoboDK is unavailable
    % Note: Actual RoboDK snapshot should be exported directly from RoboDK
    figure('Name', 'Figure 1: RoboDK Assembly Line Snapshot', 'Position', [100 100 800 600]);
    hold on;
    
    % Simulate Doosan H2017 cobot and human avatar
    plot3([500 600], [0 0], [100 100], 'b-', 'LineWidth', 2, 'DisplayName', 'Cobot Arm');
    scatter3(550, 0, 100, 50, 'black', 'filled', 'DisplayName', 'Human Avatar');
    
    % Simulate conveyor
    plot3([500 800], [50 50], [90 90], 'k--', 'LineWidth', 2, 'DisplayName', 'Conveyor');
    
    % Task positions and labels based on new image
    tasks = [500, 0, 100; 600, 100, 100; 600, -100, 100; 700, 0, 100; 800, 0, 100];
    task_labels = {'Interface', 'Sorting', 'Picking', 'Replenishing', 'Transport'};
    fatigue_values = [20, 30, 35, 25, 50]; % % values from image
    skill_levels = {'Intermediate', 'Intermediate', 'Advanced', 'Intermediate', 'Novice'};
    colors = ['r', 'g', 'b', 'm', 'c'];
    
    for i = 1:5
        scatter3(tasks(i,1), tasks(i,2), tasks(i,3), 100, colors(i), 'filled', 'DisplayName', task_labels{i});
        text(tasks(i,1), tasks(i,2), tasks(i,3)+0.8, sprintf('Task: %s / Fatigue: %d%% / Skill: %s', ...
            task_labels{i}, fatigue_values(i), skill_levels{i}), ...
            'FontName', 'Palatino Linotype', 'FontSize', 14, 'Color', 'black', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
    
    % Add annotations based on new image
    text(500, -50, 110, 'DL Module', 'Color', 'b', 'FontName', 'Palatino Linotype', 'FontSize', 12);
    text(600, -50, 110, 'RL Module', 'Color', 'g', 'FontName', 'Palatino Linotype', 'FontSize', 12);
    text(650, -50, 110, 'Execution Feedback', 'Color', 'y', 'FontName', 'Palatino Linotype', 'FontSize', 12);
    quiver3(500, 0, 100, 0, -50, 0, 'b', 'LineWidth', 2, 'DisplayName', 'Perception Input');
    quiver3(600, 0, 100, 0, -50, 0, 'g', 'LineWidth', 2, 'DisplayName', 'Task Assignment');
    quiver3(650, 0, 100, 0, -50, 0, 'y', 'LineWidth', 2, 'DisplayName', 'Execution Feedback');
    
    title('Snapshot of Simulated Assembly Line', 'FontName', 'Palatino Linotype', 'FontSize', 16);
    xlabel('X (mm)', 'FontName', 'Palatino Linotype', 'FontSize', 14);
    ylabel('Y (mm)', 'FontName', 'Palatino Linotype', 'FontSize', 14);
    zlabel('Z (mm)', 'FontName', 'Palatino Linotype', 'FontSize', 14);
    set(gca, 'FontName', 'Palatino Linotype', 'FontSize', 14);
    legend('Location', 'best', 'FontName', 'Palatino Linotype', 'FontSize', 12);
    grid on;
    view(3);
    hold off;
    
    % Save as high-resolution PNG (fallback)
    exportgraphics(gcf, 'Figure_1.png', 'Resolution', 600);
end