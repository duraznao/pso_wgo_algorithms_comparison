clear; clc; close all;

%% Definir los vectores "inicio" y "final" y el nombre de la imgen
imagen = 'mapa_3.jpg';
variable_mapa = 'mapa_3.mat';
inicio = [20, 280];
final = [280, 20];

%% Cargar la imagen a binarizar

% la imagen debe estar dibujada con objetos en color negro RGB(0,0,0) que representan
% los obstáculos y el fondo blanco RGB(255, 255, 255)
% el tamaño es 300 x 300 pixeles

imagen = imread(strcat('recursos/',imagen));

if isempty(imagen)
    error('No se pudo cargar la imagen. Asegúrate de que el archivo exista en el directorio.');
end

%% Mostrar información sobre la imagen original
disp('Información de la imagen original:');
disp(['Tamaño de la imagen: ', num2str(size(imagen))]);
disp(['Tipo de datos de la imagen: ', class(imagen)]);

%% Convertir la imagen a escala de grises
imagen_gris = rgb2gray(imagen);

%% Binarizar la imagen (umbralización)
% Usamos un umbral alto para asegurarnos de que los blancos sean completamente blancos
umbral = graythresh(imagen_gris); % Determina automáticamente un buen umbral
imagen_binaria = imbinarize(imagen_gris, umbral);

% Invertir la imagen binaria si es necesario (blanco = 1, negro = 0)
% En algunas imágenes, el fondo puede ser negro y el objeto blanco
%if sum(sum(imagen_binaria)) > (size(imagen_binaria, 1) * size(imagen_binaria, 2)) / 2
%    imagen_binaria = ~imagen_binaria; % Invierte la imagen binaria
%end

%% Extraer la matriz de 300x300
mapa_bin = double(imagen_binaria); % Convierte la imagen binaria a una matriz de dobles

% Mostrar la matriz
disp(mapa_bin);

%% Mostrar la imagen binaria
figure;
imshow(mapa_bin, []);
title('Imagen binarizada');


%% Guardar la matriz en un archivo (opcional)
save(variable_mapa, 'mapa_bin', "inicio", "final");

%% Código para binzarizar imagenes a color
% % Verificar si la imagen ya está binarizada
% % Si la imagen tiene valores únicamente 0 y 255, no es necesario hacer nada adicional
% unique_valores = unique(imagen(:));
% disp('Valores únicos en la imagen:');
% disp(unique_valores);
% 
% % Convertir la imagen a double (como solicitado)
% mapa_bin = double(imagen);
% 
% % Verificar el contenido de la matriz binaria
% disp('Contenido de la matriz binaria:');
% min_valor = min(mapa_bin(:));
% max_valor = max(mapa_bin(:));
% disp(['Valor mínimo en mapa_bin: ', num2str(min_valor)]);
% disp(['Valor máximo en mapa_bin: ', num2str(max_valor)]);
% 
% % Mostrar la imagen binaria
% figure;
% imshow(mapa_bin, []);
% title('Imagen Binarizada');
% 
% % Paso 3: Guardar los datos en un archivo .mat
% save('mapa_1.mat', 'mapa_bin', 'inicio', 'final');
% 
% % Opcional: Mostrar los datos guardados
% disp('Datos guardados en mapa_1.mat:');
% disp('mapa_bin:');
% disp('inicio:');
% disp(inicio);
% disp('final:');
% disp(final);