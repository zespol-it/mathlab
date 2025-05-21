classdef BiosignalClassifier < handle
    % BiosignalClassifier Deep learning classifier for biosignals
    %   Implements neural network based classification for EMG/EEG/ECG signals
    
    properties
        networkType  % 'lstm', 'cnn1d', 'transformer'
        net          % Deep learning network
        windowSize   % Signal window size for processing
        numClasses   % Number of output classes
        gpuDevice    % GPU device for acceleration
    end
    
    methods
        function obj = BiosignalClassifier(networkType, windowSize, numClasses)
            obj.networkType = networkType;
            obj.windowSize = windowSize;
            obj.numClasses = numClasses;
            
            % Check for GPU availability
            if gpuDeviceCount > 0
                obj.gpuDevice = gpuDevice(1);
            end
            
            % Create network based on type
            switch networkType
                case 'lstm'
                    obj.net = obj.createLSTMNetwork();
                case 'cnn1d'
                    obj.net = obj.create1DCNNNetwork();
                case 'transformer'
                    obj.net = obj.createTransformerNetwork();
                otherwise
                    error('Unsupported network type');
            end
        end
        
        function net = createLSTMNetwork(obj)
            % Create LSTM network for temporal signal processing
            layers = [
                sequenceInputLayer(1)
                lstmLayer(100, 'OutputMode', 'sequence')
                dropoutLayer(0.2)
                lstmLayer(50, 'OutputMode', 'last')
                fullyConnectedLayer(obj.numClasses)
                softmaxLayer
                classificationLayer
            ];
            
            options = trainingOptions('adam', ...
                'MaxEpochs', 100, ...
                'MiniBatchSize', 32, ...
                'InitialLearnRate', 0.01, ...
                'GradientThreshold', 1, ...
                'Plots', 'training-progress', ...
                'Verbose', false);
            
            net = struct('layers', layers, 'options', options);
        end
        
        function net = create1DCNNNetwork(obj)
            % Create 1D CNN for signal pattern recognition
            layers = [
                imageInputLayer([obj.windowSize 1 1])
                
                convolution1dLayer(32, 16, 'Padding', 'same')
                batchNormalizationLayer
                reluLayer
                maxPooling1dLayer(2, 'Stride', 2)
                
                convolution1dLayer(16, 32, 'Padding', 'same')
                batchNormalizationLayer
                reluLayer
                maxPooling1dLayer(2, 'Stride', 2)
                
                convolution1dLayer(8, 64, 'Padding', 'same')
                batchNormalizationLayer
                reluLayer
                
                globalAveragePooling1dLayer
                fullyConnectedLayer(obj.numClasses)
                softmaxLayer
                classificationLayer
            ];
            
            options = trainingOptions('adam', ...
                'MaxEpochs', 50, ...
                'MiniBatchSize', 64, ...
                'InitialLearnRate', 0.001, ...
                'Plots', 'training-progress', ...
                'Verbose', false);
            
            net = struct('layers', layers, 'options', options);
        end
        
        function net = createTransformerNetwork(obj)
            % Create Transformer network for complex pattern analysis
            layers = [
                sequenceInputLayer(1)
                
                % Positional encoding
                additionLayer(2, 'Name', 'add')
                
                % Transformer blocks
                transformerLayer(64, 8, 'Name', 'transformer1')
                layerNormalizationLayer
                
                transformerLayer(64, 8, 'Name', 'transformer2')
                layerNormalizationLayer
                
                globalAveragePooling1dLayer
                
                fullyConnectedLayer(obj.numClasses)
                softmaxLayer
                classificationLayer
            ];
            
            options = trainingOptions('adam', ...
                'MaxEpochs', 75, ...
                'MiniBatchSize', 32, ...
                'InitialLearnRate', 0.0001, ...
                'Plots', 'training-progress', ...
                'Verbose', false);
            
            net = struct('layers', layers, 'options', options);
        end
        
        function trainNetwork(obj, trainData, trainLabels)
            % Train the neural network
            if ~isempty(obj.gpuDevice)
                trainData = gpuArray(trainData);
            end
            
            % Train network based on type
            obj.net = trainNetwork(trainData, trainLabels, ...
                obj.net.layers, obj.net.options);
        end
        
        function labels = classify(obj, data)
            % Classify new data
            if ~isempty(obj.gpuDevice)
                data = gpuArray(data);
            end
            
            labels = classify(obj.net, data);
            
            if ~isempty(obj.gpuDevice)
                labels = gather(labels);
            end
        end
        
        function features = extractFeatures(obj, data)
            % Extract learned features from the network
            if ~isempty(obj.gpuDevice)
                data = gpuArray(data);
            end
            
            % Get activations from the last layer before classification
            layer = obj.net.Layers(end-2).Name;
            features = activations(obj.net, data, layer);
            
            if ~isempty(obj.gpuDevice)
                features = gather(features);
            end
        end
    end
end 