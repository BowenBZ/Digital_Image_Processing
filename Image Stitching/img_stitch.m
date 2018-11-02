%{
图像拼接程序
1.运行直接Run或者输入img_stitch;
2.程序只能拼接三张图像，且默认以中间图像为基准
3.如果需要看拼接其它三张图像的效果，需要在主函数的imread函数中输入相应的文件名。
  还需要在cpselect处使用不含预置点的那行代码

自42 张博文 2014011455
%}

%----------------------------------------------------------------------
%主函数
%----------------------------------------------------------------------
function [imgWithBlack imgWithoutBlack]=img_stitch()
%读入图像
clear
clc
img1=imread('1.jpg');
img2=imread('2.jpg');
img3=imread('3.jpg');

%在img1和img2上取5对控制点
Point1preset=[2867.75000000000,382.500000000000;2413.88030326237,1346.48131413693;3092.75000000000,1360.75000000000;2102.50000000000,842.500000000000;3197.25000000000,832.750000000000];
Point2preset=[817.156224868839,362.033029525524;297,1240.25000000000;949.250000000000,1270.62500000000;34.7500000000000,742.250000000000;1075.08538826773,799.565094195129];
[points1,points2]=cpselect(img1,img2,Point1preset,Point2preset,'wait',true);
%[points1,points2]=cpselect(img1,img2,'wait',true);
%根据控制点对img1进行变换
[newimg1 left up1 bottom1]=myTransform1(points1,points2,img1);

%在img2,img3上取5对控制点
Point3preset=[1003.75000000000,1003.25000000000;680.625000000000,1450.62500000000;685.625000000000,672.187500000000;1188.75000000000,1212.75000000000;991.149561521082,1524.86349710872];
Point2preset=[2858.75000000000,738.250000000000;2459.87325777301,1269.99303109205;2419.50000000000,362.250000000000;3095.18750000000,982.375000000000;2887.32694443381,1356.49494504653];
[points2,points3]=cpselect(img2,img3,Point2preset,Point3preset,'wait',true);
%[points2,points3]=cpselect(img2,img3,'wait',true);
%根据控制点对img3进行变换
[newimg3 right up2 bottom2]=myTransform3(points3,points2,img3);

%将三张图拼接起来
newimg=combine3img(newimg1,img2,newimg3);
imgWithBlack=newimg;
figure
imshow(newimg)
imwrite(newimg,'imgWithBlack.bmp');

%裁剪图片
newimg_crop=crop(newimg,left,right,max(up1,up2),min(bottom1,bottom2));
imgWithoutBlack=newimg_crop;
figure
imshow(newimg_crop)
imwrite(newimg_crop,'imgWithoutBlack.bmp');
end


%%
%----------------------------------------------------------------------
%其它函数
%----------------------------------------------------------------------
%对img1(左图)作仿射变换
function [img_new left up bottom]=myTransform1(points1,points2,img1)
[height width m]=size(img1);
points2(:,1)=points2(:,1)+width;

%求img1到img2的仿射变换的矩阵
Tni=point2matrix(points2,points1);
%求正变换矩阵，算一些边界
[X Y]=meshgrid(1:width,1:height);
tempX=X*Tni(1,1)+Y*Tni(1,2)+Tni(1,3);
tempY=X*Tni(2,1)+Y*Tni(2,2)+Tni(2,3);
%找到img1右侧靠里的点,应当是(1,width)和(height,width)中映射之一
min_x=int64(min(tempX(1,width),tempX(height,width)));
min_x=int64(min(min_x,width+width/7));
%找到img1最左侧的点，应当是(1,1)和(height,1)中映射之一
left=int64(max(tempX(1,1),tempX(height,1)));
%找到img1最上面的点，应当是(1,1)和(1,width)中映射之一
up=int64(max(tempY(1,1),tempY(1,width)));
up=int64(max(up,1));
%找到img1最下面的点，应当是(height,1)和(height,width)中映射之一
bottom=int64(min(tempY(height,1),tempY(height,width)));

%求img2到img1的仿射变换的矩阵
T=point2matrix(points1,points2);
%求img2到img1映射的坐标列表
[X_img2 Y_img2]=meshgrid(1:min_x,1:height);
new2old_X=double(X_img2)*T(1,1)+double(Y_img2)*T(1,2)+T(1,3);
new2old_Y=double(X_img2)*T(2,1)+double(Y_img2)*T(2,2)+T(2,3);
[X_img2 Y_img2]=meshgrid(1:width,1:height);
%使用插值函数算出各点
img_new(:,:,1)=interp2(X_img2,Y_img2,double(img1(:,:,1)),new2old_X,new2old_Y);
img_new(:,:,2)=interp2(X_img2,Y_img2,double(img1(:,:,2)),new2old_X,new2old_Y);
img_new(:,:,3)=interp2(X_img2,Y_img2,double(img1(:,:,3)),new2old_X,new2old_Y);
img_new=uint8(img_new);
end

