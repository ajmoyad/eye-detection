%% Práctica 3: Detección automática de ojos
% Flujo de demostración

clear, clc, close all
warning off

%% Resultado correcto
% A continuación una serie de imágenes que presentan un resultado correcto.
I1=imread('imagenes/yo2.png');
I2=imread('imagenes/yo3.jpg');
I3=imread('imagenes/yo.png'); 
I4=imread('imagenes/cara3.jpg');
I5=imread('imagenes/cara4.jpg');

%% Resultado erroneo
% A continuación una serie de imágenes que presentan un resultado, pero
% éste es erróneo

I12=imread('imagenes/negro.jpg');
I7=imread('imagenes/negra.jpg');
I8=imread('imagenes/cara.jpg');
I9=imread('imagenes/cara2.jpg');
I10=imread('imagenes/ojo6.jpg');
I11=imread('imagenes/lena.png');
I6=imread('imagenes/nene.jpg');


%% Incapaz de hallar resultado
% Comentadas por que éstas imágenes generan una excepción.
%I=imread('imagenes/Charlize.jpg'); % Es es la jodida % SOPRENDENTE CON APERTURA Y 0.3
%I=imread('imagenes/carnet.jpg'); % Aceptable SIN apertura
%I=imread('imagenes/Edu.jpg'); % GAFAS / IMPOSIBLE


img={'I1';'I2';'I3';'I4';'I5';'I6';'I7';'I8';'I9';'I10';'I11';'I12'};

for i=1:size(img,1)
    I=eval(img{i});
    
    piel=detectar_piel(I);
    a=detectar_ojos(I,piel);
    
    figure(31)
    imshow(I),hold on
    C1=a{1};C2=a{2};
    scatter([C1(1) C2(1)],[C1(2) C2(2)],20,'green','filled');
    scatter([C1(1) C2(1)],[C1(2) C2(2)],70,'green','+');
    pause(1)
    close all
    
end






