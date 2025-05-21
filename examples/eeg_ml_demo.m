%% EEG Processing with Machine Learning and VR/AR Demo
% This script demonstrates EEG signal processing with ML classification
% and immersive visualization

%% 1. Setup
disp('Initializing EEG processing components...');

% Create ML classifier for EEG
windowSize = 512;   % 2 seconds at 256Hz
numClasses = 4;     % Example: alpha, beta, theta, delta states
classifier = BiosignalClassifier('transformer', windowSize, numClasses);

% Create VR visualizer
visualizer = BiosignalVisualizer('VR');  % or 'AR' for augmented reality

%% 2. Generate synthetic EEG data
disp('Generating synthetic EEG data...');

% Parameters
samplingRate = 256;  % Hz
duration = 120;      % seconds
numChannels = 8;     % 8 EEG channels

% Generate different brain states
states = {'alpha', 'beta', 'theta', 'delta'};
trainData = zeros(numChannels, duration * samplingRate);
trainLabels = cell(duration, 1);

for i = 1:duration
    state = states{mod(i-1, 4) + 1};
    timeIdx = (i-1)*samplingRate + 1 : i*samplingRate;
    t = (0:samplingRate-1)/samplingRate;
    
    switch state
        case 'alpha'
            % Alpha waves (8-13 Hz)
            freq = 10;
            trainData(:, timeIdx) = sin(2*pi*freq*t) + 0.2*randn(numChannels, samplingRate);
            
        case 'beta'
            % Beta waves (13-30 Hz)
            freq = 20;
            trainData(:, timeIdx) = sin(2*pi*freq*t) + 0.2*randn(numChannels, samplingRate);
            
        case 'theta'
            % Theta waves (4-8 Hz)
            freq = 6;
            trainData(:, timeIdx) = sin(2*pi*freq*t) + 0.2*randn(numChannels, samplingRate);
            
        case 'delta'
            % Delta waves (0.5-4 Hz)
            freq = 2;
            trainData(:, timeIdx) = sin(2*pi*freq*t) + 0.2*randn(numChannels, samplingRate);
    end
    trainLabels{i} = state;
end

%% 3. Prepare and train ML model
disp('Training EEG classifier...');

% Prepare data in windows
numWindows = floor(size(trainData, 2) / windowSize);
X = zeros(numWindows, windowSize, numChannels);
Y = categorical(cell(numWindows, 1));

for i = 1:numWindows
    timeIdx = (i-1)*windowSize + 1 : i*windowSize;
    X(i, :, :) = trainData(:, timeIdx)';
    Y(i) = categorical(trainLabels{ceil(i*windowSize/samplingRate)});
end

% Train the network
classifier.trainNetwork(X, Y);

%% 4. Real-time processing and visualization
disp('Starting real-time EEG processing...');

% Setup real-time parameters
blockSize = windowSize;
processingTime = 30;  % 30 seconds demonstration
numBlocks = processingTime * (samplingRate/blockSize);

% Initialize visualization
figure('Name', 'Real-time EEG Analysis');
subplot(3,1,1); hold on;
title('Raw EEG Signal');
subplot(3,1,2); hold on;
title('Frequency Bands');
subplot(3,1,3); hold on;
title('Brain State Classification');

% Real-time processing loop
for i = 1:numBlocks
    % Simulate real-time data acquisition
    timeIdx = (i-1)*blockSize + 1 : i*blockSize;
    currentData = trainData(:, timeIdx);
    
    % Extract frequency bands
    bands = visualizer.extractEEGBands(currentData(1,:));  % Analysis on first channel
    
    % Classify brain state
    features = classifier.extractFeatures(reshape(currentData', [1 blockSize numChannels]));
    label = classifier.classify(reshape(currentData', [1 blockSize numChannels]));
    
    % Visualize in VR/AR
    visualizer.visualizeEEG(currentData, features);
    
    % Update 2D plots
    subplot(3,1,1);
    plot(timeIdx, currentData(1,:));  % Plot first channel
    xlim([timeIdx(1) timeIdx(end)]);
    ylabel('Amplitude');
    
    subplot(3,1,2);
    bandNames = {'Delta', 'Theta', 'Alpha', 'Beta', 'Gamma'};
    bandPowers = cellfun(@(x) rms(x), bands);
    bar(categorical(bandNames), bandPowers);
    ylabel('Power');
    
    subplot(3,1,3);
    bar(categorical(label));
    ylabel('Probability');
    
    % Add real-time markers
    drawnow;
    pause(0.1);  % Simulate real-time delay
end

%% 5. Brain State Visualization
disp('Creating brain state visualization...');

% Extract features for all data
allFeatures = classifier.extractFeatures(X);

% Create 3D brain state visualization in VR
visualizer.visualizeFeatures(allFeatures, 'EEG');

% Show state transitions
figure('Name', 'Brain State Transitions');
scatter3(allFeatures(:,1), allFeatures(:,2), allFeatures(:,3), 50, Y, 'filled');
xlabel('Feature 1');
ylabel('Feature 2');
zlabel('Feature 3');
title('EEG State Classification');
legend(categories(Y));

% Plot state transition probabilities
figure('Name', 'State Transition Matrix');
transitions = zeros(numClasses);
for i = 2:length(Y)
    prev = find(Y(i-1) == categories(Y));
    curr = find(Y(i) == categories(Y));
    transitions(prev, curr) = transitions(prev, curr) + 1;
end
transitions = transitions ./ sum(transitions, 2);

imagesc(transitions);
colorbar;
title('State Transition Probabilities');
xlabel('To State');
ylabel('From State');
xticklabels(categories(Y));
yticklabels(categories(Y));

disp('Demo completed!'); 