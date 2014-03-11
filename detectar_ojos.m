function [ coordenadas ] = detectar_ojos( imagen, piel)
%DETECTAR_OJOS Detecta los ojos en una fotograf�a de forma autom�tica
%
%   [COORD]=DETECTAR_OJOS(IMG,PIEL) Detecta de forma autom�tica los ojos en
%   una fotograf�a mediante la b�squeda de puntos oscuros en un �rea
%   determinada por la m�scara PIEL. Devuelve las coordenadas de los dos
%   primeros puntos que estima como ojos.
%
%   Antonio Jos� Moya D�az
%       21 de Junio de 2012
%   Procesamieto Digital de Im�genes

    % Pasamos la imagen a escala de grises
    G=rgb2gray(uint8(imagen));

    % Invertimos la piel
    skin=1-piel;
    
    % La m�scara de piel calculada por la funci�n detectar_piel nos deja a
    % 0 -elimina- todos los p�xeles no de piel. Sin embargo, ahora lo que
    % queremos es mantener los pixeles de la piel y saturar todos los
    % dem�s, ya que nuestra intenci�n ser� buscar los ojos como zonas
    % oscuras.
    skin=uint8(skin)*255;
    
    % Sumando la m�scara modificada tendremos aislados los pixeles de piel
    cara=G+skin;

    % En la experiencia basada en la bater�a de im�genes que se ha usado
    % se ha observado una fuerte dependencia con un umbral -se comenta m�s
    % adelante-, y adem�s, se ha observado que da un relativo alto �ndice
    % de acierto en un rango de umbralizaci�n entre el 20% y el 30%.
    % Por ello se ha intentado en lo posible automatizar el proceso y
    % hacerlo transparente para un hipot�tico usuario. Para ello se ha
    % iterado entre esos valores en busca de dos puntos coincidentes,
    % cuando se encuentran, se deja de iterar y se devuelve un resultado.
    % Como se explica m�s adelante y en el documento que acompa�a, esto
    % tiene algunos defectos.
    
    % Indicie de inicio
    i=0.2;
    % Estructura para morfolog�a
    st=strel('disk',4);
    n=0;
    while n~=2 && i<0.3    

        % Aislada la cara, los ojos ser�n la zona m�s oscura, por tanto,
        % umbralizamos
        ojos=im2bw(cara,i);

        
        % Invertirmos la umbralizaci�n, ya que ahora vamos a detectar por
        % proyecciones y nos interesa que la zona detectable tenga valores
        % altos ya que es m�s f�cil trabajar as�.
        ojos=1-ojos;
        
        % Rellenamos para dar consistencia a los ojos, eliminando posibles
        % puntos negros en el interior de los ojos que podr�an hacer que los
        % ojos no sobrevivieran al proceso de apertura que usaremos despu�s
        ojos = imfill(ojos, 'holes'); 
        
        % Realizamos la apertura.
        % Realizmos una operaci�n de apertura. Si todos los par�metros
        % est�n bien ajustados y la imagen de la cara es buena a efectos de
        % detecci�n, tras el proceso esperamos que solo sobrevivan 2 �reas,
        % una por cada ojo.
        ojos=imopen(ojos,st);
        
        % Se etiquetan todas las �reas conectadas en la m�scara.
        % Usamos el par�metros n, que nos da el n�mero de areas, como una
        % de las condiciones de parada
        [L n]=bwlabel(ojos);

        i=i+0.01;
    end

    % Se calculan propiedades de las zonas conectadas
    stats = regionprops(L);

    if size(stats,1)<2
        error('No se ha podido determinar la localizaci�n de los ojos');
    end
    
    % Se devuelven los centroides de las 2 primeras zonas conectadas
    coordenadas{1}=stats(1,1).Centroid;
    coordenadas{2}=stats(2,1).Centroid;

    % Notar que no se realiza ning�n tipo de comprobaci�n de validaci�n de
    % las �reas como ojos. Solo se devuelven los dos primeros.
    % En la mayor�a de los casos probados, con los par�metros y las
    % condiciones usadas en todo el proceso, suele ser condici�n
    % suficiente. Sin embargo, podr�an haber aparecido m�s elementos
    % conectados. En cuyo caso, y de haber dispuestos de m�s tiempo, se
    % podr�an haber validado los puntos mediante comprobaciones
    % geom�tricas (posici�n, orientaci�n, distancia m�nima mutua...).

end

