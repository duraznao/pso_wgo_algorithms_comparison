function [x, y] = bresenham(x1, y1, x2, y2)
    x1 = round(x1); y1 = round(y1);
    x2 = round(x2); y2 = round(y2);

    dx = abs(x2 - x1);
    dy = abs(y2 - y1);
    steep = abs(dy) > abs(dx);

    if steep
        t = x1; x1 = y1; y1 = t;
        t = x2; x2 = y2; y2 = t;
        t = dx; dx = dy; dy = t;
    end

    if x1 > x2
        [x1, x2] = deal(x2, x1);
        [y1, y2] = deal(y2, y1);
    end

    derror = 2*dy - dx;
    y = y1;
    ystep = 1;
    if y1 > y2, ystep = -1; end

    x = x1:x2;
    yvals = zeros(size(x));
    for i = 1:length(x)
        if steep
            yvals(i) = x(i);
            x(i) = y;
        else
            yvals(i) = y;
        end
        if derror > 0
            y = y + ystep;
            derror = derror - 2*dx;
        end
        derror = derror + 2*dy;
    end

    y = yvals;
end
