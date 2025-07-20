% Hybrid DL-RL Framework for Task Allocation in HRC
% MATLAB R2025a with RoboDK 5.9.1
% Simulates task allocation in an industrial assembly line
% Author: Urrea (2025)

%% Initialize Environment
clear; clc; close all;
disp('=== HRC Simulation Initializing ===');

%% Verify and Set RoboDK API Path
apiPath = 'C:\RoboDK\API\MATLAB'; % Adjust this path
if ~exist(apiPath, 'dir')
    disp(['RoboDK API path not found: ' apiPath '. Simulation will proceed without RoboDK integration.']);
else
    addpath(apiPath);
    savepath;
    disp(['RoboDK API path set to: ' apiPath]);
end

%% Initialize RoboDK Connection 
RDK = []; % Default to empty if connection fails
robodkAvailable = false; % Flag to track RoboDK availability
    RDK = Robolink(); % Attempt to create RoboDK connection
    disp('Initializing RoboDK-MATLAB connection...');
    if ~isempty(RDK)
        disp('RoboDK-MATLAB connection established.');
        robodkAvailable = true;
        RDK.Render(1); % Enable rendering
        RDK.setSimulationSpeed(5); % Set faster simulation speed
    end

% Initialize variables
robodkAvailable = false;
RDK = [];

% Force display of connection established message if RoboDK is available
try
    apiPath = 'C:\RoboDK\API\MATLAB';
    if exist(apiPath, 'dir')
        addpath(apiPath);
        RDK = Robolink();
        
        % Simple validation - don't throw errors if components missing
        station = RDK.getActiveStation();
        robot = RDK.Item('Human-Robot Collaboration');
        
        if ~isempty(station) && robot.Valid()
            robodkAvailable = true;
            RDK.Render(1);
            RDK.setSimulationSpeed(5);
            disp('RoboDK-MATLAB connection established.');
        end
    end
catch
    % Silent failure - don't display any error messages
end

%% Simulation Parameters
taskPositions = [500, 0, 100, 0, 0, 0;   % Interface
                600, 100, 100, 0, 0, 0;   % Sorting
                600, -100, 100, 0, 0, 0;  % Picking
                700, 0, 100, 0, 0, 0;     % Replenishing
                800, 0, 100, 0, 0, 0];    % Transport

taskQueue = {'pallet1','pallet2','pallet3','pallet4','pallet5'};
disp(['Initial task queue length: ' num2str(numel(taskQueue))]);
rng(42);
%% Generate Human States
numEpisodes = 1000;
humanStates = struct('fatigue', num2cell(rand(1,numEpisodes)), ...
              'skill', num2cell(randsample(1:3,numEpisodes,true,[0.3,0.4,0.3])), ...
              'completionTime', num2cell(max(5,normrnd(10,2,1,numEpisodes))));
disp('Synthetic human states data generated');

%% Display RoboDK Status (Only show if available)
if robodkAvailable
    disp('RoboDK available. Running simulation with RoboDK integration.');
end

%% DQN Initialization
qTable = zeros(9, 3); % States: 3 fatigue × 3 skill levels
epsilon = 0.1; gamma = 0.99; alpha = 0.001;
rewardWeights = [0.5, 0.3, 0.2]; % Throughput, workload, safety

%% Metrics Tracking
metrics = struct('throughput', zeros(numEpisodes,1), ...
                'workload', zeros(numEpisodes,1), ...
                'safety', zeros(numEpisodes,1), ...
                'stateIdx', zeros(numEpisodes,1), ...
                'action', zeros(numEpisodes,1)); % Added action field
startTime = tic;

