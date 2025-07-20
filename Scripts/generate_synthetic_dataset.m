function generateSyntheticDataset()
    % Generate synthetic dataset in Parquet format for 1,000 HRC episodes
    % Based on Paper_RoboDK (page 4, Section 2.2): human-state, robot-performance, task attributes
    % Expands HRC_Simulation_Results.csv with synthetic data
    rng(42); % Reproducibility

    % Load existing results
    if exist('HRC_Simulation_Results.csv', 'file')
        metrics = readtable('HRC_Simulation_Results.csv');
    else
        error('HRC_Simulation_Results.csv not found. Please ensure it is in the working directory.');
    end
    numRows = height(metrics);

    % Validate metrics structure and debug dimensions
    expectedColumns = {'Throughput', 'Workload', 'Safety', 'StateIndex', 'Action'};
    if numRows == 0
        error('HRC_Simulation_Results.csv is empty.');
    end
    if ~all(ismember(expectedColumns, metrics.Properties.VariableNames))
        missingCols = setdiff(expectedColumns, metrics.Properties.VariableNames);
        error('Missing columns in HRC_Simulation_Results.csv: %s. Found columns: %s', ...
              strjoin(missingCols, ', '), strjoin(metrics.Properties.VariableNames, ', '));
    end
    disp('Dimensions of metrics columns:');
    for col = expectedColumns
        disp([char(col) ': ' num2str(size(metrics.(char(col))))]);
    end

    % Add Episode column if missing
    if ~ismember('Episode', metrics.Properties.VariableNames)
        metrics.Episode = (1:numRows)';
        disp('Added Episode column (1 to ' + num2str(numRows) + ')');
    else
        disp(['Episode column found: ' num2str(size(metrics.Episode))]);
    end

    % Generate synthetic data with matching rows
    fatigue = max(0, min(1, normrnd(0.5, 0.12, numRows, 1))); % N(0.5, 0.12), clipped [0,1]
    skill = randsample([0, 1, 2], numRows, true, [1/3, 1/3, 1/3])'; % Transpose to [1000 1]
    completionTime = max(5, normrnd(10, 2, numRows, 1)); % N(10, 2)
    robotSuccess = binornd(1, 0.98, numRows, 1); % 98% success rate
    robotExecTime = max(5, normrnd(8, 1, numRows, 1)); % N(8, 1)
    collisionFlag = 1 - metrics.Safety; % From existing data

    % Debug dimensions of all variables
    disp('Dimensions of all variables:');
    disp(['metrics.Episode: ' num2str(size(metrics.Episode))]);
    disp(['metrics.Throughput: ' num2str(size(metrics.Throughput))]);
    disp(['metrics.Workload: ' num2str(size(metrics.Workload))]);
    disp(['metrics.Safety: ' num2str(size(metrics.Safety))]);
    disp(['metrics.StateIndex: ' num2str(size(metrics.StateIndex))]);
    disp(['metrics.Action: ' num2str(size(metrics.Action))]);
    disp(['fatigue: ' num2str(size(fatigue))]);
    disp(['skill: ' num2str(size(skill))]);
    disp(['completionTime: ' num2str(size(completionTime))]);
    disp(['robotSuccess: ' num2str(size(robotSuccess))]);
    disp(['robotExecTime: ' num2str(size(robotExecTime))]);
    disp(['collisionFlag: ' num2str(size(collisionFlag))]);

    % Create initial table with one row per episode
    dataset = table(...
        metrics.Episode, ... % Episode from CSV or generated
        metrics.Throughput, ... % Throughput from CSV
        metrics.Workload, ... % Workload from CSV
        metrics.Safety, ... % Safety from CSV
        metrics.StateIndex, ... % StateIndex from CSV
        metrics.Action, ... % Action from CSV
        fatigue, ... % Synthetic fatigue
        skill, ... % Synthetic skill
        completionTime, ... % Synthetic completion time
        robotSuccess, ... % Synthetic robot success
        robotExecTime, ... % Synthetic robot execution time
        collisionFlag, ... % Synthetic collision flag
        'VariableNames', {'Episode', 'Throughput', 'Workload', 'Safety', 'StateIndex', 'Action', ...
                         'Fatigue', 'Skill', 'CompletionTime', 'RobotSuccess', 'RobotExecTime', ...
                         'CollisionFlag'});

    % Check dataset dimensions
    if height(dataset) ~= numRows
        error('Generated dataset has %d rows, expected %d rows.', height(dataset), numRows);
    end

    % Expand dataset for 5 tasks per episode
    expandedDataset = repmat(dataset, 5, 1); % Replicate 5 times
    numRowsExpanded = height(expandedDataset);
    disp(['Expanded dataset rows: ' num2str(numRowsExpanded)]);

    % Debug expanded dataset dimensions
    disp('Dimensions of expanded dataset columns:');
    for col = dataset.Properties.VariableNames
        disp([char(col) ': ' num2str(size(expandedDataset.(char(col))))]);
    end

    % Task attributes (5 tasks per episode)
    taskIDs = reshape(repmat(1:5, numRows, 1), numRowsExpanded, 1); % Ensure 5000x1 vector
    disp(['taskIDs size: ' num2str(size(taskIDs))]);
    taskTypes = reshape(randsample({'human-centric', 'robot-centric', 'collaborative'}, numRowsExpanded, true), numRowsExpanded, 1);
    disp(['taskTypes size: ' num2str(size(taskTypes))]);
    taskComplexity = reshape(rand(numRowsExpanded, 1), numRowsExpanded, 1);
    disp(['taskComplexity size: ' num2str(size(taskComplexity))]);

    % Add task attributes using addvars with explicit row matching
    if size(taskIDs, 1) ~= numRowsExpanded || size(taskTypes, 1) ~= numRowsExpanded || size(taskComplexity, 1) ~= numRowsExpanded
        error('Mismatch in task attribute rows. Expected %d, got TaskIDs: %d, TaskTypes: %d, TaskComplexity: %d', ...
              numRowsExpanded, size(taskIDs, 1), size(taskTypes, 1), size(taskComplexity, 1));
    end
    expandedDataset = addvars(expandedDataset, taskIDs, taskTypes, taskComplexity, ...
                             'NewVariableNames', {'TaskID', 'TaskType', 'TaskComplexity'});

    % Save as Parquet
    parquetwrite('HRC_Synthetic_Dataset.parquet', expandedDataset);
    disp('Synthetic dataset saved to HRC_Synthetic_Dataset.parquet');
end