# Signal Processing Laboratory

This MATLAB project demonstrates advanced signal processing capabilities including:
- Biosignal Processing (EMG, ECG, EEG)
- Machine Learning Classification
- VR/AR Visualization
- Inertial Navigation
- GPU-Accelerated Computing
- Unit Testing Framework

## Project Structure

```
├── src/
│   ├── biosignals/         # Biosignal processing algorithms
│   ├── ml/                # Machine learning classifiers
│   ├── vr/                # VR/AR visualization
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
- Deep Learning Toolbox
- Computer Vision Toolbox
- VR/AR Support Package
- Parallel Computing Toolbox
- MATLAB Coder
- GPU Computing Toolbox
- Webcam Support Package (for AR)

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
- Inertial navigation plots
- Machine learning classification results
- VR/AR biosignal visualization

### Hardware-in-the-Loop Testing
For hardware testing, additional equipment is required:
- EMG sensors
- IMU device (with I2C interface)
- Reference measurement system (e.g., optical tracking)
- Environmental test equipment (temperature chamber, vibration generator)
- VR headset or AR-capable device

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

2. Machine Learning:
   - Deep learning classifiers (LSTM, CNN, Transformer)
   - Real-time signal classification
   - Feature extraction and visualization
   - GPU-accelerated training

3. VR/AR Visualization:
   - Immersive biosignal visualization
   - Real-time signal rendering
   - 3D feature space exploration
   - AR marker-based alignment

4. Inertial Navigation:
   - Kalman filtering for sensor fusion
   - Attitude estimation
   - Position tracking

5. GPU Computing:
   - Parallel signal processing
   - Fast Fourier Transform acceleration
   - Large dataset handling

6. Testing:
   - Unit tests for all components
   - Hardware-in-the-Loop (HIL) tests
   - Performance benchmarks
   - Code coverage reports

## Machine Learning Models
The project includes three types of neural networks:
1. LSTM Network:
   - Temporal signal processing
   - Sequence classification
   - Long-term pattern recognition

2. 1D Convolutional Neural Network:
   - Signal pattern recognition
   - Feature extraction
   - Real-time classification

3. Transformer Network:
   - Complex pattern analysis
   - Attention-based processing
   - Multi-channel signal analysis

## VR/AR Features
1. Virtual Reality:
   - 3D signal visualization
   - Interactive signal exploration
   - Feature space navigation
   - Real-time data updates

2. Augmented Reality:
   - Marker-based signal alignment
   - Real-world data overlay
   - Mobile visualization
   - Multi-signal display 


## Test HIL

Stworzony kompletny system testów HIL, który obejmuje:
1. Testy EMG:
- Akwizycję sygnału
- Kalibrację
- Przetwarzanie w czasie rzeczywistym
- Odporność na zakłócenia

2. Testy IMU:
- Wyrównanie statyczne
- Dokładność dynamiczną
- Stabilność temperaturową
- Odpowiedź na wibracje

Wszystkie testy są dobrze udokumentowane i gotowe do użycia. Aby rozpocząć testowanie z rzeczywistym sprzętem, należy tylko:
1. Podłączyć odpowiednie urządzenia (EMG, IMU)
2. Skonfigurować system referencyjny
3. Uruchomić testy poleceniem runtests('tests/HIL')

### notepad

Na podstawie dostępnego kodu i struktury projektu, mogę zaproponować wygenerowanie następujących konkretnych aplikacji:
1. System analizy EMG w czasie rzeczywistym:
- Akwizycja sygnału
- Przetwarzanie w czasie rzeczywistym
- Wizualizacja 3D w VR
- Klasyfikacja wzorców ruchu
- Przykładowe funkcje:
   - Akwizycja i filtracja sygnału
   - Ekstrakcja cech
   - Klasyfikacja w czasie rzeczywistym
   - Wizualizacja VR/AR

2. Interaktywny klasyfikator gestów:
- Interfejs użytkownika
- Uczenie w czasie rzeczywistym
- Wizualizacja wyników
- Eksport modelu

Komponenty:
   - GUI do zbierania danych
   - System uczący
   - Moduł wizualizacji
   - System eksportu

3. Wizualizacja AR
- Śledzenie ruchu
- Wizualizacja AR
- Kalibracja systemu
- Analiza dokładności

Funkcje:
   - Przetwarzanie danych IMU
   - Kalibracja czujników
   - Nakładanie AR
   - Analiza błędów

4. Aplikacja do treningu ML:
- Interfejs do treningu modeli
- Wizualizacja procesu uczenia
- Porównanie modeli
- Eksport wyników

Komponenty: 
   - System zarządzania danymi
   - Moduł treningu
   - Wizualizacja wyników
   - Eksport raportów

5. System testów HIL (Hardware-in-the-Loop):
- Testy EMG
- Testy IMU
- Wizualizacja wyników
- Generowanie raportów

Funkcje:
   - Procedury testowe
   - Akwizycja danych
   - Analiza wyników
   - Generowanie raportów

Każda z tych aplikacji może być wygenerowana z dostępnego kodu, ale będzie wymagała:
1. Konfiguracji odpowiednich toolboxów MATLAB
2. Dostępu do odpowiedniego sprzętu (dla części funkcji)
3. Dostosowania parametrów do konkretnych potrzeb

Którą z tych aplikacji chciałbyś, żebym rozwinął bardziej szczegółowo? Mogę:
- Pokazać dokładną strukturę kodu
- Wygenerować przykładowy interfejs użytkownika
- Przygotować skrypty demonstracyjne
- Stworzyć dokumentację użytkownika
