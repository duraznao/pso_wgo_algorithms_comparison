function J = Ruta(X, img, inicio, final)
    % Evaluar ruta considerando obstáculos y distancia

    Theta = X';
    n = length(Theta) / 2;
    distancia_total = 0;
    penalizacion = 0;

    % Extraer y ordenar puntos
    x = Theta(1:n);
    y = Theta(n+1:end);
    [x, idx] = sort(x, 'ascend');
    y = y(idx);

    [alto, ancho] = size(img);
    for i = 1:length(x)
        if x(i) < 1 || x(i) > ancho || y(i) < 1 || y(i) > alto
            J = 1e6;
            return;
        end
    end

    % Ruta completa
    x_full = [inicio(1), x, final(1)];
    y_full = [inicio(2), y, final(2)];

    for i = 1:length(x_full)-1
        xi = round(x_full(i));
        yi = round(y_full(i));
        xf = round(x_full(i+1));
        yf = round(y_full(i+1));

        [xl, yl] = bresenham(xi, yi, xf, yf);

        % Verificar colisión
        for k = 1:length(xl)
            xk = xl(k);
            yk = yl(k);
            if xk < 1 || xk > ancho || yk < 1 || yk > alto || img(yk, xk) == 0
                penalizacion = penalizacion + 1e6;
            end
        end

        % Distancia del tramo
        d = sqrt((x_full(i+1) - x_full(i))^2 + (y_full(i+1) - y_full(i))^2);
        distancia_total = distancia_total + d;
    end

    J = distancia_total + penalizacion;
end
