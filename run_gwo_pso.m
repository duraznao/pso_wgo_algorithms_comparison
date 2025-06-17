function JBest = run_gwo_pso(MaxIter)
% Algoritmo híbrido GWO-PSO para planificación de trayectorias en mapa_bin
% Devuelve: JBest (mejor valor de la función objetivo alcanzado)

load mapa  % Carga el mapa binario
inicio = [20, 280]; 
final  = [280, 20];

Nk = 3;                  % Número de puntos intermedios
D = 2 * Nk;              % Dimensión del vector de posición (x1,x2,x3,y1,y2,y3)
N = 60;                  % Tamaño de la población (lobos/partículas)
W = 0.7;                 % Factor de inercia PSO
C1 = 1.5; C2 = 1.5;      % Coeficientes de aprendizaje cognitivo y social PSO

mapSize = size(mapa_bin,1);  % Tamaño del mapa (se asume cuadrado)

% Inicializar posiciones y velocidades
X = randi([1 mapSize], N, D);    % Posiciones aleatorias de la población
V = zeros(N, D);                 % Velocidades PSO (inicialmente cero)
J = zeros(N, 1);                 % Fitness de cada individuo

% Evaluar la población inicial con la función Ruta()
for i = 1:N
    J(i) = Ruta(X(i,:)', mapa_bin, inicio, final);
end

% Inicialización de mejores personales (pBest) y global (gBest)
pBest = X;         % Copia inicial de posiciones como mejores personales
JpBest = J;        % Copia del fitness de cada pBest
[J_sorted, idx] = sort(J);       % Ordenar población por fitness
alpha = X(idx(1),:);             % Mejor solución (alpha)
beta  = X(idx(2),:);             % Segunda mejor (beta)
delta = X(idx(3),:);             % Tercera mejor (delta)
JBest = J_sorted(1);            % Guardar el mejor valor global
gBest = alpha;                  % Inicializar gBest con alpha

% Bucle principal del algoritmo híbrido
for iter = 1:MaxIter
    a = 2 - iter * (2 / MaxIter);  % Factor de control decreciente en GWO

    for i = 1:N
        if mod(i, 2) == 0
            %% PSO: actualizar velocidad y posición (lobos pares)
            r1 = rand(1,D); r2 = rand(1,D);
            V(i,:) = W * V(i,:) + C1 * r1 .* (pBest(i,:) - X(i,:)) + C2 * r2 .* (gBest - X(i,:));
            X(i,:) = round(X(i,:) + V(i,:));
        else
            %% GWO: actualizar posición con base en alpha, beta y delta (lobos impares)
            for d = 1:D
                % Influencia de alpha
                r1 = rand(); r2 = rand(); 
                A1 = 2*a*r1 - a; C1g = 2*r2;
                D_alpha = abs(C1g * alpha(d) - X(i,d));
                X1 = alpha(d) - A1 * D_alpha;

                % Influencia de beta
                r1 = rand(); r2 = rand();
                A2 = 2*a*r1 - a; C2g = 2*r2;
                D_beta = abs(C2g * beta(d) - X(i,d));
                X2 = beta(d) - A2 * D_beta;

                % Influencia de delta
                r1 = rand(); r2 = rand();
                A3 = 2*a*r1 - a; C3g = 2*r2;
                D_delta = abs(C3g * delta(d) - X(i,d));
                X3 = delta(d) - A3 * D_delta;

                % Promedio de las tres influencias
                X(i,d) = round((X1 + X2 + X3) / 3);
            end
        end

        %% Corrección de límites para que no salgan del mapa
        X(i,:) = max(min(X(i,:), mapSize), 1);

        %% Evaluación de la nueva posición
        Ji = Ruta(X(i,:)', mapa_bin, inicio, final);

        % Actualización de mejor personal (pBest)
        if Ji < JpBest(i)
            pBest(i,:) = X(i,:);
            JpBest(i) = Ji;

            % Actualización de mejor global (gBest)
            if Ji < JBest
                gBest = X(i,:);
                JBest = Ji;
            end
        end
    end
end
end
