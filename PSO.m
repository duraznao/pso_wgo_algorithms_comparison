clear; clc; close all

%% CARGA Y VISUALIZACIÓN DEL MAPA
load mapa_2
imshow(mapa_bin);
hold on;
inicio = [20, 280];
final  = [280, 20];
plot(inicio(1), inicio(2), 'xr', 'LineWidth', 2, 'MarkerSize', 12);
text(inicio(1) + 5, inicio(2) + 10, 'Begin', 'Color', 'red', 'FontSize', 12);
plot(final(1), final(2), 'xr', 'LineWidth', 2, 'MarkerSize', 12);
text(final(1) - 50, final(2) - 10, 'End', 'Color', 'red', 'FontSize', 12);

%% PARÁMETROS PSO
N = 4;                % Número de puntos intermedios
D = 2 * N;            % Dimensión del vector posición
Ne = 80;              % Tamaño del enjambre
MaxIte = 1700;         % Iteraciones máximas
W = 0.7;              % Inercia
C1 = 1.5;             % Coef. cognitivo
C2 = 1.5;             % Coef. social

%% INICIALIZACIÓN
mapSize = size(mapa_bin,1);
X = randi([1 mapSize], Ne, D); % Posiciones
V = zeros(Ne, D);              % Velocidades
J = zeros(Ne, 1);              % Fitness

for i = 1:Ne
    J(i) = Ruta(X(i,:)', mapa_bin, inicio, final);
end

pBest = X;
JpBest = J;
[JgBest, idxBest] = min(J);
gBest = X(idxBest,:);

%% GRÁFICA DE RUTA
h_line = plot(NaN, NaN, 'b-', 'LineWidth', 2);
h_points = plot(NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);

%% ITERACIÓN PSO
J_graf = zeros(1, MaxIte);
for ite = 1:MaxIte
    for i = 1:Ne
        % ACTUALIZAR VELOCIDAD Y POSICIÓN
        r1 = rand(1, D);
        r2 = rand(1, D);
        V(i,:) = W * V(i,:) + C1*r1.*(pBest(i,:) - X(i,:)) + C2*r2.*(gBest - X(i,:));
        X(i,:) = X(i,:) + V(i,:);
        X(i,:) = round(X(i,:));
        
        % VERIFICACIÓN DE RANGOS
        X(i,:) = max(min(X(i,:), mapSize), 1);

        % EVALUACIÓN
        Ji = Ruta(X(i,:)', mapa_bin, inicio, final);

        % ACTUALIZAR pBest y gBest
        if Ji < JpBest(i)
            pBest(i,:) = X(i,:);
            JpBest(i) = Ji;
            if Ji < JgBest
                gBest = X(i,:);
                JgBest = Ji;
            end
        end
    end

    % ACTUALIZAR GRÁFICA
    xPts = gBest(1:N);
    yPts = gBest(N+1:end);
    [x_sort, idx] = sort(xPts);
    y_sort = yPts(idx);
    ruta_x = [inicio(1), x_sort, final(1)];
    ruta_y = [inicio(2), y_sort, final(2)];
    set(h_line, 'XData', ruta_x, 'YData', ruta_y);
    set(h_points, 'XData', x_sort, 'YData', y_sort);
    drawnow

    % GUARDAR FITNESS
    J_graf(ite) = JgBest;

    % LOG
    disp(['Iteración: ', num2str(ite), ' | JBest: ', num2str(JgBest)])
end

%% GRAFICAR CONVERGENCIA
figure
plot(1:MaxIte, J_graf, 'LineWidth', 2)
xlabel('Iteraciones'); ylabel('Fitness J'); title('Convergencia PSO')
set(gca, 'FontSize', 12)

