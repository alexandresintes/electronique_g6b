void setup() {
  Serial.begin(115200);
}

void loop() {
  int valeur = analogRead(A0); // lecture capteur
  Serial.println(valeur);
  delay(10);// Fe
}
