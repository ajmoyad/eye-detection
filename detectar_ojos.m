function [ coordenadas ] = detectar_ojos( imagen, piel)
%DETECTAR_OJOS Detecta los ojos en una fotografía de forma automática
%
%   [COORD]=DETECTAR_OJOS(IMG,PIEL) Detecta de forma automática los ojos en
%   una fotografía mediante la búsqueda de puntos oscuros en un área
%   determinada por la máscara PIEL. Devuelve las coordenadas de los dos
%   primeros puntos que estima como ojos.
%
%   Antonio José Moya Díaz
%       21 de Junio de 2012
%   Procesamieto Digital de Imágenes

    % Pasamos la imagen a escala de grises
    G=rgb2gray(uint8(imagen));

    % Invertimos la piel
    skin=1-piel;
    
    % La máscara de piel calculada por la función detectar_piel nos deja a
    % 0 -elimina- todos los píxeles no de piel. Sin embargo, ahora lo que
    % queremos es mantener los pixeles de la piel y saturar todos los
    % demás, ya que nuestra intención será buscar los ojos como zonas
    % oscuras.
    skin=uint8(skin)*255;
    
    % Sumando la máscara modificada tendremos aislados los pixeles de piel
    cara=G+skin;

    % En la experiencia basada en la batería de imágenes que se ha usado
    % se ha observado una fuerte dependencia con un umbral -se comenta más
    % adelante-, y además, se ha observado que da un relativo alto índice
    % de acierto en un rango de umbralización entre el 20% y el 30%.
    % Por ello se ha intentado en lo posible automatizar el proceso y
    % hacerlo transparente para un hipotético usuario. Para ello se ha
    % iterado entre esos valores en busca de dos puntos coincidentes,
    % cuando se encuentran, se deja de iterar y se devuelve un resultado.
    % Como se explica más adelante y en el documento que acompaña, esto
    % tiene algunos defectos.
    
    % Indicie de inicio
    i=0.2;
    % Estructura para morfología
    st=strel('disk',4);
    n=0;
    while n~=2 && i<0.3    

        % Aislada la cara, los ojos serán la zona más oscura, por tanto,
        % umbralizamos
        ojos=im2bw(cara,i);

        
        % Invertirmos la umbralización, ya que ahora vamos a detectar por
        % proyecciones y nos interesa que la zona detectable tenga valores
        % altos ya que es más fácil trabajar así.
        ojos=1-ojos;
        
        % Rellenamos para dar consistencia a los ojos, eliminando posibles
        % puntos negros en el interior de los ojos que podrían hacer que los
        % ojos no sobrevivieran al proceso de apertura que usaremos después
        ojos = imfill(ojos, 'holes'); 
        
        % Realizamos la apertura.
        % Realizmos una operación de apertura. Si todos los parámetros
        % están bien ajustados y la imagen de la cara es buena a efectos de
        % detección, tras el proceso esperamos que solo sobrevivan 2 áreas,
        % una por cada ojo.
        ojos=imopen(ojos,st);
        
        % Se etiquetan todas las áreas conectadas en la máscara.
        % Usamos el parámetros n, que nos da el número de areas, como una
        % de las condiciones de parada
        [L n]=bwlabel(ojos);

        i=i+0.01;
    end

    % Se calculan propiedades de las zonas conectadas
    stats = regionprops(L);

    if size(stats,1)<2
        error('No se ha podido determinar la localización de los ojos');
    end
    
    % Se devuelven los centroides de las 2 primeras zonas conectadas
    coordenadas{1}=stats(1,1).Centroid;
    coordenadas{2}=stats(2,1).Centroid;

    % Notar que no se realiza ningún tipo de comprobación de validación de
    % las áreas como ojos. Solo se devuelven los dos primeros.
    % En la mayoría de los casos probados, con los parámetros y las
    % condiciones usadas en todo el proceso, suele ser condición
    % suficiente. Sin embargo, podrían haber aparecido más elementos
    % conectados. En cuyo caso, y de haber dispuestos de más tiempo, se
    % podrían haber validado los puntos mediante comprobaciones
    % geométricas (posición, orientación, distancia mínima mutua...).

end

