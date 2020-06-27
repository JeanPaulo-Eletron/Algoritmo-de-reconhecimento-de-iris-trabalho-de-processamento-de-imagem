Raiz = 'C:\Users\aabel\Desktop\Reconhecer iris\ProjectX';
ValorDeCorte = 51;
CorteCilios  = 5;
TamanhoIris  = 100; 
for original=1:20
    for sequencia=1:3
        if original<10
            txtdir = [Raiz '\Originais\00'];
        else
            txtdir = [Raiz '\Originais\0'];
        end
        Original = imread([txtdir int2str(original) '_1_' int2str(sequencia) '.bmp']);
        Img = Original;
        J=Img;
        [i,f]=size(Img);
% figure,imshow(Img)
% 
% Alargamento de contraste(o minimo possivel para reconhecer a pupila)
        Img= imadjust(Img,[0.1 1]);
% figure,imshow(Img)
% prewitt = Img;
% 
%prewitt
        prewitt=BordaPupilaPrewitt(i,f,Img);
%          figure,imshow(prewitt)
% 
% Binariza��o
        prewitt = BinarizarL255(i, f, prewitt);
%          figure,imshow(prewitt)

        for t=1:2
% Fechamento
            prewittAF = Fechamento(i,f,prewitt);
            
% Mediana

            prewittAF = Mediana(i,f,prewittAF);

% figure,imshow(prewittAF)

            prewitt = prewittAF;
        end

        

        for t=1:2
% Abertura
            prewittAF = Abertura(i,f,prewitt);
            
            prewitt=prewittAF;
% Mediana
            
            prewitt = Mediana(i,f,prewitt);

        end
% figure,imshow(prewitt)
% 
% Negativo
% 
        prewitt = Negativo(i,f,prewitt);
% 
% figure,imshow(prewitt);
% 
% o raio m�dio da pupila
% InicioH = 0;
% 
        MaxH = RaioHorizontal(i,f,prewitt);
% 
        RaioDaPupilaH=fix(MaxH/2);
% 
        MaxV = RaioVertical(i,f,prewitt);    
%  
% calculando a localidade
        Toque=prewitt;
        InicioH=LocalidadeA(i,f,prewitt);
        InicioV=LocalidadeB(i,f,prewitt);
% 
        LocalidadeDaPupilaH=RaioDaPupilaH+InicioH;
% 
        RaioDaPupilaV=fix(MaxV/2);
% 
        LocalidadeDaPupilaV=RaioDaPupilaV+InicioV;
% 
        RaioDaPupilaM = fix((RaioDaPupilaV+RaioDaPupilaH)/2);
%         
        if RaioDaPupilaV>RaioDaPupilaH
            RaioDaPupila  = RaioDaPupilaV;
        else
            RaioDaPupila  = RaioDaPupilaH;
        end
% 
        LocalidadeDaPupila=[fix(LocalidadeDaPupilaH),fix(LocalidadeDaPupilaV)];
%         
        disp("raio m�dio da pupila: "+RaioDaPupilaM);
        disp("raio da pupila: "+RaioDaPupila);
        disp("Cnt:"+LocalidadeDaPupila(1)+','+LocalidadeDaPupila(2));
        disp("INICIOS H:"+InicioH);
        disp("INICIO V:"+InicioV);
%         
%figure,imshow(Teste);
% 
%circulo da pupila
% 
        Mascara = TracarCirculo(Img, LocalidadeDaPupila, RaioDaPupila, i, f);
%     
% 
% Preenchimento
% 
        Mascara = PrencherCirculo(Mascara, i, f);
% 
% figure,imshow(Mascara);
% 
% mascara= prewitt;
% 
% Somando a imagem com sua mascara
% 
        Img = Img + Mascara;
% 
% cortando parte de cima da iris
% 
        MascaraExterna = CortarCilios(Mascara,i,f,InicioH+CorteCilios);
%         MascaraExterna = Mascara;
% 
        NaoNormalizado = Original+MascaraExterna;
