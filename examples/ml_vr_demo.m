%% Machine Learning and VR/AR Demo
% This script demonstrates the integration of ML classification
% with immersive VR/AR visualization of biosignals

%% 1. Setup
disp('Initializing ML and VR/AR components...');

% Create ML classifier
windowSize = 1000;  % 1 second at 1kHz
numClasses = 3;     % Example: rest, flex, extend
classifier = BiosignalClassifier('lstm', windowSize, numClasses);

% Create VR visualizer
visualizer = BiosignalVisualizer('VR');  % or 'AR' for augmented reality

%% 2. Load and prepare training data
disp('Loading training data...');

% Generate synthetic EMG data for demonstration
duration = 60;  % 60 seconds
samplingRate = 1000;
numChannels = 3;

% Simulate different EMG patterns
patterns = {'rest', 'flex', 'extend'};
trainData = zeros(numChannels, duration * samplingRate);
trainLabels = cell(duration, 1);

for i = 1:duration
    pattern = patterns{mod(i-1, 3) + 1};
    timeIdx = (i-1)*samplingRate + 1 : i*samplingRate;
    
    switch pattern
        case 'rest'
            trainData(:, timeIdx) = 0.1 * randn(numChannels, samplingRate);
        case 'flex'
            trainData(:, timeIdx) = sin(2*pi*10*(1:samplingRate)/samplingRate) + ...
                0.2 * randn(numChannels, samplingRate);
        case 'extend'
            trainData(:, timeIdx) = square(2*pi*5*(1:samplingRate)/samplingRate) + ...
                0.2 * randn(numChannels, samplingRate);
    end
    trainLabels{i} = pattern;
end

%% 3. Train ML model
disp('Training classifier...');

% Prepare data in windows
numWindows = floor(size(trainData, 2) / windowSize);
X = zeros(numWindows, windowSize, numChannels);
Y = categorical(cell(numWindows, 1));

for i = 1:numWindows
    timeIdx = (i-1)*windowSize + 1 : i*windowSize;
    X(i, :, :) = trainData(:, timeIdx)';
    Y(i) = categorical(trainLabels{ceil(i/samplingRate)});
end

% Train the network
classifier.trainNetwork(X, Y);

%% 4. Real-time processing and visualization
disp('Starting real-time processing...');

% Setup real-time parameters
blockSize = 1000;  % 1 second blocks
processingTime = 10;  % 10 seconds demonstration
numBlocks = processingTime * (samplingRate/blockSize);

% Initialize visualization
figure('Name', 'Real-time Classification');
subplot(2,1,1); hold on;
title('Raw EMG Signal');
subplot(2,1,2); hold on;
title('Classification Results');

% Real-time processing loop
for i = 1:numBlocks
    % Simulate real-time data acquisition
    timeIdx = (i-1)*blockSize + 1 : i*blockSize;
    currentData = trainData(:, timeIdx);
    
    % Process data
    processedData = currentData;  % Add any preprocessing here
    
    % Classify
    features = classifier.extractFeatures(reshape(processedData', [1 blockSize 3]));
    label = classifier.classify(reshape(processedData', [1 blockSize 3]));
    
    % Visualize in VR/AR
    visualizer.visualizeEMG(processedData, features);
    
    % Update 2D plot
    subplot(2,1,1);
    plot(timeIdx, processedData');
    xlim([timeIdx(1) timeIdx(end)]);
    
    subplot(2,1,2);
    bar(categorical(label));
    
    % Add real-time markers
    drawnow;
    pause(0.1);  % Simulate real-time delay
end

%% 5. Feature Space Visualization
disp('Visualizing feature space...');

% Extract features for all data
allFeatures = classifier.extractFeatures(X);

% Create 3D feature space visualization in VR
visualizer.visualizeFeatures(allFeatures, 'EMG');

% Show classification boundaries
figure('Name', 'Feature Space');
scatter3(allFeatures(:,1), allFeatures(:,2), allFeatures(:,3), 50, Y, 'filled');
xlabel('Feature 1');
ylabel('Feature 2');
zlabel('Feature 3');
title('EMG Classification Feature Space');
legend(categories(Y));

disp('Demo completed!'); 