%% Main Simulation Loop
for episode = 1:numEpisodes
    % Get current state
    state = humanStates(episode);
    [fatigueLvl, skillLvl] = classifyState(state);
    
    % State encoding and display
    fatigueIdx = find(strcmp(fatigueLvl, {'low','medium','high'}));
    skillIdx = find(strcmp(skillLvl, {'novice','intermediate','expert'}));
    stateIdx = (fatigueIdx-1)*3 + skillIdx;
    
    % Store state index
    metrics.stateIdx(episode) = stateIdx;
    fprintf('Episode %d: Calculated stateIdx = %d\n', episode, stateIdx);
    
    % Action selection
    if rand < epsilon
        action = randi(3); % Explore
    else
        [~, action] = max(qTable(stateIdx,:)); % Exploit
    end
    
    % Store action
    metrics.action(episode) = action;
    disp(['Debug: Episode ' num2str(episode) ': Action = ' num2str(action) ' (1=Human, 2=Robot, 3=Collaborative)']);
    
    % Execute action
    [taskTime, fatigueScore, isSafe] = executeAction(action, state, taskQueue{1});
    
    % RoboDK visualization (silent on errors)
    if robodkAvailable
        try
            timePoint = mod(episode-1, size(taskPositions,1)) + 1;
            pos = taskPositions(timePoint,:);
            pose = transl(pos(1:3)) * rotx(deg2rad(pos(4))) * ...
                   roty(deg2rad(pos(5))) * rotz(deg2rad(pos(6)));
            
            if any(action == [2, 3]) % Robot or collaborative
                target = RDK.AddTarget(['Target_' num2str(episode)], pose);
                robot = RDK.Item('Human-Robot Collaboration');
                robot.MoveJ(target);
            end
            
            if any(action == [1, 3]) % Human or collaborative
                human = RDK.AddFrame(['Human_' num2str(episode)]);
                human.setPose(pose);
            end
        catch
            robodkAvailable = false;
        end
    end
    
    % Update metrics
    elapsedTime = toc(startTime)/60;
    metrics.throughput(episode) = episode/max(0.1, elapsedTime);
    metrics.workload(episode) = fatigueScore;
    metrics.safety(episode) = isSafe;
    
    % Update Q-table
    reward = rewardWeights*[metrics.throughput(episode); -fatigueScore; isSafe];
    qTable(stateIdx,action) = qTable(stateIdx,action) + ...
        alpha*(reward + gamma*max(qTable(stateIdx,:)) - qTable(stateIdx,action));
    
    % Manage task queue
    taskQueue = taskQueue(2:end);
    if isempty(taskQueue)
        taskQueue = {'pallet1','pallet2','pallet3','pallet4','pallet5'};
    end
    
    % Progress reporting
    if mod(episode,100) == 0
        fprintf('Completed %d/%d episodes\n', episode, numEpisodes);
    end
end

%% Generate Results
disp('=== Final Results ===');
fprintf('Throughput: %.2f tasks/min\n', mean(metrics.throughput));
fprintf('Workload: %.2f fatigue score\n', mean(metrics.workload));
fprintf('Safety Rate: %.2f%%\n', mean(metrics.safety)*100);

% Save comprehensive results
results = table((1:numEpisodes)', metrics.throughput, metrics.workload, ...
               metrics.safety, metrics.stateIdx, metrics.action, ...
               'VariableNames', {'Episode','Throughput','Workload','Safety','StateIndex','Action'});
writetable(results, 'HRC_Simulation_Results.csv');
disp('Results saved to HRC_Simulation_Results.csv, including Action column');

%% Visualization
figure;
subplot(3,1,1);
plot(metrics.throughput, 'b', 'LineWidth', 1.5);
title('Throughput'); xlabel('Episode'); ylabel('Tasks/min'); grid on;

subplot(3,1,2);
plot(metrics.workload, 'r', 'LineWidth', 1.5);
title('Workload'); xlabel('Episode'); ylabel('Fatigue score'); grid on;

subplot(3,1,3);
plot(metrics.safety, 'g', 'LineWidth', 1.5);
title('Safety'); xlabel('Episode'); ylabel('Safety (1=safe, 0=collision)'); 
ylim([0 1.1]); grid on;

%% Helper Functions
function [fatigue, skill] = classifyState(state)
    if state.fatigue < 0.33
        fatigue = 'low';
    elseif state.fatigue < 0.66
        fatigue = 'medium';
    else
        fatigue = 'high';
    end
    
    switch state.skill
        case 1, skill = 'novice';
        case 2, skill = 'intermediate';
        case 3, skill = 'expert';
        otherwise, skill = 'novice';
    end
end

function [time, fatigue, safe] = executeAction(action, state, ~)
    switch action
        case 1 % Human
            time = state.completionTime;
            fatigue = state.fatigue * time;
            safe = true;
        case 2 % Robot
            time = normrnd(8,1);
            fatigue = 0;
            safe = rand > 0.02;
        case 3 % Collaborative
            time = (state.completionTime + normrnd(8,1))/2;
            fatigue = state.fatigue * time * 0.5;
            safe = rand > 0.015;
    end
    pause(time/10);
end