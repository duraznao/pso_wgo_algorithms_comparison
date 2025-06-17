function JBest = run_pso(MaxIter)
% PSO: Particle Swarm Optimization aplicado a rutas en mapa_bin
% Devuelve: JBest (mejor valor de la función objetivo encontrada)

load mapa  % Carga el mapa binario (debe contener la variable mapa_bin)
inicio = [20, 280]; 
final  = [280, 20];

Nk = 3;                  % Número de puntos intermedios en la ruta
D = 2 * Nk;              % Dimensión del vector de cada partícula (x1,x2,x3,y1,y2,y3)
N = 60;                  % Número de partículas (enjambre)
W = 0.7;                 % Factor de inercia (controla la velocidad anterior)
C1 = 1.5;                % Coeficiente cognitivo (memoria propia)
C2 = 1.5;                % Coeficiente social (memoria grupal)

mapSize = size(mapa_bin,1);  % Asume mapa cuadrado

% Inicialización de partículas y sus velocidades
X = randi([1 mapSize], N, D);     % Posiciones iniciales aleatorias
V = zeros(N, D);                  % Velocidades iniciales en cero
J = zeros(N, 1);                  % Fitness de cada partícula

% Evaluar posición inicial de cada partícula con la función Ruta()
for i = 1:N
    J(i) = Ruta(X(i,:)', mapa_bin, inicio, final);  % Evaluación de la trayectoria
end

% Inicialización de mejores personales y globales
pBest = X;                        % Mejores posiciones personales
JpBest = J;                       % Fitness de las mejores personales
[JBest, idxBest] = min(J);        % Mejor valor de la población inicial
gBest = X(idxBest,:);            % Mejor posición global (gBest)

% Bucle principal de PSO
for ite = 1:MaxIter
    for i = 1:N
        % Generar dos vectores aleatorios
        r1 = rand(1,D); 
        r2 = rand(1,D);

        % Actualizar velocidad: mezcla entre inercia, experiencia personal y global
        V(i,:) = W * V(i,:) + C1 * r1 .* (pBest(i,:) - X(i,:)) + C2 * r2 .* (gBest - X(i,:));

        % Actualizar posición: mover partícula en la dirección de su velocidad
        X(i,:) = round(X(i,:) + V(i,:));

        % Limitar posición dentro de los bordes del mapa
        X(i,:) = max(min(X(i,:), mapSize), 1);

        % Evaluar nueva posición
        Ji = Ruta(X(i,:)', mapa_bin, inicio, final);

        % Si es mejor que su mejor anterior, actualizar pBest
        if Ji < JpBest(i)
            pBest(i,:) = X(i,:);
            JpBest(i) = Ji;

            % Y si es mejor que el mejor global, actualizar gBest
            if Ji < JBest
                gBest = X(i,:);
                JBest = Ji;
            end
        end
    end
end
end
