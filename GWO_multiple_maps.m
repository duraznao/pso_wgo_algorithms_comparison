clear; clc; close all;

% --- Cargar configuraciones de mapas desde un archivo externo ---
% 'map_configs.m' debe estar presente

map_configs; 

% --- Iterar sobre cada mapa ---
for map_idx = 1:length(map_files)
    current_map_file = map_files{map_idx};
    fprintf('Procesando mapa: %s\n', current_map_file);

    %% CARGA Y VISUALIZACIÓN DEL MAPA
    load(current_map_file); % Carga el mapa actual (debe contener 'mapa_bin')

    figure; % Crea una nueva figura para cada mapa
    imshow(mapa_bin);
    hold on;
    
    % --- Definir inicio y final ---
    % Ajustar estas coordenadas si los mapas tienen diferentes puntos
    % de inicio/fin lógicos. Por ahora, los mantendremos fijos.
    inicio = [20, 280];
    final  = [280, 20];
    
    plot(inicio(1),inicio(2),'xr','LineWidth',2); 
    text(inicio(1)+5,inicio(2)+10,'Begin','Color','r');
    plot(final(1),final(2),'xr','LineWidth',2); 
    text(final(1)-40,final(2)-10,'End','Color','r');

    %% PARÁMETROS GWO
    Nk = 3;                      % Número de puntos intermedios
    D = 2 * Nk;                  % Dimensión (x1,x2,x3,y1,y2,y3)
    N = 200;                     % Número de lobos (población)
    MaxIter = 700;               % Iteraciones máximas
    mapSize = size(mapa_bin, 1); % Tamaño del mapa (asume que es cuadrado)

    %% INICIALIZACIÓN
    X = randi([1 mapSize], N, D);  % Población inicial aleatoria de lobos
    J = zeros(N, 1);               % Fitness (costo de la ruta) para cada lobo

    % Evaluar el fitness inicial para cada lobo
    for i = 1:N
        J(i) = Ruta(X(i,:)', mapa_bin, inicio, final);
    end

    % Identificar los 3 mejores lobos (alfa, beta, delta)
    [J_sorted, idx] = sort(J);
    alpha = X(idx(1), :); % Mejor lobo (alfa)
    beta  = X(idx(2), :); % Segundo mejor lobo (beta)
    delta = X(idx(3), :); % Tercer mejor lobo (delta)
    JBest = J_sorted(1);  % Mejor fitness global

    % Inicializar gráfica para la actualización dinámica de la ruta
    xBest = alpha(1:Nk); % Coordenadas X de los puntos intermedios de la mejor ruta
    yBest = alpha(Nk+1:end); % Coordenadas Y de los puntos intermedios de la mejor ruta
    
    % Ordenar los puntos intermedios por su coordenada X para una ruta más coherente
    [x_sort, idx_sort] = sort(xBest); 
    y_sort = yBest(idx_sort);
    
    % Manjadores para actualizar la línea y los puntos de la ruta
    h_line = plot([inicio(1), x_sort, final(1)], [inicio(2), y_sort, final(2)], 'b-', 'LineWidth', 2);
    h_points = plot(x_sort, y_sort, 'ro', 'MarkerFaceColor', 'r');
    
    JBest_graf = zeros(1, MaxIter); % Para guardar el mejor fitness en cada iteración

    %% BUCLE PRINCIPAL GWO
    for iter = 1:MaxIter
        % 'a' disminuye linealmente de 2 a 0, crucial para la fase de exploración/explotación
        a = 2 - iter * (2 / MaxIter); 
        
        for i = 1:N % Para cada lobo en el enjambre
            for d = 1:D % Para cada dimensión (coordenada)
                % Cálculo de la posición del lobo basada en la posición de alfa
                r1 = rand(); r2 = rand();
                A1 = 2*a*r1 - a;
                C1 = 2*r2;
                D_alpha = abs(C1 * alpha(d) - X(i,d)); % Distancia a alfa
                X1 = alpha(d) - A1 * D_alpha;
                
                % Cálculo de la posición del lobo basada en la posición de beta
                r1 = rand(); r2 = rand();
                A2 = 2*a*r1 - a;
                C2 = 2*r2;
                D_beta = abs(C2 * beta(d) - X(i,d)); % Distancia a beta
                X2 = beta(d) - A2 * D_beta;
                
                % Cálculo de la posición del lobo basada en la posición de delta
                r1 = rand(); r2 = rand();
                A3 = 2*a*r1 - a;
                C3 = 2*r2;
                D_delta = abs(C3 * delta(d) - X(i,d)); % Distancia a delta
                X3 = delta(d) - A3 * D_delta;
                
                % Actualizar la posición del lobo promediando las influencias de alfa, beta y delta
                X(i,d) = round((X1 + X2 + X3) / 3);
            end
            % Corrección de límites: asegurar que los lobos permanezcan dentro del mapa
            X(i, :) = max(min(X(i,:), mapSize), 1);
        end
        
        % Evaluar fitness y actualizar la jerarquía de los lobos
        for i = 1:N
            Ji = Ruta(X(i,:)', mapa_bin, inicio, final);
            J(i) = Ji;
        end
        
        % Reidentificar los 3 mejores lobos después de la actualización de posiciones
        [J_sorted, idx] = sort(J);
        alpha = X(idx(1), :);
        beta  = X(idx(2), :);
        delta = X(idx(3), :);
        
        % Guardar la mejor solución global encontrada hasta ahora
        if J_sorted(1) < JBest
            JBest = J_sorted(1);
            xBest = alpha(1:Nk);
            yBest = alpha(Nk+1:end);
        end
        
        % Actualizar la gráfica con la mejor ruta actual
        [x_sort, idx_sort] = sort(xBest); 
        y_sort = yBest(idx_sort);
        set(h_line, 'XData', [inicio(1), x_sort, final(1)], 'YData', [inicio(2), y_sort, final(2)]);
        set(h_points, 'XData', x_sort, 'YData', y_sort);
        drawnow; % Refrescar la ventana de la figura
        
        JBest_graf(iter) = JBest; % Guardar el mejor fitness para la gráfica de convergencia
        
        % Mostrar log en la consola
        disp(['Mapa: ', current_map_file, ' | Iteración: ', num2str(iter), ' | JBest: ', num2str(JBest)])
    end

    %% GRAFICAR CONVERGENCIA
    figure; % Nueva figura para la gráfica de convergencia de cada mapa
    plot(1:MaxIter, JBest_graf, 'LineWidth', 2);
    xlabel('Iteraciones');
    ylabel('Fitness J');
    title(['Convergencia GWO para ', current_map_file]);
    set(gca, 'FontSize', 12);
    
    %Pausar para ver el resultado de cada mapa antes de pasar al siguiente
    % pause(2);
    
    fprintf('\nTerminado de procesar mapa: %s\n\n', current_map_file);
end

disp('Todos los mapas han sido procesados.');
