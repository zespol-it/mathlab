classdef EMGProcessorTest < matlab.unittest.TestCase
    % EMGProcessorTest Unit tests for EMGProcessor class
    
    properties
        processor
        testSignal
        samplingRate = 1000
    end
    
    methods(TestMethodSetup)
        function setupTest(testCase)
            % Setup for each test
            testCase.processor = EMGProcessor(testCase.samplingRate, 4, 200);
            duration = 1.0;  % 1 second of data
            testCase.testSignal = EMGProcessor.simulateEMG(duration, testCase.samplingRate);
        end
    end
    
    methods(Test)
        function testFilterSignal(testCase)
            % Test signal filtering
            filtered = testCase.processor.filterSignal(testCase.testSignal);
            
            % Verify signal properties
            testCase.verifyEqual(length(filtered), length(testCase.testSignal), ...
                'Filtered signal length should match input');
            testCase.verifyLessThan(std(filtered), std(testCase.testSignal), ...
                'Filtered signal should have lower variance');
        end
        
        function testEnvelopeDetection(testCase)
            % Test envelope detection
            envelope = testCase.processor.getEnvelope(testCase.testSignal);
            
            % Verify envelope properties
            testCase.verifyEqual(length(envelope), length(testCase.testSignal), ...
                'Envelope length should match input');
            testCase.verifyGreaterThan(min(envelope), 0, ...
                'Envelope should be positive');
        end
        
        function testFeatureExtraction(testCase)
            % Test feature extraction
            features = testCase.processor.extractFeatures(testCase.testSignal);
            
            % Verify feature properties
            testCase.verifyClass(features, 'struct', ...
                'Features should be returned as struct');
            testCase.verifyField(features, 'rms', ...
                'RMS feature should be present');
            testCase.verifyField(features, 'mav', ...
                'MAV feature should be present');
            testCase.verifyField(features, 'zc', ...
                'Zero crossings feature should be present');
            testCase.verifyField(features, 'wl', ...
                'Waveform length feature should be present');
        end
        
        function testPerformance(testCase)
            % Performance test
            duration = 10.0;  % 10 seconds of data
            longSignal = EMGProcessor.simulateEMG(duration, testCase.samplingRate);
            
            % Measure processing time
            tic;
            filtered = testCase.processor.filterSignal(longSignal);
            envelope = testCase.processor.getEnvelope(filtered);
            features = testCase.processor.extractFeatures(envelope);
            processingTime = toc;
            
            % Verify processing time is reasonable
            testCase.verifyLessThan(processingTime, 1.0, ...
                'Processing should complete within 1 second');
        end
    end
end 