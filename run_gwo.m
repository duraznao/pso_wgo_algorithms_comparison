function JBest = run_gwo(MaxIter)
% GWO: Grey Wolf Optimizer aplicado a búsqueda de rutas en mapa_bin
% Devuelve: JBest (mejor valor de la función objetivo alcanzado)

load mapa  % Carga el mapa binario: mapa_bin
inicio = [20, 280]; 
final  = [280, 20];

Nk = 3;          % Número de puntos intermedios de la trayectoria
D = 2 * Nk;      % Dimensión del vector (x1, x2, x3, y1, y2, y3)
N = 100;         % Número de lobos (tamaño de la población)

mapSize = size(mapa_bin,1);  % Dimensión del mapa (asume cuadrado)

% Inicialización aleatoria de posiciones de los lobos
X = randi([1 mapSize], N, D);  % Cada fila es un lobo
J = zeros(N, 1);               % Evaluación de cada lobo (fitness)

% Evaluar la población inicial
for i = 1:N
    J(i) = Ruta(X(i,:)', mapa_bin, inicio, final);  % Ruta = función objetivo
end

% Ordenar la población por desempeño (menor J es mejor)
[J_sorted, idx] = sort(J);

% Definir los tres mejores lobos: alpha, beta y delta
alpha = X(idx(1),:);
beta  = X(idx(2),:);
delta = X(idx(3),:);

JBest = J_sorted(1);  % Mejor valor actual de la función objetivo

% Bucle principal del algoritmo GWO
for iter = 1:MaxIter
    a = 2 - iter * (2 / MaxIter);  % Parámetro que decrece linealmente (exploración → explotación)

    for i = 1:N  % Para cada lobo
        for d = 1:D  % Para cada dimensión
            % Actualización según el lobo alpha
            r1 = rand(); r2 = rand();
            A1 = 2*a*r1 - a; 
            C1g = 2*r2;
            D_alpha = abs(C1g * alpha(d) - X(i,d));
            X1 = alpha(d) - A1 * D_alpha;

            % Actualización según beta
            r1 = rand(); r2 = rand();
            A2 = 2*a*r1 - a; 
            C2g = 2*r2;
            D_beta = abs(C2g * beta(d) - X(i,d));
            X2 = beta(d) - A2 * D_beta;

            % Actualización según delta
            r1 = rand(); r2 = rand();
            A3 = 2*a*r1 - a; 
            C3g = 2*r2;
            D_delta = abs(C3g * delta(d) - X(i,d));
            X3 = delta(d) - A3 * D_delta;

            % Posición final promediando las tres influencias
            X(i,d) = round((X1 + X2 + X3)/3);
        end

        % Asegurar que los valores estén dentro del mapa
        X(i,:) = max(min(X(i,:), mapSize), 1);

        % Evaluar nueva posición del lobo
        Ji = Ruta(X(i,:)', mapa_bin, inicio, final);
        J(i) = Ji;
    end

    % Actualizar jerarquía de lobos
    [J_sorted, idx] = sort(J);
    alpha = X(idx(1),:);
    beta  = X(idx(2),:);
    delta = X(idx(3),:);

    % Guardar el mejor resultado global
    if J_sorted(1) < JBest
        JBest = J_sorted(1);
    end
end
end
