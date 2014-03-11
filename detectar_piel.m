function [ mask ] = detectar_piel(imagen, c)
%DETECTAR_PIEL Detecta la piel en una fotograf�a
%
%   [MASK] = DETECTAR_PIEL(IMAGEN, C) Detecta los pixeles de IMAGEN que
%   corresponden con un �rea de piel y devuelve una MASK del �rea
%   detectada. C es un umbral de detecci�n de p�xeles oscuros que se
%   realiza en la componente de brillo, V, en el espacio de color HSV.
%   
%   Antonio Jos� Moya D�az
%       21 de Junio de 2012
%   Procesamiento Digital de Im�genes


% Se presenta a continuaci�n un algoritmo basado en el presentado en el
% art�culo 'Eye detection using color cues and projection functions' de R.
% Thilak Kumar, S. Kumar Raja y A.G. Ramakrishnan
    
    % Se comprueba si el usuario a introducido un valor de umbralizaci�n,
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
    

    
    %% Paso 1: M�scara en HSV
    IH=rgb2hsv(I);
    
    % Obtenemos una primera m�scara umbralizando en HSV por un valor dado.
    % Por defecto ser� un valor 90 sobre 255.
    mask1=im2bw(IH(:,:,3),c/255);
    
    % As� obtenemos una primera m�scara con los p�xeles oscuros de la
    % imagen.


    %% Paso 2: Obtenci�n de la m�scara por color
    I=double(imagen);

    % Se calculan los �ndices normalizados propuestos por el art�culo
    NR=(I(:,:,1)./(I(:,:,1)+I(:,:,2)+I(:,:,3)))*255;
    NG=(I(:,:,2)./(I(:,:,1)+I(:,:,2)+I(:,:,3)))*255;

    % Se buscan aquellos p�xeles que se encuentren dentro del rango de
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

    
    %% Paso 3: Combinamos las dos m�scaras en una sola
    mask_previa=logical(mask1.*mask2);

    % Dentro del �mbito de la detecci�n de los ojos, la idea es que, en una
    % regi�n de p�xeles pertenecientes a la cara, los ojos ser�n la zona
    % m�s oscura de la misma. As� pues se realiza un doble proceso, por un
    % lado se detectan los p�xeles oscuros de toda la imagen, mask1, y por
    % otro los pixeles que se encuentran dentro del rango que se espera,
    % est�n los p�xeles del color de la piel, poniendo en la mask2, �stos a
    % 1 y los pixeles no pertenecientes a la piel a 0. Finalmente, haciendo
    % un AND de ambas m�scaras nos dar� una m�scara con una zona que
    % corresponder� con m�s o menos precisi�n al �rea ocupada por la piel.
    
    %% Paso 4: Mejora de la m�scara

    % Como vemos, la m�scara nos deja fuera los ojos, y lo que nos interesa
    % es delimitar una zona donde poder buscarlos de forma m�s o menos
    % f�cil, por tanto los borraremos de la m�scara para delimitar dicha
    % zona en la cara en su totalidad.
    
    mask = imfill(mask_previa, 'holes');

    % Resulta que en los bordes de la m�scara pueden haberse colado algunos
    % p�xeles oscuros del pelo o similares, que no nos interesan que est�n
    % presentes ya que podr�an ser mas oscuros que los ojos. Por tanto,
    % erosionmos para detertar la piel por defecto.
    
    st=strel('disk',4);
    mask=imerode(mask,st);

    %% Muestra del proceso
    % Descomentar las siguientes l�neas para ver una muestra gr�fica del
    % proceso llevado a cabo.
    
%     figure,
%     subplot(2,3,1),imshow(imagen),title('Imagen original');
%     subplot(2,3,2),imshow(uint8(I)),title('Imagen contrastada');
%     
%     subplot(2,3,4),imshow(mask1),title('M�scara 1');
%     subplot(2,3,5),imshow(mask2),title('M�scara 2');
%     subplot(2,3,6),imshow(mask_previa),title('M�scara 1 AND M�scara 2');
%     
%     subplot(2,3,3),imshow(mask),title('M�scara final');    
    
end

