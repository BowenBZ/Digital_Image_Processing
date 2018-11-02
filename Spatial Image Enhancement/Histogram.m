%1读入图像
clear
clc
img=imread('hw2.jpg');
[m,n]=size(img);     %测量图像尺寸参数
GP=zeros(1,256);     %预创建存放灰度出现概率的向量
figure(1)
subplot(2,3,1)
imshow(img)
title('原图像')

%2画图像的直方图
for k=0:255
    GP(k+1)=length(find(img==k))/(m*n);  %计算每级灰度出现的概率，将其存入GP中相应位置
end
figure(1)
subplot(2,3,2)
bar(0:255,GP,'g')   %绘制GP的图像
xlim([0 255])
title('原图像直方图')
xlabel('灰度值')
ylabel('出现概率')

%3均衡化数据
MaxNum=255;          %=find(GP==max(GP));   %找到最大的灰度值
TotalNum=m*n;
for i=0:255
    list(i+1)=uint8(length(find(img<=i))*MaxNum/TotalNum);
end
for i=1:m
    for j=1:n
        img_JH(i,j)=list(img(i,j)+1);
    end
end
figure(1)
subplot(2,3,4)
imshow(img_JH)
title('均衡化图像')

%4均匀化之后的数据
for k=0:255
    JH(k+1)=length(find(img_JH==k))/(m*n); %计算每级灰度出现的概率，将其存入GP中相应位置
end
figure(1)
subplot(2,3,5)
bar(0:255,JH,'g')   %绘制的图像
xlim([0 255])
title('均衡化直方图')
xlabel('灰度值')
ylabel('出现概率')

%5累积分布函数
for k=0:255
    temp=0;
    for i=0:k
        temp=temp+JH(i+1);
    end
    LJ(k+1)=temp;
end
figure(1)
subplot(2,3,6)
bar(0:255,LJ,'g')
xlim([0 255])
ylim([0 1])
title('累积分布函数')

%6亮度增强
white(1:m,1:n)=255;
a=1.5;
img_light=uint8(uint8((1-a)*white)+a*img_JH);
figure(2)
subplot(1,2,1)
imshow(img_light)
title('亮度增强图像')
xlabel('a=1.5')

%7反转图像
for i=1:m
    for j=1:n
        img_FZ(i,j)=255-img_JH(i,j);
    end
end
figure(2)
subplot(1,2,2)
imshow(img_FZ)
title('反转图')