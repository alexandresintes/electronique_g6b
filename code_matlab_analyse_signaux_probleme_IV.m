% Paramètres d'analyse
Fe = 16000;
N = Fe * 1;
seuil = 0.35;
seuil_puissance = 0.001;

port = "COM3";
baudrate = 115200;

s = serialport(port, baudrate);
configureTerminator(s,"LF");
flush(s);

fprintf("Acquisition du signal depuis le port série...\n");

x = zeros(N,1);

for i = 1:N
    x(i) = str2double(readline(s));
end

clear s;

% Suppression offset DC
x = x - mean(x);

% Calcul de la puissance
Puissance = mean(x.^2);

% Analyse fréquentielle
X = fft(x);
DSP = (abs(X).^2) / N;
f = (0:N-1) * (Fe/N);

% Énergie au-dessus de 2 kHz
index_2k = find(f >= 2000);
E_totale = sum(DSP);
E_2k = sum(DSP(index_2k));
ratio = E_2k / E_totale;

% Classification
if Puissance < seuil_puissance
    Etat = "Tolérable";
elseif ratio > seuil
    Etat = "Pénible";
else
    Etat = "Tolérable";
end

% Résultats
fprintf("Puissance = %.4f\n", Puissance);
fprintf("Energie > 2 kHz = %.2f %%\n", ratio*100);
fprintf("Classification = %s\n", Etat);

% Spectre
figure;
plot(f(1:N/2),10*log10(DSP(1:N/2)));
xlabel("Fréquence (Hz)");
ylabel("DSP (dB)");
title("Spectre du signal acquis via port série");
grid on;