%对img3(右图)作仿射变换
function [img_new right up bottom]=myTransform3(points3,points2,img3)
[height width m]=size(img3);
points2(:,1)=points2(:,1)+width;
%求img3到img2的仿射变换的矩阵
Tni=point2matrix(points2,points3);

%求正变换矩阵，算一些边界
[X Y]=meshgrid(1:width,1:height);
tempX=X*Tni(1,1)+Y*Tni(1,2)+Tni(1,3);
tempY=X*Tni(2,1)+Y*Tni(2,2)+Tni(2,3);
%找到img3右侧靠里的点,应当是(1,1)和(height,1)中映射之一
max_x=int64(max(tempX(1,1),tempX(height,1)));
max_x=int64(max(max_x,width+width*6/7));
%找到img3右侧的点，应当是(1,width)和(height,width)中映射之一
right=int64(min(tempX(1,width),tempX(height,width)));
%找到img3最上面的点，应当是(1,1)和(1,width)中映射之一
up=int64(max(tempY(1,1),tempY(1,width)));
up=int64(max(up,1));
%找到img1最下面的点，应当是(height,1)和(height,width)中映射之一
bottom=int64(min(tempY(height,1),tempY(height,width)));

%求img2到img1的仿射变换的矩阵
T=point2matrix(points3,points2);
%求img2到img1映射的坐标列表
[X_img3 Y_img3]=meshgrid(max_x:3*width,1:height);
new2old_X=double(X_img3)*T(1,1)+double(Y_img3)*T(1,2)+T(1,3);
new2old_Y=double(X_img3)*T(2,1)+double(Y_img3)*T(2,2)+T(2,3);
[X_img3 Y_img3]=meshgrid(1:width,1:height);
%使用插值函数算出各点
img_new(:,:,1)=interp2(X_img3,Y_img3,double(img3(:,:,1)),new2old_X,new2old_Y);
img_new(:,:,2)=interp2(X_img3,Y_img3,double(img3(:,:,2)),new2old_X,new2old_Y);
img_new(:,:,3)=interp2(X_img3,Y_img3,double(img3(:,:,3)),new2old_X,new2old_Y);
img_new=uint8(img_new);
end

%根据控制点求仿射变换矩阵
function T=point2matrix(point1,point2)
%求point2到point1的映射
%point1为原图点，point2为新图点
length=size(point1,1);
point1=point1';
point1(3,1:length)=1;
point2=point2';
point2(3,1:length)=1;
T=point1/point2;     %point1*point2^-1
end

%拼接已经仿射变换之后的图像
function newimg=combine3img(img1,img2,img3)
%img1占1：width+1000，img3占2*width-1000:3*width
[height1 width1 m]=size(img1);
[height2 width2 m]=size(img2);
[height3 width3 m]=size(img3);


newimg(:,1:width2,:)=img1(:,1:width2,:);
newimg(:,2*width2+1:3*width2,:)=img3(:,end-width2+1:end,:);

pixelNum1=width1-width2;
temp=linspace(0,1,pixelNum1);
tempZeng=meshgrid(temp,1:height2,1:3);
temp=linspace(1,0,pixelNum1);
tempJian=meshgrid(temp,1:height2,1:3);
newimg(:,width2+1:width2+pixelNum1,:)=uint8(double(img2(:,1:pixelNum1,:)).*tempZeng+double(img1(:,width2+1:width2+pixelNum1,:)).*tempJian);

pixelNum3=width3-width2;
temp=linspace(0,1,pixelNum3);
tempZeng=meshgrid(temp,1:height2,1:3);
temp=linspace(1,0,pixelNum3);
tempJian=meshgrid(temp,1:height2,1:3);
newimg(:,2*width2-pixelNum3+1:2*width2,:)=uint8(double(img3(:,1:pixelNum3,:)).*tempZeng+double(img2(:,width2-pixelNum3+1:width2,:)).*tempJian);

newimg(:,width2+pixelNum1+1:2*width2-pixelNum3,:)=img2(:,pixelNum1+1:width2-pixelNum3,:);

end

%裁剪黑边
function newimg=crop(img,left,right,up,bottom)
[height width m]=size(img);
img(:,right:end,:)=[];
img(:,1:left,:)=[];
img(bottom:end,:,:)=[];
img(1:up,:,:)=[];
newimg=img;
end