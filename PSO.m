clear

%% ====================
%Funçao
%======================

quality = @(x,y) -20*exp(-0.2*(sqrt(0.5*(x.^2+y.^2))))-exp(0.5*(cos(2*pi*x)+cos(2*pi*y)))+20+exp(1);
% quality = @(x,y) 3*(1-x).^2.*exp(-(x.^2)-(y+1).^2) ...
%     - 10*(x/5-x.^3-y.^5).*exp(-x.^2-y.^2)...
%     -1/3*exp(-(x+1).^2-y.^2);
 
%% ====================
%Calculo do espaço de pesquisa
%======================

%Area de Pesquisa
Area = 32.768;
%Area = 2;
%Area = 20;
MaxArea = Area;
MinArea = -Area;
x1 = linspace(MinArea,MaxArea,100);
x2 = linspace(MinArea,MaxArea,100);

%Combinação de pontos entre x1 e x2
[x1,x2]= meshgrid(x1,x2);

%Calculo da qualidade de cada ponto da combinação
fx = quality(x1,x2);

%% ====================
%Desenho do espaço de pesquisa
%======================

    %em 2D

subplot(1,2,1)
contour(x1,x2,fx,20);
axis([MinArea MaxArea MinArea MaxArea])
hold on
    %em 3D

subplot(1,2,2)
axis([MinArea MaxArea MinArea MaxArea])
contour3(x1,x2,fx,20);
splot=surf(x1,x2,fx,'FaceAlpha',0.25);
splot.EdgeColor = 'none';
hold on
%% ====================
%inicialização dos agentes
%======================

Nagentes = 5;                   %default =5
Iteracoes = 100;
ite = 0;
wmax = 0.9;                     %default = 0.9
wmin = 0.2;                     %default = 0.2
wvar = (wmax-wmin)/Iteracoes;
c1=0.3;                           %default = 0.3
c2=0.2;                           %default = 0.2
%% ====================
%inicializar as posicoes das particulas, Pbest's e Gbest.
%======================
particle = zeros(Nagentes, 2);
Pbest = zeros(Nagentes, 2);
velo = zeros(Nagentes, 2);
old = zeros(Nagentes, 2);

for i = 1:Nagentes
    for pos =1:2
        particle(i,pos) = (rand*2-1)*MaxArea;
        Pbest(i,pos) = particle(i,pos);
        velo(i,pos) = 0;
    end
    plotthispoint(particle(i,1),particle(i,2),quality(particle(i,1),particle(i,2)),'bx')
end
GlobalBest(1,1)=particle(i,1);
GlobalBest(1,2)=particle(i,2);
QualGbest = quality(GlobalBest(1,1),GlobalBest(1,2));
for i = 1:Nagentes
       qualtest = quality(particle(i,1),particle(i,2));
       qualbest = quality(Pbest(i,1),Pbest(i,2));
       if (qualtest<qualbest)
            Pbest(i,1) = particle(i,1);
            Pbest(i,2) = particle(i,2);
       end
       if (qualtest<QualGbest)
            GlobalBest(1,1) =particle(i,1);
            GlobalBest(1,2) =particle(i,2);
            QualGbest = quality(GlobalBest(1,1),GlobalBest(1,2));
       end
end

%% =================
%MAIN
%===================

weight=wmax;

while ite<=Iteracoes
    %% ====================
    %Calculo da Velocidade
    %======================
    %Tendo o calculo da velocidade fora do ciclo do movimento em si,
    %adiamos a convergencia para o Melhor Valor Global, tendo assim um
    %pouco mais de exploração.
   for i = 1:Nagentes
        for pos = 1:2
            %Podemos tambem adicionar um fator aleatorio para cada
            %parametro aumentando assim tambem um pouco mais a exploração.
            
            %sem o fator aleatorio
            %velo(i,pos) = weight*velo(i,pos)+c1*(Pbest(i,pos)-particle(i,pos))+c2*(GlobalBest(1,pos)-particle(i,pos));
            
            %com o fator aleatorio
            velo(i,pos) = weight*velo(i,pos)+c1*rand()*(Pbest(i,pos)-particle(i,pos))+c2*rand()*(GlobalBest(1,pos)-particle(i,pos));
        end
   end
   %% =================
   %Movimento das particulas
   %===================
   for i = 1:Nagentes
        for pos = 1:2
            old(i,pos)=particle(i,pos);
            particle(i,pos)=particle(i,pos)+velo(i,pos);
            if particle(i,pos)>MaxArea
                particle(i,pos) = MaxArea;
            end
            if particle(i,pos)<MinArea
                particle(i,pos) = MinArea;
            end
        end
        if ite == Iteracoes
            %Plot para assinalar o fim da viagem de cada particula
            plotthispoint(particle(i,1),particle(i,2),quality(particle(i,1),particle(i,2)),'b*')
            
        end

        X = [particle(i,1),old(i,1)];
        Y = [particle(i,2),old(i,2)];
        Z = [quality(particle(i,1),particle(i,2)),quality(old(i,1),old(i,2))];
        
        lh.Color=[1,0,0,0.35];  %Linhas a Vermelho
        %lh.Color=[0,0,0,0.35]; %Linhas a Preto
        
        plotthispoint(X,Y,Z,lh);
   end
   %% ==================
   %Atualizar melhores
   %====================
   
   for i = 1:Nagentes
       qualtest = quality(particle(i,1),particle(i,2));
       qualbest = quality(Pbest(i,1),Pbest(i,2));
       if (qualtest<qualbest)
            Pbest(i,1) = particle(i,1);
            Pbest(i,2) = particle(i,2);
            if (qualtest<QualGbest)
                GlobalBest(1,1) =particle(i,1);
                GlobalBest(1,2) =particle(i,2);
                QualGbest = quality(GlobalBest(1,1),GlobalBest(1,2));
            end
       end
   end
   weight=weight-wvar;
   disp(['Iteração n# ', int2str(ite)]);
   ite = ite+1;
end

plotthispoint(GlobalBest(1,1),GlobalBest(1,2),quality(GlobalBest(1,1),GlobalBest(1,2)),'bo');
 subplot(1,2,1)
 hold off
 subplot(1,2,2)
 hold off
 
function plotthispoint(X,Y,Z,marker)
    %Funcao criada para fazer plot em 2D e 3D simultaneamente
    subplot(1,2,1)
    plot(X,Y,marker)
    subplot(1,2,2)
    plot3(X,Y,Z,marker)
end
