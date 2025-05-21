classdef GPUSignalProcessor < handle
    % GPUSignalProcessor Implements GPU-accelerated signal processing
    %   Uses Parallel Computing Toolbox for fast signal processing
    
    properties
        useGPU
        fftLength
    end
    
    methods
        function obj = GPUSignalProcessor(fftLength)
            % Constructor
            obj.fftLength = fftLength;
            % Check if GPU is available
            obj.useGPU = (gpuDeviceCount > 0);
        end
        
        function spectrum = parallelFFT(obj, signals)
            % Parallel FFT computation on GPU if available
            if obj.useGPU
                % Transfer to GPU
                gSignals = gpuArray(signals);
                % Compute FFT in parallel
                gSpectrum = fft(gSignals, obj.fftLength, 1);
                % Transfer back to CPU
                spectrum = gather(gSpectrum);
            else
                % Fallback to CPU computation
                spectrum = fft(signals, obj.fftLength, 1);
            end
        end
        
        function filtered = parallelFilter(obj, signals, filterCoeffs)
            % Parallel filtering using GPU
            if obj.useGPU
                gSignals = gpuArray(signals);
                gFilter = gpuArray(filterCoeffs);
                
                % Apply filter in parallel
                gFiltered = arrayfun(@(x) conv(gSignals(x,:), gFilter, 'same'), ...
                    1:size(gSignals,1));
                
                filtered = gather(gFiltered);
            else
                filtered = zeros(size(signals));
                for i = 1:size(signals,1)
                    filtered(i,:) = conv(signals(i,:), filterCoeffs, 'same');
                end
            end
        end
        
        function features = parallelFeatureExtraction(obj, signals)
            % Extract features in parallel using GPU
            if obj.useGPU
                gSignals = gpuArray(signals);
                
                % Compute features in parallel
                gRMS = sqrt(mean(gSignals.^2, 2));
                gMAV = mean(abs(gSignals), 2);
                gVar = var(gSignals, 0, 2);
                
                % Gather results
                features.rms = gather(gRMS);
                features.mav = gather(gMAV);
                features.variance = gather(gVar);
            else
                features.rms = sqrt(mean(signals.^2, 2));
                features.mav = mean(abs(signals), 2);
                features.variance = var(signals, 0, 2);
            end
        end
    end
    
    methods (Static)
        function benchmark = performanceBenchmark(signalLength, numSignals)
            % Benchmark GPU vs CPU performance
            processor = GPUSignalProcessor(signalLength);
            signals = randn(numSignals, signalLength);
            
            % CPU timing
            tic;
            processor.useGPU = false;
            processor.parallelFFT(signals);
            cpuTime = toc;
            
            % GPU timing (if available)
            if gpuDeviceCount > 0
                tic;
                processor.useGPU = true;
                processor.parallelFFT(signals);
                gpuTime = toc;
            else
                gpuTime = Inf;
            end
            
            benchmark.cpuTime = cpuTime;
            benchmark.gpuTime = gpuTime;
            benchmark.speedup = cpuTime/gpuTime;
        end
    end
end 