function generateTable2(metrics)
    % Generate Table 2: Performance Metrics by Human State with Tolerances
    % Input: metrics (table from HRC_Simulation_Results.csv)
    fatigueLevels = {'Low', 'Medium', 'High'};
    skillLevels = {'Novice', 'Intermediate', 'Expert'};
    stateIndices = [1, 2, 3, 4, 5, 6, 7, 8, 9]; % 3 fatigue x 3 skill
    
    % Initialize table with additional columns for tolerances
    tableData = table([], [], [], [], [], [], [], [], ...
        'VariableNames', {'FatigueLevel', 'SkillLevel', ...
        'Throughput', 'Throughput_Tolerance', ...
        'Workload', 'Workload_Tolerance', ...
        'Safety', 'Safety_Tolerance'});
    
    for i = 1:length(fatigueLevels)
        for j = 1:length(skillLevels)
            stateIdx = (i-1)*3 + j;
            subset = metrics(metrics.StateIndex == stateIdx, :);
            if ~isempty(subset)
                % Calculate mean and standard error
                n = size(subset, 1); % Number of samples
                throughput_mean = mean(subset.Throughput);
                throughput_std = std(subset.Throughput);
                throughput_se = throughput_std / sqrt(n); % Standard error
                
                workload_mean = mean(subset.Workload);
                workload_std = std(subset.Workload);
                workload_se = workload_std / sqrt(n);
                
                safety_mean = mean(subset.Safety) * 100; % Convert to percentage
                safety_std = std(subset.Safety) * 100;
                safety_se = safety_std / sqrt(n);
                
                % Add row to table
                tableData = [tableData; {fatigueLevels{i}, skillLevels{j}, ...
                    throughput_mean, throughput_se, ...
                    workload_mean, workload_se, ...
                    safety_mean, safety_se}];
            end
        end
    end
    
    % Display table with formatted tolerances
    disp('Table 2: Hybrid DL–RL performance per human state.');
    fprintf('%-15s %-15s %-20s %-20s %-20s\n', ...
        'FatigueLevel', 'SkillLevel', 'Throughput (tasks/min)', 'Workload (fatigue score)', 'Safety (%)');
    for k = 1:height(tableData)
        fprintf('%-15s %-15s %-20s %-20s %-20s\n', ...
            tableData.FatigueLevel{k}, tableData.SkillLevel{k}, ...
            sprintf('%.2f ± %.2f', tableData.Throughput(k), tableData.Throughput_Tolerance(k)), ...
            sprintf('%.2f ± %.2f', tableData.Workload(k), tableData.Workload_Tolerance(k)), ...
            sprintf('%.2f ± %.2f', tableData.Safety(k), tableData.Safety_Tolerance(k)));
    end
    
    % Export to CSV
    writetable(tableData, 'Table_2.csv');
    disp('Table 2 saved to Table_2.csv with tolerance columns');
end

% Call the function with metrics from simulation
metrics = readtable('HRC_Simulation_Results.csv');
generateTable2(metrics);