function plotProofOfConcept(RDK, taskPositions, humanStates)
    % Plotting proof of concept in RoboDK with dynamic styling distinct from Figure 3
    % Check and set default arguments if not provided
    if nargin < 1 || isempty(RDK)
        RDK = Robolink(); % Use existing connection or create new if none
        if isempty(RDK)
            disp('RoboDK not available. Using MATLAB-only visualization.');
            RDK = [];
        end
    end
    if nargin < 2 || isempty(taskPositions)
        taskPositions = [
            500, 0, 100, 0, 0, 0;   % t1: Interface
            600, 100, 100, 0, 0, 0; % t2: Sorting
            600, -100, 100, 0, 0, 0; % t3: Picking
            700, 0, 100, 0, 0, 0;   % t4: Replenishing
            800, 0, 100, 0, 0, 0    % t5: Transport
        ];
        disp('Default taskPositions initialized.');
    end
    if nargin < 3 || isempty(humanStates)
        humanStates = struct('fatigue', {0.20, 0.30, 0.35, 0.25, 0.50}, ...
            'skill', {'intermediate', 'intermediate', 'expert', 'intermediate', 'novice'});
        disp('Default humanStates initialized.');
    end

    minusSign = char(8722); % Unicode U+2212 for minus sign
    if ~isempty(RDK)
        % Attempt to re-establish connection on default port 20500
        try
            RDK = Robolink(); % Use existing connection, no forced close to avoid issues
            if ~isempty(RDK)
                disp('Connection established on port 20500.');
            else
                error('Failed to connect to RoboDK on port 20500. Check if RoboDK is running.');
            end
        catch ME
            disp(['Connection issue detected: ' ME.message '. Proceeding without RoboDK.']);
            RDK = [];
        end
        % Add delay to allow server to stabilize
        pause(3); % 3-second delay
        figure('Name', ['Proof of Concept in RoboDK'], 'Position', [100 100 800 600]);
        hold on;
        % Verify taskPositions dimensions
        if size(taskPositions, 2) < 3
            error('taskPositions must have at least 3 columns (x, y, z).');
        end
        % Define colors and markers distinct from Figure 3
        colors = ['r', 'g', 'b', 'm', 'c']; % Red, Green, Blue, Magenta, Cyan
        markers = {'o', 's', '^', 'd', 'p'}; % Circle, Square, Triangle, Diamond, Pentagon
        taskLabels = {'Task 1 (RoboDK): Interface', 'Task 2 (RoboDK): Sorting', 'Task 3 (RoboDK): Picking', 'Task 4 (RoboDK): Replenishing', 'Task 5 (RoboDK): Transport'};
        maxRetries = 3; % Maximum number of retries per target
        robodkSuccess = false;
        for i = 1:size(taskPositions, 1)
            % Explicitly construct 4x4 homogeneous transformation matrix
            x = taskPositions(i, 1);
            y = taskPositions(i, 2);
            z = taskPositions(i, 3);
            pose = zeros(4, 4);
            pose(1, 1:4) = [1, 0, 0, x];   % Row 1: [R11 R12 R13 x]
            pose(2, 1:4) = [0, 1, 0, y];   % Row 2: [R21 R22 R23 y]
            pose(3, 1:4) = [0, 0, 1, z];   % Row 3: [R31 R32 R33 z]
            pose(4, 1:4) = [0, 0, 0, 1];   % Row 4: [0 0 0 1]
            poseVector = pose(:); % 16x1 column vector
            disp(['Debug: pose for ' taskLabels{i} ':']);
            disp(pose); % Debug pose matrix
            disp(['Debug: poseVector for ' taskLabels{i} ' (16x1):']);
            disp(poseVector);
            retries = 0;
            targetAdded = false;
            while retries < maxRetries && ~targetAdded && ~isempty(RDK)
                try
                    target = RDK.AddTarget(taskLabels{i}, poseVector); % Use taskLabels for consistency
                    targetAdded = true;
                    robodkSuccess = true;
                catch ME
                    retries = retries + 1;
                    disp(['AddTarget failed for ' taskLabels{i} ' (Attempt ' num2str(retries) '): ' ME.message]);
                    if retries < maxRetries
                        pause(1); % Wait 1 second before retry
                        disp('Retrying...');
                    else
                        disp(['All ' num2str(maxRetries) ' attempts failed for ' taskLabels{i} '.']);
                        disp(['poseVector for ' taskLabels{i} ':']);
                        disp(poseVector);
                    end
                end
            end
            % Plot with distinct markers and colors
            scatter3(taskPositions(i, 1), taskPositions(i, 2), taskPositions(i, 3), 200, ...
                colors(i), markers{i}, 'LineWidth', 2, 'DisplayName', taskLabels{i});
            % Set text color to black for fatigue labels, centered above markers
            textColor = 'black'; % Force black color for visibility
            disp(['Debug for ' taskLabels{i} ': textColor forced to black']);
            text(taskPositions(i, 1), taskPositions(i, 2), taskPositions(i, 3) + 0.4, ...
                ['Fatigue: ' sprintf('%.0f', humanStates(i).fatigue * 100) '%'], ...
                'Color', textColor, 'FontName', 'Palatino Linotype', 'FontSize', 14, ...
                'FontWeight', 'bold', 'BackgroundColor', 'white', 'Margin', 1, ...
                'HorizontalAlignment', 'center');
        end
        if ~robodkSuccess && ~isempty(RDK)
            disp('Warning: No targets were added to RoboDK due to server issues. Visualization is MATLAB-only.');
        end
        if ~isempty(RDK)
            disp('Check RoboDK interface for real-time visualization.');
        end
        legend('Location', 'best', 'FontName', 'Palatino Linotype', 'FontSize', 14, 'Interpreter', 'none');
        title(['Proof of Concept: Task Positions in RoboDK'], 'FontName', 'Palatino Linotype', 'FontSize', 16);
        xlabel(['X (mm)'], 'FontName', 'Palatino Linotype', 'FontSize', 14);
        ylabel(['Y (mm)'], 'FontName', 'Palatino Linotype', 'FontSize', 14);
        zlabel(['Z (mm)'], 'FontName', 'Palatino Linotype', 'FontSize', 14);
        set(gca, 'FontName', 'Palatino Linotype', 'FontSize', 14);
        % Adjust ZLim to include fatigue labels
        set(gca, 'ZLim', [99 102]);
        grid on;
        view(3);
        % Customize axis tick labels using minusSign explicitly
        xticks = linspace(500, 800, 3); % Match X range [500, 800]
        if ~isnumeric(xticks) || isempty(xticks)
            disp('Warning: xticks generation failed. Forcing to [500 650 800].');
            xticks = [500, 650, 800];
        end
        xticklabels = cell(1, length(xticks));
        for k = 1:length(xticks)
            if isnumeric(xticks(k)) && isfinite(xticks(k))
                if xticks(k) < 0
                    xticklabels{k} = [minusSign num2str(abs(xticks(k)))]; % Use minusSign for negative values
                else
                    xticklabels{k} = num2str(xticks(k));
                end
            else
                xticklabels{k} = num2str(500 + (k-1)*150); % Fallback
            end
        end
        yticks = linspace(-100, 100, 5); % Match Y range [-100, 100]
        if ~isnumeric(yticks) || isempty(yticks)
            disp('Warning: yticks generation failed. Forcing to [-100 -50 0 50 100].');
            yticks = [-100, -50, 0, 50, 100];
        end
        yticklabels = cell(1, length(yticks));
        for k = 1:length(yticks)
            if isnumeric(yticks(k)) && isfinite(yticks(k))
                if yticks(k) < 0
                    yticklabels{k} = [minusSign num2str(abs(yticks(k)))]; % Use minusSign for negative values
                else
                    yticklabels{k} = num2str(yticks(k));
                end
            else
                yticklabels{k} = num2str(-100 + (k-1)*50); % Fallback
            end
        end
        zticks = linspace(100, 102, 3); % Match adjusted Z range [100, 102]
        if ~isnumeric(zticks) || isempty(zticks)
            disp('Warning: zticks generation failed. Forcing to [100 101 102].');
            zticks = [100, 101, 102];
        end
        zticklabels = cell(1, length(zticks));
        for k = 1:length(zticks)
            if isnumeric(zticks(k)) && isfinite(zticks(k))
                if zticks(k) < 0
                    zticklabels{k} = [minusSign num2str(abs(zticks(k)))]; % Use minusSign for negative values
                else
                    zticklabels{k} = num2str(zticks(k));
                end
            else
                zticklabels{k} = num2str(100 + (k-1)*1); % Fallback
            end
        end
        disp('Debug: xticklabels generated:');
        disp(xticklabels);
        disp('Debug: yticklabels generated:');
        disp(yticklabels);
        disp('Debug: zticklabels generated:');
        disp(zticklabels);
        set(gca, 'XTick', xticks);
        set(gca, 'YTick', yticks);
        set(gca, 'ZTick', zticks);
        set(gca, 'XTickLabel', xticklabels);
        set(gca, 'YTickLabel', yticklabels);
        set(gca, 'ZTickLabel', zticklabels);
        hold off;
    else
        disp('RoboDK not available. Cannot generate Figure 4.');
    end
    % Debug: Verify figure rendering
    disp('Debug: Figure rendering completed. Checking axes state...');
    disp(get(gca));
    % Ensure proper line termination
    ;
end