#include <ArduinoFFT.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define MIC_PIN A0
#define SAMPLES 256
#define SAMPLING_FREQUENCY 8000

#define OLED_WIDTH 128
#define OLED_HEIGHT 64

Adafruit_SSD1306 display(OLED_WIDTH, OLED_HEIGHT, &Wire, -1);
ArduinoFFT FFT = ArduinoFFT();

double vReal[SAMPLES];
double vImag[SAMPLES];

// Seuils (adaptés du MATLAB)
double seuil_ratio = 0.35;
double seuil_puissance = 0.001;

void setup() {
  Serial.begin(115200);

  // Initialisation OLED
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    while (1);
  }

  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(WHITE);
  display.setCursor(0, 20);
  display.println("Audio OK");
  display.display();

  delay(2000);
}

void loop() {

  // Acquisition
  for (int i = 0; i < SAMPLES; i++) {
    vReal[i] = analogRead(MIC_PIN);
    vImag[i] = 0;
    delayMicroseconds(1000000 / SAMPLING_FREQUENCY);
  }

  // Centrage
  double mean = 0;
  for (int i = 0; i < SAMPLES; i++) mean += vReal[i];
  mean /= SAMPLES;
  for (int i = 0; i < SAMPLES; i++) vReal[i] -= mean;

  // Puissance
  double puissance = 0;
  for (int i = 0; i < SAMPLES; i++) {
    puissance += vReal[i] * vReal[i];
  }
  puissance /= SAMPLES;

  // FFT
  FFT.Windowing(vReal, SAMPLES, FFT_WIN_TYP_HAMMING, FFT_FORWARD);
  FFT.Compute(vReal, vImag, SAMPLES, FFT_FORWARD);
  FFT.ComplexToMagnitude(vReal, vImag, SAMPLES);

  // Énergie fréquentielle
  double E_tot = 0;
  double E_2k = 0;

  for (int i = 1; i < SAMPLES / 2; i++) {
    double freq = (i * SAMPLING_FREQUENCY) / SAMPLES;
    E_tot += vReal[i];
    if (freq >= 2000) {
      E_2k += vReal[i];
    }
  }

  double ratio = E_2k / E_tot;

  // Classification
  String etat;
  if (puissance < seuil_puissance) {
    etat = "Tolérable";
  } else if (ratio > seuil_ratio) {
    etat = "Pénible";
  } else {
    etat = "Tolérable";
  }

  // Affichage OLED
  display.clearDisplay();
  display.setTextSize(2);
  display.setCursor(0, 0);
  display.println("Ambiance");

  display.setTextSize(1);
  display.setCursor(0, 30);
  display.print("Puissance:");
  display.println(puissance, 4);

  display.setCursor(0, 40);
  display.print(">2kHz:");
  display.print(ratio * 100, 1);
  display.println("%");

  display.setCursor(0, 55);
  display.setTextSize(2);
  display.println(etat);

  display.display();

  delay(500);
}
