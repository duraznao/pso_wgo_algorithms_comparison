
clear; clc;

% Parámetros generales
reps = 100;
MaxIter = 300;
Nombres = {'PSO', 'GWO', 'GWO-PSO'};
Resultados = zeros(reps, 3);  % [PSO, GWO, GWO-PSO]

for metodo = 1:3
    fprintf('\nEjecutando método: %s\n', Nombres{metodo});
    for r = 1:reps
        switch metodo
            case 1  % PSO
                JBest = run_pso(MaxIter);
            case 2  % GWO
                JBest = run_gwo(MaxIter);
            case 3  % GWO-PSO
                JBest = run_gwo_pso(MaxIter);
        end
        Resultados(r, metodo) = JBest;
        fprintf('Repetición %d: JBest = %.4f\n', r, JBest);
    end

end

% Mostrar resultados
fprintf('\nResumen de resultados:\n');
for metodo = 1:3
    prom = mean(Resultados(:,metodo));
    stdv = std(Resultados(:,metodo));
    fprintf('%s -> Promedio: %.4f | Desviación: %.4f\n', Nombres{metodo}, prom, stdv);
end

% Gráfica boxplot
figure;
boxplot(Resultados, 'Labels', Nombres);
ylabel('JBest Final');
title('Comparación PSO vs GWO vs Híbrido GWO-PSO');
grid on;

% Histograma de cada método
figure;
for i = 1:3
    subplot(1,3,i);
    histogram(Resultados(:,i), 8);
    title(['Histograma: ', Nombres{i}]);
    xlabel('JBest'); ylabel('Frecuencia');
    grid on;
end

% % Dibujo de la mejor ruta en el mapa
% [~, metodo_ganador] = min(mean(Resultados));  % Método con mejor promedio
% fprintf('\\nMétodo ganador: %s\\n', Nombres{metodo_ganador});
% 
% switch metodo_ganador
%     case 1
%         [~, idx] = min(Resultados(:,1));
%         [JBest, xBest, yBest] = run_pso(MaxIter);
%         titulo = 'Ruta Óptima - PSO';
%     case 2
%         [~, idx] = min(Resultados(:,2));
%         [JBest, xBest, yBest] = run_gwo(MaxIter);
%         titulo = 'Ruta Óptima - GWO';
%     case 3
%         [~, idx] = min(Resultados(:,3));
%         [JBest, xBest, yBest] = run_gwo_pso(MaxIter);
%         titulo = 'Ruta Óptima - GWO-PSO';
% end
% 
% % Mostrar en mapa
% load mapa
% imshow(mapa_bin); hold on;
% inicio = [20, 280]; final = [280, 20];
% [x_sort, idx] = sort(xBest); y_sort = yBest(idx);
% plot([inicio(1), x_sort, final(1)], [inicio(2), y_sort, final(2)], 'b-', 'LineWidth', 2);
% plot(x_sort, y_sort, 'ro', 'MarkerFaceColor', 'r');
% title(titulo);
