classdef InertialNavigator < handle
    % InertialNavigator Implements inertial navigation algorithms
    %   Provides sensor fusion and position tracking capabilities
    
    properties
        samplingRate
        gravity = 9.81
        % Kalman filter parameters
        Q  % Process noise covariance
        R  % Measurement noise covariance
        P  % Error covariance matrix
        state  % Current state vector [position; velocity; orientation]
    end
    
    methods
        function obj = InertialNavigator(samplingRate)
            obj.samplingRate = samplingRate;
            % Initialize Kalman filter parameters
            obj.Q = eye(9) * 0.01;  % State: [pos; vel; orientation]
            obj.R = eye(6) * 0.1;   % Measurements: [acc; gyro]
            obj.P = eye(9);
            obj.state = zeros(9,1);
        end
        
        function [orientation, velocity, position] = processIMUData(obj, accel, gyro)
            % Process IMU data using Extended Kalman Filter
            dt = 1/obj.samplingRate;
            
            % Predict step
            [obj.state, obj.P] = obj.predict(obj.state, obj.P, accel, gyro, dt);
            
            % Update step with measurements
            z = [accel; gyro];
            [obj.state, obj.P] = obj.update(obj.state, obj.P, z);
            
            % Extract results
            position = obj.state(1:3);
            velocity = obj.state(4:6);
            orientation = obj.state(7:9);
        end
        
        function [state_pred, P_pred] = predict(obj, state, P, accel, gyro, dt)
            % EKF prediction step
            % Simple motion model
            F = eye(9);
            F(1:3, 4:6) = eye(3) * dt;  % Position update from velocity
            
            % State prediction
            state_pred = F * state;
            
            % Add acceleration influence
            state_pred(4:6) = state_pred(4:6) + accel * dt;
            
            % Covariance prediction
            P_pred = F * P * F' + obj.Q;
        end
        
        function [state_upd, P_upd] = update(obj, state, P, z)
            % EKF update step
            H = [zeros(3,3), eye(3), zeros(3,3);  % Accelerometer measurement
                 zeros(3,6), eye(3)];             % Gyroscope measurement
            
            % Innovation
            y = z - H * state;
            
            % Kalman gain
            S = H * P * H' + obj.R;
            K = P * H' / S;
            
            % State and covariance update
            state_upd = state + K * y;
            P_upd = (eye(9) - K * H) * P;
        end
        
        function quaternion = eulerToQuaternion(~, euler)
            % Convert Euler angles to quaternion
            phi = euler(1)/2;
            theta = euler(2)/2;
            psi = euler(3)/2;
            
            quaternion = [
                cos(phi)*cos(theta)*cos(psi) + sin(phi)*sin(theta)*sin(psi);
                sin(phi)*cos(theta)*cos(psi) - cos(phi)*sin(theta)*sin(psi);
                cos(phi)*sin(theta)*cos(psi) + sin(phi)*cos(theta)*sin(psi);
                cos(phi)*cos(theta)*sin(psi) - sin(phi)*sin(theta)*cos(psi)
            ];
        end
    end
    
    methods (Static)
        function [accel, gyro] = simulateIMUData(duration, samplingRate)
            % Generate synthetic IMU data for testing
            t = 0:1/samplingRate:duration-1/samplingRate;
            n = length(t);
            
            % Simulate circular motion with noise
            omega = 2*pi*0.5;  % 0.5 Hz rotation
            radius = 1;
            
            % Ideal accelerometer readings
            ax = -radius * omega^2 * cos(omega*t);
            ay = -radius * omega^2 * sin(omega*t);
            az = ones(1,n) * 9.81;  % gravity
            
            % Add noise
            noise_std = 0.1;
            accel = [ax; ay; az] + noise_std * randn(3,n);
            
            % Ideal gyroscope readings
            gx = zeros(1,n);
            gy = zeros(1,n);
            gz = omega * ones(1,n);
            
            % Add noise
            gyro = [gx; gy; gz] + noise_std * randn(3,n);
        end
    end
end 