clear
clc
oldimg=imread('红眼.jpg');
[height width m]=size(oldimg);

%确定面部
a=find(oldimg(:,:,1)<100);
[mina,minb]=ind2sub(size(oldimg(:,:,1)),min(a));
[maxa,maxb]=ind2sub(size(oldimg(:,:,1)),max(a));
faceimg(:,:,1:3)=oldimg(mina:maxa,minb:maxb,1:3);
%根据阈值将红眼区变灰
hsiimg=rgb2hsi(faceimg);
Hlow=-1*pi/3;
Hhigh=pi/3;
S=0.3;
[height1 width1 m]=size(hsiimg);
for i=1:height1
    for j=1:width1
        if((hsiimg(i,j,1)>Hlow)&(hsiimg(i,j,1)<Hhigh)&(hsiimg(i,j,2)>S))
            hsiimg(i,j,2)=0;
            hsiimg(i,j,1)=0;
        end
    end
end
%HSI变回RGB
newface=hsi2rgb(hsiimg);
newimg=im2double(oldimg);
newimg(mina:maxa,minb:maxb,1:3)=newface(:,:,1:3);
figure
imshow(newimg);
imwrite(newimg,'去红眼.jpg');