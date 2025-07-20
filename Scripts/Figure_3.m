function plotHeatmap(qTable)
    % Plotting heatmap of average Q-values with larger text and Palatino Linotype
    figure('Name', 'Figure 1: Q-Table Heatmap', 'Position', [100 100 600 400]);
    avgQ = reshape(mean(qTable, 2), 3, 3); % Average Q-values for 3x3 states
    imagesc(avgQ);
    colorbar;
    title('Heatmap of Average Q-Values Across Fatigue and Skill Levels', 'FontName', 'Palatino Linotype', 'FontSize', 15);
    xlabel('Skill Level (1=Novice, 2=Intermediate, 3=Expert)', 'FontName', 'Palatino Linotype', 'FontSize', 13);
    ylabel('Fatigue Level (1=Low, 2=Medium, 3=High)', 'FontName', 'Palatino Linotype', 'FontSize', 13);
    set(gca, 'XTick', 1:3, 'YTick', 1:3, 'FontName', 'Palatino Linotype', 'FontSize', 13);
    set(gca, 'XTickLabel', {'Novice', 'Intermediate', 'Expert'});
    set(gca, 'YTickLabel', {'Low', 'Medium', 'High'});
    
    % Get the current colormap
    cmap = jet;  % Same as colormap('jet')
    cmin = min(avgQ(:));
    cmax = max(avgQ(:));

    for i = 1:3
        for j = 1:3
            val = avgQ(i, j);
            % Normalize value to [0,1] range for colormap indexing
            idx = round((val - cmin) / (cmax - cmin) * (size(cmap, 1) - 1)) + 1;
            bgColor = cmap(idx, :);

            % Compute luminance to decide text color (black or white)
            % Luminance formula: https://www.w3.org/TR/RELAY/ 
            luminance = 0.299*bgColor(1) + 0.587*bgColor(2) + 0.114*bgColor(3);
            textColor = 'black';
            if luminance < 0.5
                textColor = 'white';
            end

            % Place the text
            text(j, i, sprintf('%.2f', val), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'Color', textColor, 'FontName', 'Palatino Linotype', 'FontSize', 14);
        end
    end

    colormap('jet');
end

% Call the function after the simulation
plotHeatmap(qTable);