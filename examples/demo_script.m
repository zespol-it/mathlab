% Demo script showing main functionalities of the Signal Processing Laboratory
disp('Starting Signal Processing Laboratory Demo...');

%% 1. EMG Processing Demo
disp('1. Testing EMG Processing...');

% Create EMG processor
samplingRate = 1000; % 1kHz
filterOrder = 4;
cutoffFreq = 200;
emgProc = EMGProcessor(samplingRate, filterOrder, cutoffFreq);

% Generate test signal
duration = 5.0; % 5 seconds
testSignal = EMGProcessor.simulateEMG(duration, samplingRate);

% Process signal
filtered = emgProc.filterSignal(testSignal);
envelope = emgProc.getEnvelope(filtered);
features = emgProc.extractFeatures(filtered);

% Display results
figure('Name', 'EMG Processing Results');
subplot(3,1,1);
plot(testSignal); title('Raw EMG Signal');
subplot(3,1,2);
plot(filtered); title('Filtered EMG Signal');
subplot(3,1,3);
plot(envelope); title('EMG Envelope');

disp('EMG Features:');
disp(features);

%% 2. GPU Processing Demo
disp('2. Testing GPU Processing...');

% Create GPU processor
fftLength = 1024;
gpuProc = GPUSignalProcessor(fftLength);

% Generate test data
numSignals = 1000;
signals = randn(numSignals, fftLength);

% Run benchmark
benchmark = GPUSignalProcessor.performanceBenchmark(fftLength, numSignals);
disp('Performance Benchmark Results:');
disp(['CPU Time: ' num2str(benchmark.cpuTime) ' seconds']);
disp(['GPU Time: ' num2str(benchmark.gpuTime) ' seconds']);
disp(['Speedup: ' num2str(benchmark.speedup) 'x']);

%% 3. Inertial Navigation Demo
disp('3. Testing Inertial Navigation...');

% Create navigator
nav = InertialNavigator(samplingRate);

% Generate test IMU data
[accel, gyro] = InertialNavigator.simulateIMUData(duration, samplingRate);

% Process data
positions = zeros(3, length(accel));
velocities = zeros(3, length(accel));
orientations = zeros(3, length(accel));

for i = 1:length(accel)
    [orientations(:,i), velocities(:,i), positions(:,i)] = ...
        nav.processIMUData(accel(:,i), gyro(:,i));
end

% Plot trajectory
figure('Name', 'Navigation Results');
subplot(3,1,1);
plot(positions'); title('Position');
legend('X', 'Y', 'Z');
subplot(3,1,2);
plot(velocities'); title('Velocity');
legend('V_x', 'V_y', 'V_z');
subplot(3,1,3);
plot(orientations'); title('Orientation');
legend('\phi', '\theta', '\psi');

disp('Demo completed successfully!'); 