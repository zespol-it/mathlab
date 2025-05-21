classdef IMUHardwareTest < matlab.unittest.TestCase
    % IMUHardwareTest Hardware-in-the-Loop tests for IMU sensors
    %   Tests real hardware IMU acquisition and navigation algorithms
    
    properties
        navigator
        samplingRate = 100  % 100Hz
        imuHandle
        referenceSystem  % External reference measurement system
    end
    
    methods(TestMethodSetup)
        function setupHardware(testCase)
            % Initialize navigation system
            testCase.navigator = InertialNavigator(testCase.samplingRate);
            
            % Setup hardware connections
            try
                % Initialize IMU
                testCase.imuHandle = IMUDevice('I2C', 1, testCase.samplingRate);
                testCase.addTeardown(@() disconnect(testCase.imuHandle));
                
                % Initialize reference system (e.g., optical tracking)
                testCase.referenceSystem = ReferenceSystem('192.168.1.100');
                testCase.addTeardown(@() disconnect(testCase.referenceSystem));
            catch ex
                assumeFail(testCase, ['Hardware setup failed: ' ex.message]);
            end
        end
    end
    
    methods(Test)
        function testStaticAlignment(testCase)
            % Test IMU alignment in static condition
            assumeTrue(testCase, isConnected(testCase.imuHandle), ...
                'IMU not connected');
            
            % Collect static data
            duration = 5.0;  % 5 seconds
            [accel, gyro] = acquire(testCase.imuHandle, duration);
            
            % Calculate mean acceleration
            meanAccel = mean(accel, 2);
            
            % Verify gravity measurement
            gravity = norm(meanAccel);
            testCase.verifyEqual(gravity, 9.81, 'RelTol', 0.05, ...
                'Incorrect gravity measurement');
            
            % Verify gyro bias
            meanGyro = mean(gyro, 2);
            testCase.verifyLessThan(norm(meanGyro), 0.1, ...
                'Excessive gyro bias');
        end
        
        function testDynamicAccuracy(testCase)
            % Test dynamic accuracy against reference system
            duration = 10.0;  % 10 seconds
            
            % Start reference system measurement
            refData = startMeasurement(testCase.referenceSystem);
            
            % Collect IMU data
            [accel, gyro] = acquire(testCase.imuHandle, duration);
            
            % Stop reference measurement
            stopMeasurement(testCase.referenceSystem);
            
            % Process IMU data
            positions = zeros(3, size(accel,2));
            velocities = zeros(3, size(accel,2));
            orientations = zeros(3, size(accel,2));
            
            for i = 1:size(accel,2)
                [orientations(:,i), velocities(:,i), positions(:,i)] = ...
                    testCase.navigator.processIMUData(accel(:,i), gyro(:,i));
            end
            
            % Compare with reference data
            refPositions = getReferencePositions(testCase.referenceSystem);
            refOrientations = getReferenceOrientations(testCase.referenceSystem);
            
            % Verify position accuracy
            posError = rms(positions - refPositions, 2);
            testCase.verifyLessThan(max(posError), 0.1, ...
                'Position error exceeds 10cm');
            
            % Verify orientation accuracy
            oriError = rms(orientations - refOrientations, 2);
            testCase.verifyLessThan(max(oriError), deg2rad(5), ...
                'Orientation error exceeds 5 degrees');
        end
        
        function testTemperatureStability(testCase)
            % Test sensor stability across temperature changes
            assumeTrue(testCase, hasTemperatureSensor(testCase.imuHandle), ...
                'Temperature sensor not available');
            
            % Collect data at different temperatures
            temps = [20 30 40];  % Target temperatures in Celsius
            gyroReadings = zeros(3, length(temps));
            
            for i = 1:length(temps)
                % Wait for temperature stabilization
                waitForTemperature(testCase.imuHandle, temps(i));
                
                % Collect static data
                [~, gyro] = acquire(testCase.imuHandle, 1.0);
                gyroReadings(:,i) = mean(gyro, 2);
            end
            
            % Verify temperature stability
            maxDrift = max(abs(diff(gyroReadings, 1, 2)), [], 'all');
            testCase.verifyLessThan(maxDrift, 0.05, ...
                'Excessive gyro drift with temperature');
        end
        
        function testVibrationResponse(testCase)
            % Test system response to mechanical vibrations
            
            % Start vibration generator
            startVibration(10);  % 10Hz vibration
            pause(1.0);  % Wait for vibration to stabilize
            
            % Collect data
            [accel, gyro] = acquire(testCase.imuHandle, 5.0);
            
            % Stop vibration
            stopVibration();
            
            % Process data
            filtered = testCase.navigator.filterVibration(accel, gyro);
            
            % Verify vibration suppression
            originalPower = rms(accel, 2);
            filteredPower = rms(filtered, 2);
            
            testCase.verifyLessThan(filteredPower./originalPower, 0.5, ...
                'Insufficient vibration suppression');
        end
    end
    
    methods(Static)
        function startVibration(frequency)
            % Implementation depends on your vibration test setup
            warning('Vibration generation not implemented');
        end
        
        function stopVibration()
            % Stop vibration generator
            warning('Vibration stop not implemented');
        end
    end
end 