% 
        LocalidadeDaPupila = LocalidadeDaPupila+[0 0];
% 
        [Normalizado, ruido] = normalisariris(double(NaoNormalizado), [LocalidadeDaPupila(2) (LocalidadeDaPupila(1))], TamanhoIris, [LocalidadeDaPupila(2) (LocalidadeDaPupila(1))], RaioDaPupila+5, TamanhoIris, 446, 'teste');
% 
        Normalizado=histeq(Normalizado);
%         Normalizado = WalletGabor(Normalizado, 4, 6, 3, 1.7, 0.65, 1.3);%Ainda n�o implementado        
        [C, D] = size(Normalizado);
        imwrite(Normalizado, [Raiz '\Normalizado\' int2str(original) '_' int2str(sequencia) '.bmp']);
        figure,imshow(Normalizado);
    end
end
AC = 0;
FL = 0;
cont = 0;
contb = 0;
PastaPrincipal = [Raiz '\Normalizado'];
for i=1:20
    for j=1:20
        for k=1:3
            for m=1:3
                disp("Comparando a imagem "+k+" da pessoa "+i+" com a imagem "+m+" da pessoa "+j+".");
                A1 = [PastaPrincipal '\' int2str(i) '_' int2str(k) '.bmp'];
                A2 = [PastaPrincipal '\' int2str(j) '_' int2str(m) '.bmp'];
                I = imread( A1 );
                J = imread( A2 );
                porc=comparar(I,J);
                if porc > ValorDeCorte
                    palpite = "MESMA PESSOA";
                    if i == j
                        AC = AC + 1;
                        cont = cont + 1;
                    else
                        FL = FL + 1;
                        contb = contb + 1;
                    end    
                else
                    palpite = "PESSOAS DIFERENTES";
                    if i ~= j
                        AC = AC + 1;
                    else
                        FL = FL + 1;
                    end
                end
                disp(palpite);
            end
        end
    end
end
disp("Acertos:"+AC);
disp("Erros:"+FL);
disp("Taxa de acerto:"+(AC/(FL+AC))*100+"%");
disp("Msm:"+cont+","+contb);


% OLD   N�o ler codigos para possivel uso no futuro
%         %Histograma
%         
%         Img = histeq(Img);
%         
%         figure,imshow(Img);
%         %Alargamento de contraste
%         Aux= imadjust(Img,[0.4 1]);
%         
%         
%         %binariza��o
%         
%         for i=2 : i-1
%             for j=2: f-1
%                 if Aux(i, j)<1 
%                     Aux(i, j)=0;
%                 else
%                     Aux(i, j)=255;
%                 end
%             end     
%         end
%         
%         %mediana
%         
%         for a=2:i-1
%             for b=2:f-1
%                 J = [Aux(a-1,b-1),Aux(a,b-1),Aux(a+1,b-1),Aux(a-1,b),Aux(a,b),Aux(a+1,b),Aux(a-1,b+1),Aux(a,b+1),Aux(a+1,b+1)];
%                 J = sort(J);
%                 Aux(a,b) = J(5);
%             end
%         end
%         
%         
%         figure,imshow(Aux);
%         
%         
%         Aux = Aux - Mascara;
%         
%         % abertura
%         
%         Aux2=Aux;
%         
%         for t=1:3
%             for a=3:i-2
%                 for b=3:f-2
%                     if Aux(a,b)==0
%                         Aux2(a,b) = 0;
%                         Aux2(a-1,b) = 0;
%                         Aux2(a+1,b) = 0;
%                         Aux2(a,b-1) = 0;
%                         Aux2(a,b+1) = 0;
%         
%                         Aux2(a+1,b-1) = 0;
%                         Aux2(a+1,b+1) = 0;
%                         Aux2(a-1,b-1) = 0;
%                         Aux2(a-1,b+1) = 0;
%         
%                         Aux2(a+2,b) = 0;
%                         Aux2(a+1,b+1) = 0;
%                         Aux2(a+1,b-1) = 0;
%                         Aux2(a-2,b) = 0;
%                         Aux2(a-1,b+1) = 0;
%                         Aux2(a-1,b-1) = 0;            
%                         Aux2(a,b-2) = 0;
%                         Aux2(a,b+2) = 0;
%                         
%                         Aux2(a+2,b-1) = 0;
%                         Aux2(a+2,b+1) = 0;
%                         Aux2(a-2,b-1) = 0;
%                         Aux2(a-2,b+1) = 0;            
%                         Aux2(a-1,b-2) = 0;
%                         Aux2(a+1,b-2) = 0;
%                         Aux2(a-1,b+2) = 0;
%                         Aux2(a+1,b+2) = 0;
%                     else
%                         Aux2(a,b) = 255;
%                     end
%                 end
%             end
%             Aux=Aux2;
%         
%             %mediana
%         
%             for a=2:i-1
%                 for b=2:f-1
%                     J = [Aux(a-1,b-1),Aux(a,b-1),Aux(a+1,b-1),Aux(a-1,b),Aux(a,b),Aux(a+1,b),Aux(a-1,b+1),Aux(a,b+1),Aux(a+1,b+1)];
%                     J = sort(J);
%                     Aux(a,b) = J(5);
%                 end
%             end
%         end    
%         
%         % Fechamento
%         for t=1:6
%             Aux2 = Aux;
%             for a=3:i-2
%                 for b=3:f-2
%                     if Aux(a,b)==255
%                         Aux2(a,b) = 255;
%                         Aux2(a-1,b) = 255;
%                         Aux2(a+1,b) = 255;
%                         Aux2(a,b-1) = 255;
%                         Aux2(a,b+1) = 255;
%         
%                         Aux2(a+1,b-1) = 255;
%                         Aux2(a+1,b+1) = 255;
%                         Aux2(a-1,b-1) = 255;
%                         Aux2(a-1,b+1) = 255;
%         
%                         Aux2(a+2,b) = 255;
%                         Aux2(a+1,b+1) = 255;
%                         Aux2(a+1,b-1) = 255;
%                         Aux2(a-2,b) = 255;
%                         Aux2(a-1,b+1) = 255;
%                         Aux2(a-1,b-1) = 255;            
%                         Aux2(a,b-2) = 255;
%                         Aux2(a,b+2) = 255;
%                         
%                         Aux2(a+2,b-1) = 255;
%                         Aux2(a+2,b+1) = 255;
%                         Aux2(a-2,b-1) = 255;
%                         Aux2(a-2,b+1) = 255;            
%                         Aux2(a-1,b-2) = 255;
%                         Aux2(a+1,b-2) = 255;
%                         Aux2(a-1,b+2) = 255;
%                         Aux2(a+1,b+2) = 255;                
%                     else
%                         Aux2(a,b) = 0;
%                     end
%                 end
%             end
%             Aux=Aux2;
%             
%             %mediana
%         
%             for a=2:i-1
%                 for b=2:f-1
%                     J = [Aux(a-1,b-1),Aux(a,b-1),Aux(a+1,b-1),Aux(a-1,b),Aux(a,b),Aux(a+1,b),Aux(a-1,b+1),Aux(a,b+1),Aux(a+1,b+1)];
%                     J = sort(J);
%                     Aux(a,b) = J(5);
%                 end
%             end  
%         end
%         
%         Aux2 = Aux;
%         
%         figure,imshow(Aux2);
%         
%         % abertura
%         
%         for t=1:3
%             for a=3:i-2
%                 for b=3:f-2
%                     if Aux(a,b)==0
%                         Aux2(a,b) = 0;
%                         Aux2(a-1,b) = 0;
%                         Aux2(a+1,b) = 0;
%                         Aux2(a,b-1) = 0;
%                         Aux2(a,b+1) = 0;
%         
%                         Aux2(a+1,b-1) = 0;
%                         Aux2(a+1,b+1) = 0;
%                         Aux2(a-1,b-1) = 0;
%                         Aux2(a-1,b+1) = 0;
%         
%                         Aux2(a+2,b) = 0;
%                         Aux2(a+1,b+1) = 0;
%                         Aux2(a+1,b-1) = 0;
%                         Aux2(a-2,b) = 0;
%                         Aux2(a-1,b+1) = 0;
%                         Aux2(a-1,b-1) = 0;            
%                         Aux2(a,b-2) = 0;
%                         Aux2(a,b+2) = 0;
%                         
%                         Aux2(a+2,b-1) = 0;
%                         Aux2(a+2,b+1) = 0;
%                         Aux2(a-2,b-1) = 0;
%                         Aux2(a-2,b+1) = 0;            
%                         Aux2(a-1,b-2) = 0;
%                         Aux2(a+1,b-2) = 0;
%                         Aux2(a-1,b+2) = 0;
%                         Aux2(a+1,b+2) = 0;
%                     else
%                         Aux2(a,b) = 255;
%                     end
%                 end
%             end
%             Aux=Aux2;
%         
%             %mediana
%         
%             for a=2:i-1
%                 for b=2:f-1
%                     J = [Aux(a-1,b-1),Aux(a,b-1),Aux(a+1,b-1),Aux(a-1,b),Aux(a,b),Aux(a+1,b),Aux(a-1,b+1),Aux(a,b+1),Aux(a+1,b+1)];
%                     J = sort(J);
%                     Aux(a,b) = J(5);
%                 end
%             end
%         end    
%         
%         figure,imshow(Aux);
%         
%         Aux = Aux + Mascara;
%         
%         Img = Img + Aux;
%         
%         Img = histeq(Img);
%         
%         figure,imshow(Img);
%         
%         figure,imshow(Aux);
% 
%         borda externa

%         MascaraExterna=Mascara;
% 
%         for a=1:i    
%             for b=1:f
%               MascaraExterna(a,b) = 0;   
%               if (((a-LocalidadeDaPupila(1))*(a-LocalidadeDaPupila(1)))+((b-LocalidadeDaPupila(2))*(b-LocalidadeDaPupila(2))))+TamanhoIris >(TamanhoIris*TamanhoIris) && (((a-LocalidadeDaPupila(1))*(a-LocalidadeDaPupila(1)))+((b-LocalidadeDaPupila(2))*(b-LocalidadeDaPupila(2)))-TamanhoIris<(TamanhoIris*TamanhoIris))
%                 MascaraExterna(a,b) = 255;
%               end    
%             end
%         end
% 
%         % Preenchimento
% 
%         pontas=0;
%         for a=1:i
%             inicio = 0;
%             fim = 0;
%             for b=2:f-1
%                 if MascaraExterna(a,b)==0 && MascaraExterna(a,b+1)==255 && pontas<3
%                     pontas = pontas + 1;
%                     if pontas==1
%                         inicio = b;
%                     else
%                         fim = b;
%                     end
%                 end        
%             end
%             for b=2:f-1
%                 if MascaraExterna(a,b)==0 && MascaraExterna(a,b-1)==255 && b>=inicio && b<=fim
%                     MascaraExterna(a,b)=255;
%                 end
%             end
%             pontas = 0;
%         end
% 
%         %Negativo
% 
%         for a=2:i-1
%           for b=2:f-1
%              if MascaraExterna(a,b)==0
%                MascaraExterna(a,b)=256;
%              else 
%                MascaraExterna(a,b)=0;  
%              end
%           end
%         end
% figure,imshow(MascaraExterna);
% figure,imshow(Original+MascaraExterna+Mascara);  
%         Teste=prewitt;
%         for a=1:i    
%             for b=1:f
%                 if a == InicioH
%                     Teste(a,b)= 255;
%                 else
%                     if b == InicioV
%                         Teste(a,b)= 255; 
%                     else
%                       Teste(a,b)= prewitt(a,b);
%                     end
%                 end 
%             end
%         end
%         
%         MascaraExterna = CortarEmBaixo(MascaraExterna,i,f,LocalidadeDaPupila(1)+CorteBaixo);