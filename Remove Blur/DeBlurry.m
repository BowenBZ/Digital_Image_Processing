clear
clc
img=imread('image.jpg');
subplot(2,2,1)
imshow(img)
title('原图')

%画图像的直方图
grayimg=rgb2gray(img);
[height width]=size(grayimg);     %测量图像尺寸参数
for k=0:255
    GP(k+1)=length(find(grayimg==k))/(height*width);  %计算每级灰度出现的概率，将其存入GP中相应位置
end
subplot(2,2,2)
bar(0:255,GP,'g')   %绘制GP的图像
xlim([0 255])
title('原图像直方图')
xlabel('灰度值')
ylabel('出现概率')

%求图象傅里叶变换
Fs(:,:,1:3)=fftshift(fft2(double(img(:,:,1:3))));

%逆高斯滤波
%{
正确参数
k=0.0025 a=0.1
k=0.001  a=0.1,0.05
k=0.002 a=0.05
%}
k=0.0025;
a=0.07;
[height width m]=size(img);
for i=1:height     
    for j=1:width                 
        HG(i,j)=exp(-k*((i-double(height/2)+0.5)^2+(j-double(width/2)+0.5)^2)^(5/6));  
        if(HG(i,j)<=a)
            HG(i,j)=10^10;
        end
    end
end

%逆Butterworth滤波 
%{
D0=22 a=0.1
%}
D0=15;
a=0.1;
[height width m]=size(img);
for i=1:height     
    for j=1:width                 
        D=sqrt((i-double(height/2)+0.5)^2+(j-double(width/2)+0.5)^2);       
        HB(i,j)=1/(1+(sqrt(2)-1)*(D/D0)^2);
        if(HB(i,j)<=a)
            HB(i,j)=10^10;
        end
    end
end

%原图加模糊
newFsG(:,:,1)=Fs(:,:,1)./HG;
newFsG(:,:,2)=Fs(:,:,2)./HG;
newFsG(:,:,3)=Fs(:,:,3)./HG;

newFsB(:,:,1)=Fs(:,:,1)./HB;
newFsB(:,:,2)=Fs(:,:,2)./HB;
newFsB(:,:,3)=Fs(:,:,3)./HB;

%反傅里叶变换
ffG(:,:,1:3)=real(ifft2(ifftshift(newFsG(:,:,1:3))));
ffB(:,:,1:3)=real(ifft2(ifftshift(newFsB(:,:,1:3))));

%显示图片
newimgG=uint8(ffG);
subplot(2,2,3)
imshow(newimgG)
title('逆Gaussian滤波')
imwrite(newimgG,'Gaussian.jpg');

newimgB=uint8(ffB);
subplot(2,2,4)
imshow(newimgB)
title('逆Butterworth滤波')
imwrite(newimgB,'Butterworth.jpg');