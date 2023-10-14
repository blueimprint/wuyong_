clear all;
close all;
clc
% Physcal parameters:

lamda      = 1064*10^(-9);          % wavelength
k0         = 2*pi/lamda;           % wavevector in vaccum
n0         = 1;                 % refractive index in substrat
v          = 0;               %???(V)
E0         = v/5e-3;               % + self_focusing 1000v/5mm=20e4
r33        = 1340*10^(-12);        % oe effcient     1340
seta       = -k0*n0^3*r33*E0/2;    % indices


Nx        = 1920;                        % Num of points in x-axis   / pixel 
Lx        = 9.6*1e-3;                     % X - computer window        0.37*1e-3
dx=Lx/Nx;
x         = linspace(-Lx/2,Lx/2,Nx)'; %%% difine the 1D matrix of x
kx        = [0:Nx/2-1  -Nx/2:-1]'*2*pi/Lx; %%%% define Fourier space axis kx
Ny        = 1080;  
Ly        = Ny*dx;  
y         = linspace(-Ly/2,Ly/2,Ny)';
ky        = [0:Ny/2-1  -Ny/2:-1]'*2*pi/Ly;
[X,Y]     = meshgrid(x,y);
[ Kx,Ky]   = meshgrid(kx,ky);
lz        = 300* 10^(-3);                 % Z - sample length  control the propagation length

Nz        = 300;                         % points in z-axis
z         = linspace(0,lz,Nz);
dz        = z(2)-z(1);
Ap        = 1;

r0=1e-4;
r=sqrt(X.^2+Y.^2)/r0;
qr=exp(-1e-4.*r.^2).* (sqrt( X.^2+Y.^2)<1.1e-3);
%   k= find(r>=1.1e-3);
%   qr(k)=0;
r=sqrt( X.^ 2+Y.^2)/r0.* (sqrt( X.^2+Y.^2)<1.1e-3);
  
 B=Pearcey(-r,0).* qr;
%B=Pearcey(-r/0.1e-3,0).*qr;
%B=airy(2-r/0.05).*exp(0.1*(2-r)/0.05);
I0=(abs(B)).^2;%%%%%Input intensity of the beam

uA=B;
figure(1)
I0=(abs(uA)).^2;
imagesc(x*1e3,y*1e3,I0);
xlabel('x(mm)'),ylabel('y(mm)');
title('input of Pearcey  beam');
Input_matrix2D =I0;
minInput_matrix2D = min(min(Input_matrix2D));
Input_matrix2D = Input_matrix2D + abs(minInput_matrix2D);
maxInput_matrix2D = max(max(Input_matrix2D));
level = 255;
Input_matrix2D = Input_matrix2D/maxInput_matrix2D*level;%*maxInput_matrix2D/max(max(Ipf)); %normalized!!!!
map = colormap(hot(level)); 
axis image;
imwrite(Input_matrix2D,map,['CPB r0=',num2str(r0),'.png'],'png');
%hologram
figure(2)
% c0=exp(-(X./0.0003).^2-(Y./0.0003).^2);
% Iphase=(abs((ifft2(abs(c0).*exp(i.*phase))))).^2;
% Iphasek=(abs(c0)).^2;
% imagesc(Iphase);
for nx=3*10^4:10^3:3*10^4
% nx=k0;
ny=0;
A1=max(max(abs(uA)));
uA1=uA+A1*exp(1i*(nx*pi*X+ny*pi*Y));
% Iphase=(abs((ifft2(abs(c0).*exp(i.*phase))))).^2;
Iphasek=(abs(uA1)).^2;
imagesc(x*1e3,y*1e3,Iphasek);
xlabel('x(\mum)'),ylabel('y(\mum)');
title('input of CPB');
Input_matrix2D =Iphasek;
minInput_matrix2D = min(min(Input_matrix2D));
Input_matrix2D = Input_matrix2D + abs(minInput_matrix2D);
maxInput_matrix2D = max(max(Input_matrix2D));
level = 255;
Input_matrix2D = Input_matrix2D/maxInput_matrix2D*level;%*maxInput_matrix2D/max(max(Ipf)); %normalized!!!!
map = colormap(gray(level)); 
axis image;
imwrite(Input_matrix2D,map,['Hologram-CPB_117 r0=',num2str(r0),' nx=',num2str(nx),'.png'],'png');
end

function Pe=Pearcey(x,y)
%Pe = integral(@(s) exp(1i*pi/8)*exp(1i*((s.*exp(1i*pi/8)).^4 + (s.*exp(1i*pi/8)).*y + (s.*exp(1i*pi/8)).^2.*x)),-Inf, Inf, 'ArrayValued',1);
format long
x=x*exp(-1i*pi*0.25);
y=y*exp(1i*pi*0.125);
Pe = integral(@(s) exp((-s.^4 + i.*s.*y - s.^2.*x+1i*pi*0.125)), -Inf, Inf, 'ArrayValued',1);
%Pe = integral(@(s) exp(1i*pi/8)*exp(1i*((s.*exp(1i*pi/8)).^4 + (s.*exp(1i*pi/8)).*y + (s.*exp(1i*pi/8)).^2.*x)),-Inf, Inf, 'ArrayValued',1);
warning('off');

