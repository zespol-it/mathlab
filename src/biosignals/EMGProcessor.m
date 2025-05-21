classdef EMGProcessor < handle
    % EMGProcessor Class for processing EMG signals
    %   Implements common EMG processing techniques including:
    %   - Filtering
    %   - Envelope detection
    %   - Feature extraction
    
    properties
        samplingRate
        filterOrder
        cutoffFreq
    end
    
    methods
        function obj = EMGProcessor(samplingRate, filterOrder, cutoffFreq)
            % Constructor
            obj.samplingRate = samplingRate;
            obj.filterOrder = filterOrder;
            obj.cutoffFreq = cutoffFreq;
        end
        
        function filtered = filterSignal(obj, signal)
            % Apply bandpass filter to remove noise
            nyquist = obj.samplingRate/2;
            [b, a] = butter(obj.filterOrder, ...
                [20 obj.cutoffFreq]/nyquist, 'bandpass');
            filtered = filtfilt(b, a, signal);
        end
        
        function envelope = getEnvelope(obj, signal)
            % Calculate signal envelope using RMS
            windowSize = round(0.05 * obj.samplingRate); % 50ms window
            envelope = sqrt(movmean(signal.^2, windowSize));
        end
        
        function features = extractFeatures(obj, signal)
            % Extract common EMG features
            features = struct();
            features.rms = rms(signal);
            features.mav = mean(abs(signal));
            features.zc = sum(diff(sign(signal)) ~= 0);
            features.wl = sum(abs(diff(signal)));
        end
    end
    
    methods (Static)
        function signal = simulateEMG(duration, samplingRate)
            % Generate synthetic EMG for testing
            t = 0:1/samplingRate:duration-1/samplingRate;
            baseSignal = randn(size(t));
            envelope = 1 + sin(2*pi*0.5*t);
            signal = baseSignal .* envelope';
        end
    end
end 