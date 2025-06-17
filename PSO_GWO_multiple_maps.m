clear; clc; close all;

% --- Cargar configuraciones de mapas desde un archivo externo ---

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
    % Coordenadas de inicio y fin que se pueden ajustarse 

    inicio = [20, 280];
    final  = [280, 20];
    
    plot(inicio(1),inicio(2),'xr','LineWidth',2); 
    text(inicio(1)+5,inicio(2)+10,'Begin','Color','r');
    plot(final(1),final(2),'xr','LineWidth',2); 
    text(final(1)-40,final(2)-10,'End','Color','r');

    %% PARÁMETROS GENERALES (Híbrido GWO-PSO)
    Nk = 4;                   % Número de puntos intermedios para la ruta
    D = 2 * Nk;               % Dimensión del vector de posición (X e Y para Nk puntos)
    N = 80;                   % Tamaño del enjambre/manada (número de agentes)
    MaxIter = 700;            % Iteraciones máximas
    
    % Parámetros PSO
    W = 0.7;                  % Inercia
    C1 = 1.5;                 % Coeficiente cognitivo
    C2 = 1.5;                 % Coeficiente social
    
    mapSize = size(mapa_bin,1); % Tamaño del mapa (asume que es cuadrado)

    %% INICIALIZACIÓN
    X = randi([1 mapSize], N, D);   % Posiciones iniciales aleatorias de los agentes
    V = zeros(N, D);                % Velocidades iniciales para los agentes tipo PSO
    J = zeros(N, 1);                % Fitness (costo de la ruta) de cada agente

    % Evaluar el fitness inicial para cada agente
    for i = 1:N
        J(i) = Ruta(X(i,:)', mapa_bin, inicio, final);
    end

    % Inicialización de mejores posiciones para PSO
    pBest = X;      % Mejor posición personal de cada agente
    JpBest = J;     % Mejor fitness personal de cada agente

    % Inicialización de mejores posiciones para GWO (y global)
    [J_sorted, idx] = sort(J);
    alpha = X(idx(1),:); % Mejor lobo/agente (alfa)
    beta = X(idx(2),:);  % Segundo mejor (beta)
    delta = X(idx(3),:); % Tercer mejor (delta)
    JBest = J_sorted(1); % Mejor fitness global
    gBest = alpha;       % Mejor posición global (inicialmente el alfa)

    % Visualización inicial de la mejor ruta
    xBest = gBest(1:Nk);       % Coordenadas X de los puntos intermedios de la mejor ruta
    yBest = gBest(Nk+1:end);   % Coordenadas Y de los puntos intermedios de la mejor ruta
    
    % Ordenar los puntos intermedios por su coordenada X para una ruta más coherente
    [x_sort, idx_sort] = sort(xBest); 
    y_sort = yBest(idx_sort);
    
    % Manejadores para actualizar la línea y los puntos en la gráfica
    h_line = plot([inicio(1), x_sort, final(1)], [inicio(2), y_sort, final(2)], 'b-', 'LineWidth', 2);
    h_points = plot(x_sort, y_sort, 'ro', 'MarkerFaceColor', 'r');
    
    JBest_graf = zeros(1, MaxIter); % Para guardar el mejor fitness en cada iteración

    %% BUCLE PRINCIPAL: GWO + PSO Híbrido
    for iter = 1:MaxIter
        a = 2 - iter * (2 / MaxIter);  % Parámetro de control de convergencia para GWO (de 2 a 0)
        
        for i = 1:N % Para cada agente en el enjambre/manada
            if mod(i, 2) == 0  % Si el índice es par, aplica reglas de actualización PSO
                r1 = rand(1,D); r2 = rand(1,D); % Números aleatorios para componentes cognitivo y social
                V(i,:) = W*V(i,:) + C1*r1.*(pBest(i,:)-X(i,:)) + C2*r2.*(gBest - X(i,:));
                X(i,:) = round(X(i,:) + V(i,:));
            else  % Si el índice es impar, aplica reglas de actualización GWO
                for d = 1:D % Para cada dimensión (coordenada)
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
                    
                    % Promedio de las influencias de los tres mejores lobos
                    X(i,d) = round((X1 + X2 + X3) / 3);
                end
            end
            
            % Corrección de límites: asegurar que los agentes permanezcan dentro del mapa
            X(i,:) = max(min(X(i,:), mapSize), 1);
            
            % Evaluación del fitness de la nueva posición y actualización de mejores
            Ji = Ruta(X(i,:)', mapa_bin, inicio, final);
            
            % Actualizar la mejor posición personal (pBest)
            if Ji < JpBest(i)
                pBest(i,:) = X(i,:);
                JpBest(i) = Ji;
            end
            
            % Actualizar la mejor posición global (gBest) y la jerarquía GWO
            if Ji < JBest
                JBest = Ji;
                gBest = X(i,:);
                
                % Aquí también necesitamos actualizar alpha, beta, delta para la parte GWO
                % Se reevalúa el J para todos los lobos para reordenar la jerarquía
                % Esto es importante ya que gBest podría no ser el 'alpha' si era de tipo PSO
                % y superó a los anteriores alpha, beta, delta.
                % Para ser rigurosos, se podría recalcular alpha, beta, delta aquí o
                % al final del bucle interno (después de que todos los agentes se muevan).
                % Por simplicidad y eficiencia, mantendremos la actualización de gBest
                % y actualizaremos alpha, beta, delta para el siguiente ciclo.
                
                xBest = gBest(1:Nk); % Actualiza los puntos de la mejor ruta para visualización
                yBest = gBest(Nk+1:end);
            end
        end % Fin del bucle de agentes

        % Re-ordenar alpha, beta, delta después de que todos los agentes se hayan movido
        % y potencialmente hayan encontrado mejores soluciones que alteran la jerarquía.
        for i = 1:N
            J(i) = Ruta(X(i,:)', mapa_bin, inicio, final); % Re-evaluar J para todos los agentes
        end
        [J_sorted, idx] = sort(J);
        alpha = X(idx(1),:); 
        beta = X(idx(2),:); 
        delta = X(idx(3),:);
        % Si JBest se actualizó en el bucle interno, ya es el valor correcto.
        % Si no, se asegura que sea el mejor de la población actual.
        JBest = J_sorted(1); 
        gBest = alpha; % gBest siempre será el alpha actualizado

        % Actualización visual de la mejor ruta encontrada
        xBest = gBest(1:Nk); 
        yBest = gBest(Nk+1:end);
        [x_sort, idx_sort] = sort(xBest); 
        y_sort = yBest(idx_sort);
        set(h_line, 'XData', [inicio(1), x_sort, final(1)], 'YData', [inicio(2), y_sort, final(2)]);
        set(h_points, 'XData', x_sort, 'YData', y_sort);
        drawnow; % Refrescar la ventana de la figura
        
        JBest_graf(iter) = JBest; % Guardar el mejor fitness para la gráfica de convergencia
        
        % Mostrar log en la consola
        disp(['Mapa: ', current_map_file, ' | Iteración: ', num2str(iter), ' | JBest: ', num2str(JBest)]);
    end % Fin del bucle de iteraciones

    %% GRAFICAR CONVERGENCIA
    figure; % Nueva figura para la gráfica de convergencia de cada mapa
    plot(1:MaxIter, JBest_graf, 'LineWidth', 2);
    xlabel('Iteraciones'); 
    ylabel('Fitness J'); 
    title(['Convergencia GWO-PSO Híbrido para ', current_map_file]);
    set(gca, 'FontSize', 12);
    
    % Pausar para ver el resultado de cada mapa antes de pasar al siguiente
    % pause(2);
    
    fprintf('\nTerminado de procesar mapa: %s\n\n', current_map_file);
end % Fin del bucle de mapas

disp('Todos los mapas han sido procesados.');