end

%%%%%%%%%%%%%%%%%%%% beams propagation methods BPM method%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%
% v=exp(i*(-0.5*(wx.^2+wy.^2))*dz/k0/n0);
%         w=(v); 
% for j = 1:Nz 
%     
%    
%        
%         Bm=fft2(uA);
%         Bm=Bm.*w;
%         Bm=ifft2(Bm);
%         
%         %+ shows decelerate G
%         % - shows accelerate G = -0.75
%         % 0 shows free space_okay
% %         G = 0;
% %         Dn=1.4*(G*x+G*y);   
% %         p=exp(i*k0*Dn*dz);
% %         B=B.*p;
%         
%         % nonlinearity
%         NO=i.*seta./(1+1*abs(uA).^2);
%         expNO = exp(dz.*NO);
%         uA = Bm.*expNO;
%    %uA= um1.* expNO1 ;       
%    Ai2(:,j)= uA(:,Nx/2);
%    ev3(:,:,j)=abs(uA).^2;
% end


%%%%%% find some special points%%%%%
% ev=abs(Ai2).^2; %%% sideview of propagation of beams
% [ymax,yd]=max(ev(:,1));   %%%%  find peak intensity input position
% [xmax,xf]=max(ev(Nx/2,:));    %%%%% find z position of  focusing point
% Ipf=ev3(:,:,xf);  %%%% select a part to plot
% %Ipfy=Ipf(:,100); %  intensity distribution at center along x axis
% figure(1)
% imagesc(ev),title('Input in real space');
% colormap jet;
% axis image;
% 
% figure(2)
% imagesc(x*1e3,y*1e3,I0),title('Input in real space');
% colormap jet;
% axis image;
% 
% figure(3)
% imagesc(x*1e3,y*1e3,Ipf),title('output in focal point');
% colormap jet;
% axis image;

% function Pe=Pearcey(x,y) 
% %     y=y;
% %     x=x;
% %   x=x*exp(-1i*pi*0.25);
%  %  y=y*exp(1i*pi*0.125);
% %  fun =@(t) exp(-t.^4 + 1i.*y.*t - x.*t.^2 + 1i*pi*0.125); 
% % %  syms t
% % % fun=exp(-t.^4 + 1i.*y.*t - x.*t.^2 + 1i*pi*0.125); 
% % % Pe=int(fun,t,[-1000, 1000],'IgnoreSpecialCases',true);
% % % 
% %  Pe=integral(fun,-Inf, Inf, 'ArrayValued',1);
% %  Pe = integral(@(s) exp((-s.^4 + i.*s.*y - s.^2.*x+1i*pi*0.125)), -Inf, Inf, 'ArrayValued',1);
% % Pe = integral(@(s) 2.*exp(1i*pi/8).*exp(1i*(s.^4 + s.*y +s.^2.*x)), -Inf, Inf, 'ArrayValued',1);
% %  Pe = integral(@(s) exp(1i*pi/8)*exp(1i*((s.*exp(1i*pi/8)).^4 + (s.*exp(1i*pi/8)).*y + (s.*exp(1i*pi/8)).^2.*x)),-Inf, Inf, 'ArrayValued',1);
% %  
% % pe1=integral(@(s) cos(1*(s.^4 + s.*y +s.^2.*x)), -Inf, Inf, 'ArrayValued',1);
% % pe2=integral(@(s) sin(1*(s.^4 + s.*y +s.^2.*x)), -Inf, Inf, 'ArrayValued',1);
% % Pe=pe1+1i*pe2;
% % Pe = integral(@(s) (exp(y.*s.^2.*exp(3*1i*pi/4)-s.^4).*cosh(x.*s.*exp(5*1i*pi/8))), 0, Inf);
% % format long
% %   x=x*exp(-1i*pi*0.25);
% %   y=y*exp(1i*pi*0.125);
% % Pe = integral(@(s) exp((-s.^4 + i.*s.*y - s.^2.*x+1i*pi*0.125)), -Inf, Inf, 'ArrayValued',1);
% %  Pe = integral(@(s) exp(1i*pi/8)*exp(1i*((s.*exp(1i*pi/8)).^4 + (s.*exp(1i*pi/8)).*y + (s.*exp(1i*pi/8)).^2.*x)),-Inf, Inf, 'ArrayValued',1);
% % warning('off');
% % 
% % end
