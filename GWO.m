clear; clc; close all

%% CARGA Y VISUALIZACIÓN DEL MAPA
load mapa_1
imshow(mapa_bin); hold on;
inicio = [20, 280];
final  = [280, 20];
plot(inicio(1),inicio(2),'xr','LineWidth',2); text(inicio(1)+5,inicio(2)+10,'Begin','Color','r');
plot(final(1),final(2),'xr','LineWidth',2); text(final(1)-40,final(2)-10,'End','Color','r');

%% PARÁMETROS GWO
Nk = 3;                      % Número de puntos intermedios
D = 2 * Nk;                  % Dimensión (x1,x2,x3,y1,y2,y3)
N = 200;                     % Número de lobos
MaxIter = 700;              % Iteraciones máximas
mapSize = size(mapa_bin, 1);

%% INICIALIZACIÓN
X = randi([1 mapSize], N, D);  % Población inicial aleatoria
J = zeros(N, 1);               % Fitness

for i = 1:N
    J(i) = Ruta(X(i,:)', mapa_bin, inicio, final);
end

% Identificar los 3 mejores lobos
[J_sorted, idx] = sort(J);
alpha = X(idx(1), :);
beta  = X(idx(2), :);
delta = X(idx(3), :);
JBest = J_sorted(1);

% Inicializar gráfica
xBest = alpha(1:Nk); yBest = alpha(Nk+1:end);
[x_sort, idx_sort] = sort(xBest); y_sort = yBest(idx_sort);
h_line = plot([inicio(1), x_sort, final(1)], [inicio(2), y_sort, final(2)], 'b-', 'LineWidth', 2);
h_points = plot(x_sort, y_sort, 'ro', 'MarkerFaceColor', 'r');

JBest_graf = zeros(1, MaxIter);

%% BUCLE PRINCIPAL GWO
for iter = 1:MaxIter
    a = 2 - iter * (2 / MaxIter);
    for i = 1:N
        for d = 1:D
            r1 = rand(); r2 = rand();
            A1 = 2*a*r1 - a;
            C1 = 2*r2;
            D_alpha = abs(C1 * alpha(d) - X(i,d));
            X1 = alpha(d) - A1 * D_alpha;

            r1 = rand(); r2 = rand();
            A2 = 2*a*r1 - a;
            C2 = 2*r2;
            D_beta = abs(C2 * beta(d) - X(i,d));
            X2 = beta(d) - A2 * D_beta;

            r1 = rand(); r2 = rand();
            A3 = 2*a*r1 - a;
            C3 = 2*r2;
            D_delta = abs(C3 * delta(d) - X(i,d));
            X3 = delta(d) - A3 * D_delta;

            X(i,d) = round((X1 + X2 + X3) / 3);
        end

        % Corrección de límites
        X(i, :) = max(min(X(i,:), mapSize), 1);
    end

    % Evaluar fitness y actualizar jerarquía
    for i = 1:N
        Ji = Ruta(X(i,:)', mapa_bin, inicio, final);
        J(i) = Ji;
    end
    [J_sorted, idx] = sort(J);
    alpha = X(idx(1), :);
    beta  = X(idx(2), :);
    delta = X(idx(3), :);

    % Guardar mejor solución
    if J_sorted(1) < JBest
        JBest = J_sorted(1);
        xBest = alpha(1:Nk);
        yBest = alpha(Nk+1:end);
    end

    [x_sort, idx_sort] = sort(xBest); y_sort = yBest(idx_sort);
    set(h_line, 'XData', [inicio(1), x_sort, final(1)], 'YData', [inicio(2), y_sort, final(2)]);
    set(h_points, 'XData', x_sort, 'YData', y_sort);
    drawnow

    JBest_graf(iter) = JBest;
    disp(['Iteración ', num2str(iter), ' | JBest: ', num2str(JBest)])
end

%% GRAFICAR CONVERGENCIA
figure
plot(1:MaxIter, JBest_graf, 'LineWidth', 2)
xlabel('Iteraciones'); ylabel('Fitness J'); title('Convergencia GWO')
set(gca, 'FontSize', 12)
