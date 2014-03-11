function [ mask ] = detectar_piel(imagen, c)
%DETECTAR_PIEL Detecta la piel en una fotografía
%
%   [MASK] = DETECTAR_PIEL(IMAGEN, C) Detecta los pixeles de IMAGEN que
%   corresponden con un área de piel y devuelve una MASK del área
%   detectada. C es un umbral de detección de píxeles oscuros que se
%   realiza en la componente de brillo, V, en el espacio de color HSV.
%   
%   Antonio José Moya Díaz
%       21 de Junio de 2012
%   Procesamiento Digital de Imágenes


% Se presenta a continuación un algoritmo basado en el presentado en el
% artículo 'Eye detection using color cues and projection functions' de R.
% Thilak Kumar, S. Kumar Raja y A.G. Ramakrishnan
    
    % Se comprueba si el usuario a introducido un valor de umbralización,
    % en caso contrario se usa el valor 90.
    if nargin<2
        c=90;
    end


    I=imagen;

    %% Paso 0: Contrastado de la imagen
    %         De cada una de sus bandas por separado, en espacio RGB
    I(:,:,1) = imadjust(I(:,:,1),stretchlim(I(:,:,1)),[]);
    I(:,:,2) = imadjust(I(:,:,2),stretchlim(I(:,:,2)),[]);
    I(:,:,3) = imadjust(I(:,:,3),stretchlim(I(:,:,3)),[]);
    

    
    %% Paso 1: Máscara en HSV
    IH=rgb2hsv(I);
    
    % Obtenemos una primera máscara umbralizando en HSV por un valor dado.
    % Por defecto será un valor 90 sobre 255.
    mask1=im2bw(IH(:,:,3),c/255);
    
    % Así obtenemos una primera máscara con los píxeles oscuros de la
    % imagen.


    %% Paso 2: Obtención de la máscara por color
    I=double(imagen);

    % Se calculan los índices normalizados propuestos por el artículo
    NR=(I(:,:,1)./(I(:,:,1)+I(:,:,2)+I(:,:,3)))*255;
    NG=(I(:,:,2)./(I(:,:,1)+I(:,:,2)+I(:,:,3)))*255;

    % Se buscan aquellos píxeles que se encuentren dentro del rango de
    % color propuesto
    mask2=zeros(size(I,1),size(I,2));

    for i=1:1:size(I,1)
        for j=1:1:size(I,2)
            %if NR(i,j)>96 && NR(i,j)<120 && NG(i,j)<86 && NG(i,j)>75
            if NR(i,j)>90 && NR(i,j)<145 && NG(i,j)<100 && NG(i,j)>60
                mask2(i,j)=1;
            end
        end
    end

    
    %% Paso 3: Combinamos las dos máscaras en una sola
    mask_previa=logical(mask1.*mask2);

    % Dentro del ámbito de la detección de los ojos, la idea es que, en una
    % región de píxeles pertenecientes a la cara, los ojos serán la zona
    % más oscura de la misma. Así pues se realiza un doble proceso, por un
    % lado se detectan los píxeles oscuros de toda la imagen, mask1, y por
    % otro los pixeles que se encuentran dentro del rango que se espera,
    % estén los píxeles del color de la piel, poniendo en la mask2, éstos a
    % 1 y los pixeles no pertenecientes a la piel a 0. Finalmente, haciendo
    % un AND de ambas máscaras nos dará una máscara con una zona que
    % corresponderá con más o menos precisión al área ocupada por la piel.
    
    %% Paso 4: Mejora de la máscara

    % Como vemos, la máscara nos deja fuera los ojos, y lo que nos interesa
    % es delimitar una zona donde poder buscarlos de forma más o menos
    % fácil, por tanto los borraremos de la máscara para delimitar dicha
    % zona en la cara en su totalidad.
    
    mask = imfill(mask_previa, 'holes');

    % Resulta que en los bordes de la máscara pueden haberse colado algunos
    % píxeles oscuros del pelo o similares, que no nos interesan que estén
    % presentes ya que podrían ser mas oscuros que los ojos. Por tanto,
    % erosionmos para detertar la piel por defecto.
    
    st=strel('disk',4);
    mask=imerode(mask,st);

    %% Muestra del proceso
    % Descomentar las siguientes líneas para ver una muestra gráfica del
    % proceso llevado a cabo.
    
%     figure,
%     subplot(2,3,1),imshow(imagen),title('Imagen original');
%     subplot(2,3,2),imshow(uint8(I)),title('Imagen contrastada');
%     
%     subplot(2,3,4),imshow(mask1),title('Máscara 1');
%     subplot(2,3,5),imshow(mask2),title('Máscara 2');
%     subplot(2,3,6),imshow(mask_previa),title('Máscara 1 AND Máscara 2');
%     
%     subplot(2,3,3),imshow(mask),title('Máscara final');    
    
end

