classdef BiosignalVisualizer < handle
    % BiosignalVisualizer Real-time VR/AR visualization of biosignals
    %   Provides immersive visualization of EMG/EEG/ECG signals and analysis
    
    properties
        vrWorld         % Virtual reality world handle
        arScene         % Augmented reality scene
        signalObjects   % Handles to signal visualization objects
        mlFeatures     % Machine learning features for visualization
        updateRate     % Visualization update rate (Hz)
    end
    
    methods
        function obj = BiosignalVisualizer(mode)
            % Initialize VR/AR environment
            if strcmp(mode, 'VR')
                obj.initializeVR();
            elseif strcmp(mode, 'AR')
                obj.initializeAR();
            else
                error('Unsupported visualization mode');
            end
            
            obj.updateRate = 60;  % 60 Hz default update rate
            obj.signalObjects = struct();
        end
        
        function initializeVR(obj)
            % Initialize VR environment
            obj.vrWorld = vrworld('BiosignalVR.wrl', 'new');
            
            % Create visualization space
            nodes = struct();
            nodes.room = vrnode(obj.vrWorld, 'Room', 'Transform');
            nodes.signals = vrnode(obj.vrWorld, 'Signals', 'Group');
            nodes.features = vrnode(obj.vrWorld, 'Features', 'Group');
            
            % Add interaction capabilities
            vrsetpref('InteractionMode', 'Examiner');
            
            % Open the world
            open(obj.vrWorld);
            view(obj.vrWorld);
        end
        
        function initializeAR(obj)
            % Initialize AR environment using webcam
            cam = webcam();
            obj.arScene = arscene(cam);
            
            % Create AR markers for signal anchoring
            addARMarker(obj.arScene, 'EMGMarker', [0 0 0]);
            addARMarker(obj.arScene, 'EEGMarker', [0.2 0 0]);
            addARMarker(obj.arScene, 'ECGMarker', [-0.2 0 0]);
        end
        
        function visualizeEMG(obj, emgData, features)
            % Real-time EMG visualization
            if ~isempty(obj.vrWorld)
                % Update VR visualization
                emgMesh = obj.createSignalMesh(emgData);
                obj.signalObjects.emg = vrnode(obj.vrWorld, 'EMGSignal', 'Shape', ...
                    'geometry', emgMesh);
                
                % Visualize ML features
                if nargin > 2
                    obj.visualizeFeatures(features, 'EMG');
                end
            elseif ~isempty(obj.arScene)
                % Update AR visualization
                emgPlot = plot3(obj.arScene, emgData);
                alignToMarker(emgPlot, 'EMGMarker');
            end
        end
        
        function visualizeEEG(obj, eegData, features)
            % Real-time EEG visualization with frequency bands
            if ~isempty(obj.vrWorld)
                % Create frequency band visualization
                bands = obj.extractEEGBands(eegData);
                for i = 1:length(bands)
                    bandMesh = obj.createBandMesh(bands{i});
                    obj.signalObjects.eeg{i} = vrnode(obj.vrWorld, ...
                        ['EEGBand' num2str(i)], 'Shape', 'geometry', bandMesh);
                end
                
                % Visualize ML features
                if nargin > 2
                    obj.visualizeFeatures(features, 'EEG');
                end
            elseif ~isempty(obj.arScene)
                % Update AR visualization
                eegPlot = obj.createEEGSpectogram(eegData);
                alignToMarker(eegPlot, 'EEGMarker');
            end
        end
        
        function visualizeECG(obj, ecgData, features)
            % Real-time ECG visualization with beat detection
            if ~isempty(obj.vrWorld)
                % Create ECG trace
                ecgMesh = obj.createSignalMesh(ecgData);
                obj.signalObjects.ecg = vrnode(obj.vrWorld, 'ECGSignal', 'Shape', ...
                    'geometry', ecgMesh);
                
                % Add beat markers
                beats = obj.detectECGBeats(ecgData);
                obj.visualizeBeats(beats);
                
                % Visualize ML features
                if nargin > 2
                    obj.visualizeFeatures(features, 'ECG');
                end
            elseif ~isempty(obj.arScene)
                % Update AR visualization
                ecgPlot = plot3(obj.arScene, ecgData);
                alignToMarker(ecgPlot, 'ECGMarker');
                
                % Add heart rate display
                hr = obj.calculateHeartRate(ecgData);
                displayHeartRate(obj.arScene, hr);
            end
        end
        
        function visualizeFeatures(obj, features, signalType)
            % Visualize machine learning features in 3D space
            if ~isempty(obj.vrWorld)
                % Create feature space visualization
                featureMesh = obj.createFeatureMesh(features);
                obj.signalObjects.features = vrnode(obj.vrWorld, ...
                    [signalType 'Features'], 'Shape', 'geometry', featureMesh);
                
                % Add feature labels
                obj.addFeatureLabels(features);
            elseif ~isempty(obj.arScene)
                % Create AR feature visualization
                featurePlot = obj.createFeaturePlot(features);
                alignToMarker(featurePlot, [signalType 'Marker']);
            end
        end
        
        function mesh = createSignalMesh(~, data)
            % Create 3D mesh for signal visualization
            x = 1:length(data);
            y = data;
            z = zeros(size(x));
            
            mesh = struct('vertices', [x' y' z'], ...
                'faces', [1:length(data)-1; 2:length(data)]');
        end
        
        function bands = extractEEGBands(~, eegData)
            % Extract EEG frequency bands using wavelet transform
            bands = cell(5,1);
            % Delta (0.5-4 Hz)
            bands{1} = waveband(eegData, 0.5, 4);
            % Theta (4-8 Hz)
            bands{2} = waveband(eegData, 4, 8);
            % Alpha (8-13 Hz)
            bands{3} = waveband(eegData, 8, 13);
            % Beta (13-30 Hz)
            bands{4} = waveband(eegData, 13, 30);
            % Gamma (30+ Hz)
            bands{5} = waveband(eegData, 30, 100);
        end
        
        function beats = detectECGBeats(~, ecgData)
            % Detect R-peaks in ECG signal
            [~, beats] = findpeaks(ecgData, 'MinPeakHeight', ...
                mean(ecgData) + 2*std(ecgData));
        end
        
        function visualizeBeats(obj, beats)
            % Add visual markers for ECG beats
            for i = 1:length(beats)
                beatMarker = vrnode(obj.vrWorld, ['Beat' num2str(i)], ...
                    'Shape', 'geometry', 'Sphere');
                beatMarker.translation = [beats(i) 0 0];
            end
        end
        
        function hr = calculateHeartRate(~, ecgData)
            % Calculate heart rate from ECG data
            [~, beats] = findpeaks(ecgData, 'MinPeakHeight', ...
                mean(ecgData) + 2*std(ecgData));
            hr = 60 * length(beats) / (length(ecgData) / 1000);  % Assuming 1000Hz
        end
    end
    
    methods(Static)
        function spectogram = createEEGSpectogram(eegData)
            % Create EEG spectogram for visualization
            window = 256;
            noverlap = 128;
            nfft = 512;
            [s, f, t] = spectrogram(eegData, window, noverlap, nfft, 1000);
            spectogram = abs(s);
        end
    end
end 