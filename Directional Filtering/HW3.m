clear
clc
img=imread('HW3.jpg');
subplot(2,2,1)
imshow(img)
title('原图')


%二维傅里叶变换
%{
可实现fftshift的功能
[height width]=size(img);
[X Y]=meshgrid(1:width,1:height);
X=int64(X);
Y=int64(Y);
tempimg=int64(img).*(-1).^(X+Y);
Fs=fft2(double(tempimg));
%}
Fs=fftshift(fft2(double(img)));

%S为频谱图
S=255*mat2gray(abs(Fs));
subplot(2,2,2)
imshow(S)
title('频谱图')

%频域滤波器
%1的部分保留，0的部分被滤去
[height width]=size(S);
lvbo(1:height,1:width)=1;
for i=1:height/2
    for j=1:width/2
        tempX=j-width/2;
        tempY=height/2-i;
        
        %第二象限平面频域纵轴方向滤波,原图网格横线
        k1=10;
        k2=6;
        if(tempY>double(height/2/(width/k1)*-1)*tempX||tempY<double(height/2/k2/(width/2)*-1)*tempX)
            lvbo(i,j)=0;
        end
    end
end
%关于纵轴对称
lvbo(:,width/2+1:end)=lvbo(:,width/2:-1:1);
%关于横轴对称
lvbo(height/2+1:end,:)=lvbo(height/2:-1:1,:);

%频谱图乘以滤波器
S=S.*lvbo;
subplot(2,2,4)
imshow(S)
title('滤波后频谱图')
%傅里叶变换乘以滤波器
Fs=Fs.*lvbo;

%二维傅里叶反变换
ff=real(ifft2(ifftshift(Fs)));
newimg=uint8(ff);
subplot(2,2,3)
imshow(newimg)
title('滤波后图像')
imwrite(newimg,'newimg.bmp');