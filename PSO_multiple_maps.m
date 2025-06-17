clear; clc; close all;

%% --- Lista de mapas a probar ---

% --- Cargar configuraciones de mapas desde un archivo externo ---
map_configs; % Esto ejecuta map_configs.m y carga map_files en el workspace

% --- Iterar sobre cada mapa ---
for map_idx = 1:length(map_files)
    current_map_file = map_files{map_idx};
    fprintf('Procesando mapa: %s\n', current_map_file);

    %% CARGA Y VISUALIZACIÓN DEL MAPA
    load(current_map_file); % Carga el mapa actual

    % La variable del mapa debe ser 'mapa_bin', esto se puede generar con
    % el archivo binzarizar_mapa.m
    
    figure; % Crea una nueva figura para cada mapa
    imshow(mapa_bin);
    hold on;
    
    % --- Definir inicio y final según el mapa o mantener fijos ---

    inicio = [20, 280];
    final  = [280, 20];
    
    plot(inicio(1), inicio(2), 'xr', 'LineWidth', 2, 'MarkerSize', 12);
    text(inicio(1) + 5, inicio(2) + 10, 'Begin', 'Color', 'red', 'FontSize', 12);
    plot(final(1), final(2), 'xr', 'LineWidth', 2, 'MarkerSize', 12);
    text(final(1) - 50, final(2) - 10, 'End', 'Color', 'red', 'FontSize', 12);

    %% PARÁMETROS PSO
    N = 4;                % Número de puntos intermedios
    D = 2 * N;            % Dimensión del vector posición (X e Y para N puntos)
    Ne = 80;              % Tamaño del enjambre (número de partículas)
    MaxIte = 700;        % Iteraciones máximas
    W = 0.7;              % Inercia
    C1 = 1.5;             % Coeficiente cognitivo (influencia de la mejor posición personal)
    C2 = 1.5;             % Coeficiente social (influencia de la mejor posición global)

    %% INICIALIZACIÓN
    mapSize = size(mapa_bin, 1);    % Obtiene el tamaño del mapa (asume que es cuadrado)
    X = randi([1 mapSize], Ne, D);  % Posiciones iniciales aleatorias de las partículas
    V = zeros(Ne, D);               % Velocidades iniciales de las partículas
    J = zeros(Ne, 1);               % Fitness (costo de la ruta) de cada partícula

    % Evaluar el fitness inicial para cada partícula
    for i = 1:Ne
        J(i) = Ruta(X(i,:)', mapa_bin, inicio, final);
    end

    pBest = X;          % Mejor posición personal de cada partícula
    JpBest = J;         % Mejor fitness personal de cada partícula
    
    [JgBest, idxBest] = min(J); % Mejor fitness global y su índice
    gBest = X(idxBest,:);       % Mejor posición global

    %% GRÁFICA DE RUTA (Inicialización para la actualización dinámica)
    % Estos manejadores se usan para actualizar la línea y los puntos de la ruta
    h_line = plot(NaN, NaN, 'b-', 'LineWidth', 2);
    h_points = plot(NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);

    %% ITERACIÓN PSO
    J_graf = zeros(1, MaxIte); % Para guardar el mejor fitness en cada iteración

    for ite = 1:MaxIte
        for i = 1:Ne
            % ACTUALIZAR VELOCIDAD Y POSICIÓN
            r1 = rand(1, D); % Números aleatorios para el componente cognitivo
            r2 = rand(1, D); % Números aleatorios para el componente social
            
            % Ecuación de actualización de la velocidad
            V(i,:) = W * V(i,:) + C1*r1.*(pBest(i,:) - X(i,:)) + C2*r2.*(gBest - X(i,:));
            % Ecuación de actualización de la posición
            X(i,:) = X(i,:) + V(i,:);
            X(i,:) = round(X(i,:)); % Redondear a valores enteros de píxeles
            
            % VERIFICACIÓN DE RANGOS (asegura que las partículas estén dentro del mapa)
            X(i,:) = max(min(X(i,:), mapSize), 1);

            % EVALUACIÓN del fitness de la nueva posición
            Ji = Ruta(X(i,:)', mapa_bin, inicio, final);

            % ACTUALIZAR pBest (mejor posición personal) y gBest (mejor posición global)
            if Ji < JpBest(i)
                pBest(i,:) = X(i,:);
                JpBest(i) = Ji;
                if Ji < JgBest
                    gBest = X(i,:);
                    JgBest = Ji;
                end
            end
        end
        
        % ACTUALIZAR GRÁFICA con la mejor ruta encontrada hasta ahora
        xPts = gBest(1:N);       % Coordenadas X de los puntos intermedios
        yPts = gBest(N+1:end);   % Coordenadas Y de los puntos intermedios
        
        % Ordenar los puntos intermedios por su coordenada X para una ruta más coherente
        [x_sort, idx] = sort(xPts);
        y_sort = yPts(idx);
        
        % Construir la ruta completa: inicio -> puntos intermedios -> final
        ruta_x = [inicio(1), x_sort, final(1)];
        ruta_y = [inicio(2), y_sort, final(2)];
        
        % Actualizar los datos de la línea y los puntos en la gráfica
        set(h_line, 'XData', ruta_x, 'YData', ruta_y);
        set(h_points, 'XData', x_sort, 'YData', y_sort);
        drawnow; % Refrescar la ventana de la figura
        
        % GUARDAR FITNESS para la gráfica de convergencia
        J_graf(ite) = JgBest;
        
        % Mostrar log en la consola
        disp(['Mapa: ', current_map_file, ' | Iteración: ', num2str(ite), ' | JBest: ', num2str(JgBest)])
    end

    %% GRAFICAR CONVERGENCIA
    figure; % Nueva figura para la gráfica de convergencia de cada mapa
    plot(1:MaxIte, J_graf, 'LineWidth', 2);
    xlabel('Iteraciones');
    ylabel('Fitness J');
    title(['Convergencia PSO para ', current_map_file]);
    set(gca, 'FontSize', 12);
    
    % Pausar para ver el resultado de cada mapa antes de pasar al siguiente
    % pause(2); 
    
    fprintf('\nTerminado de procesar mapa: %s\n\n', current_map_file);
end

disp('Todos los mapas han sido procesados.');