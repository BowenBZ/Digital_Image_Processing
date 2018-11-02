clear;
clc;
oldimg=imread('figure.jpg');

%去高斯噪声
imgdguass=wiener2(oldimg,[10 10]);
%去渐变噪声
[height width]=size(oldimg);
Hsize=min(height,width);
Hfre=100;
HGrad=fspecial('Gaussian',[Hsize Hsize],Hfre);
gradnoise=imfilter(imgdguass,HGrad);
%去除渐变噪声
imgdgrad=imgdguass-0.5*gradnoise;
%阈值分割
midgray=59;
thresimg=double(imgdgrad);
thresimg(thresimg<midgray)=0;
thresimg(thresimg>0)=1;
thresimg=1-thresimg;
%腐蚀阈值分割图
[height width]=size(oldimg);
signimg=thresimg;
se=strel('disk',4);
signimg(:,1:width/2)=imerode(thresimg(:,1:width/2),se);
%膨胀构造掩模
se=strel('disk',4);
signimg(1:height/2,1:width/2)=imdilate(signimg(1:height/2,1:width/2),se);
se=strel('disk',1);
signimg=imdilate(signimg,se);
%构建新图象
newimg=uint8(signimg.*double(imgdguass)+(1-signimg)*1.5*sum(sum(gradnoise))/(Hsize*Hsize));

figure
subplot(221);imshow(oldimg);title('原图');
subplot(222);imshow(imgdguass);title('去高斯噪声');
subplot(223);imshow(gradnoise);title('渐变噪声');
subplot(224);imshow(imgdgrad);title('去渐变噪声');

figure
subplot(221);imshow(thresimg);title('阈值分割');
subplot(222);imshow(signimg);title('腐蚀+膨胀');
subplot(223);imshow(oldimg);title('原图');
subplot(224);imshow(newimg);title('新图');
imwrite(newimg,'new.jpg');

%求取连通区个数
se=strel('square',3);
area=signimg*0;
point=find(signimg==1&area==0);
num=0;
while(~isempty(point))
    [pointx pointy]=ind2sub(size(signimg),min(point));
    area(pointx,pointy)=1;
    newarea=double(imdilate(area,se)&signimg);
    while(~isequal(area,newarea))
        area=newarea;
        newarea=imdilate(area,se)&signimg;
    end
    point=find(signimg==1&area==0);
    num=num+1;
    %figure;imshow(area);
end
num
