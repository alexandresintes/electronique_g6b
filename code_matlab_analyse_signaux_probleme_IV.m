% Paramètres d'analyse
Fe = 16000;
N = Fe * 1;
seuil = 0.35;
seuil_puissance = 0.001;

% Liste des fichiers audio à analyser
fichiers = {
    "downfall-3-208028.mp3"
    "fossil-wrist-watch-ticking-studio-quality-timepiece-sound-fx-326607.mp3"
    "large-underwater-explosion-190270.mp3"
    "stab-f-01-brvhrtz-224599.mp3"
    "wind-blowing-sfx-12809.mp3"
};

% Boucle sur chaque signal
for k = 1:length(fichiers)

    fprintf("\nAnalyse du signal : %s\n", fichiers{k});

    % Chargement du signal audio
    [x,Fe] = audioread(fichiers{k});

    if size(x,2) > 1
        x = x(:,1);
    end

    % Sélection d'une seconde et centrage
    x = x(1:min(N,length(x)));
    x = x - mean(x);

    % Calcul de la puissance
    Puissance = mean(x.^2);

    % Analyse fréquentielle (FFT et DSP)
    X = fft(x);
    DSP = (abs(X).^2) / N;
    f = (0:N-1) * (Fe/N);

    % Calcul de l'énergie au-dessus de 2 kHz
    index_2k = find(f >= 2000);
    E_totale = sum(DSP);
    E_2k = sum(DSP(index_2k));
    ratio = E_2k / E_totale;

    % Classification pénible / tolérable
    if Puissance < seuil_puissance
        Etat = "Tolérable";
    elseif ratio > seuil
        Etat = "Pénible";
    else
        Etat = "Tolérable";
    end

    % Affichage des résultats
    fprintf("Puissance = %.4f\n", Puissance);
    fprintf("Energie > 2 kHz = %.2f %%\n", ratio*100);
    fprintf("Classification = %s\n", Etat);

    % Affichage du spectre fréquentiel
    figure;
    plot(f(1:N/2),10*log10(DSP(1:N/2)));
    xlabel("Fréquence (Hz)");
    ylabel("DSP (dB)");
    title("Spectre du signal : " + fichiers{k});
    grid on;

end
