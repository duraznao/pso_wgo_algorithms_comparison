clear; clc; close all

%% CARGA Y VISUALIZACIÓN DEL MAPA
load mapa_1  % Carga variable mapa_bin
imshow(mapa_bin); hold on;
inicio = [20, 280];
final  = [280, 20];
plot(inicio(1),inicio(2),'xr','LineWidth',2); text(inicio(1)+5,inicio(2)+10,'Begin','Color','r');
plot(final(1),final(2),'xr','LineWidth',2); text(final(1)-40,final(2)-10,'End','Color','r');

%% PARÁMETROS GENERALES
Nk = 4;                   % Número de puntos intermedios
D = 2 * Nk;               % Dimensión del vector (x1,x2,x3,y1,y2,y3)
N = 80;                   % Tamaño del enjambre/manada
MaxIter = 700;            % Iteraciones
W = 0.7; C1 = 1.5; C2 = 1.5;
mapSize = size(mapa_bin,1);

%% INICIALIZACIÓN
X = randi([1 mapSize], N, D);   % Posiciones
V = zeros(N, D);                % Velocidades PSO
J = zeros(N, 1);                % Fitness
for i = 1:N
    J(i) = Ruta(X(i,:)', mapa_bin, inicio, final);
end

% Inicialización de mejores
pBest = X;
JpBest = J;
[J_sorted, idx] = sort(J);
alpha = X(idx(1),:); beta = X(idx(2),:); delta = X(idx(3),:);
JBest = J_sorted(1);
gBest = alpha;

% Visualización inicial
xBest = alpha(1:Nk); yBest = alpha(Nk+1:end);
[x_sort, idx_sort] = sort(xBest); y_sort = yBest(idx_sort);
h_line = plot([inicio(1), x_sort, final(1)], [inicio(2), y_sort, final(2)], 'b-', 'LineWidth', 2);
h_points = plot(x_sort, y_sort, 'ro', 'MarkerFaceColor', 'r');

JBest_graf = zeros(1, MaxIter);

%% BUCLE PRINCIPAL: GWO + PSO
for iter = 1:MaxIter
    a = 2 - iter * (2 / MaxIter);  % Control de convergencia GWO

    for i = 1:N
        if mod(i, 2) == 0  % PSO para lobos pares
            r1 = rand(1,D); r2 = rand(1,D);
            V(i,:) = W*V(i,:) + C1*r1.*(pBest(i,:)-X(i,:)) + C2*r2.*(gBest - X(i,:));
            X(i,:) = round(X(i,:) + V(i,:));
        else  % GWO para lobos impares
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

                % Promedio de los tres
                X(i,d) = round((X1 + X2 + X3) / 3);
            end
        end

        % Corrección de límites
        X(i,:) = max(min(X(i,:), mapSize), 1);

        % Evaluación y actualización de mejores
        Ji = Ruta(X(i,:)', mapa_bin, inicio, final);
        if Ji < JpBest(i)
            pBest(i,:) = X(i,:);
            JpBest(i) = Ji;
        end
        if Ji < JBest
            JBest = Ji;
            gBest = X(i,:);
            xBest = gBest(1:Nk);
            yBest = gBest(Nk+1:end);
        end
    end

    % Actualización visual
    [x_sort, idx_sort] = sort(xBest); y_sort = yBest(idx_sort);
    set(h_line, 'XData', [inicio(1), x_sort, final(1)], 'YData', [inicio(2), y_sort, final(2)]);
    set(h_points, 'XData', x_sort, 'YData', y_sort);
    drawnow

    JBest_graf(iter) = JBest;
    disp(['Iteración ', num2str(iter), ' | JBest: ', num2str(JBest)]);
end

%% GRÁFICA DE CONVERGENCIA
figure
plot(1:MaxIter, JBest_graf, 'LineWidth', 2)
xlabel('Iteraciones'); ylabel('Fitness J'); title('Convergencia GWO-PSO')
set(gca, 'FontSize', 12)
