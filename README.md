# Signal Processing Laboratory

This MATLAB project demonstrates advanced signal processing capabilities including:
- Biosignal Processing (EMG, ECG, EEG)
- Inertial Navigation
- GPU-Accelerated Computing
- Unit Testing Framework

## Project Structure

```
├── src/
│   ├── biosignals/         # Biosignal processing algorithms
│   ├── navigation/         # Inertial navigation implementations
│   ├── gpu/               # GPU-accelerated computations
│   └── utils/             # Utility functions
├── tests/
│   ├── unit/             # Unit tests
│   └── HIL/              # Hardware-in-the-Loop tests
├── data/                  # Sample datasets
└── examples/              # Usage examples
```

## Requirements
- MATLAB R2023b or newer
- Signal Processing Toolbox
- Parallel Computing Toolbox
- MATLAB Coder
- GPU Computing Toolbox

## Getting Started
1. Clone this repository
2. Add the project root and all subfolders to MATLAB path
3. Run the example scripts in the `examples` folder
4. Execute tests using `runtests('tests')`

## Testing the Project
1. Start MATLAB
2. Add project paths to MATLAB path:
   ```matlab
   addpath(genpath('/path/to/mathlab'));
   ```
3. Run unit tests:
   ```matlab
   runtests('tests/unit');
   ```
4. Run demonstration script:
   ```matlab
   run('examples/demo_script.m');
   ```

The demo script will show:
- EMG signal processing visualization
- GPU vs CPU performance benchmarks
- Inertial navigation plots (position, velocity, orientation)

### Hardware-in-the-Loop Testing
For hardware testing, additional equipment is required:
- EMG sensors
- IMU device (with I2C interface)
- Reference measurement system (e.g., optical tracking)
- Environmental test equipment (temperature chamber, vibration generator)

To run HIL tests:
```matlab
runtests('tests/HIL');
```

HIL tests include:
1. EMG Hardware Tests:
   - Signal acquisition verification
   - Calibration accuracy
   - Real-time processing performance
   - Noise immunity testing

2. IMU Hardware Tests:
   - Static alignment accuracy
   - Dynamic position tracking
   - Temperature stability
   - Vibration response

## Features
1. Biosignal Processing:
   - EMG signal filtering and analysis
   - ECG peak detection and heart rate variability
   - EEG frequency band analysis

2. Inertial Navigation:
   - Kalman filtering for sensor fusion
   - Attitude estimation
   - Position tracking

3. GPU Computing:
   - Parallel signal processing
   - Fast Fourier Transform acceleration
   - Large dataset handling

4. Testing:
   - Unit tests for all components
   - Hardware-in-the-Loop (HIL) tests
   - Performance benchmarks
   - Code coverage reports 