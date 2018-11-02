clear
clc
oldimg=imread('hw.jpg');

%画图像的直方图
[height width]=size(oldimg);
for k=0:255
    GP(k+1)=length(find(oldimg==k));        %计算每级灰度出现的个数，将其存入GP中相应位置
end
figure;bar(0:255,GP,'g');   %绘制GP的图像
xlim([0 255]);

%中值法-threshold1
At=0;
t=0;
vary=0;
while(t==0||t>=256)
    while(abs(At-height*width/2)>vary&&t<=255)
        At=At+GP(t+1);
        t=t+1;
    end
    if(t>=256)
        t=0;
        At=0;
    end
    vary=vary+1;
end
threshold1=t-1;
newimg1=oldimg;
newimg1(newimg1<=threshold1)=0;
newimg1(newimg1>0)=1;
newimg1=double(newimg1);
vary-1
threshold1

%动量矩不变-threshold2
A=sum(GP);
i=[0:1:255];B=sum(GP.*i);
x1=0;x2=255;
t=0;
At=0;
vary=0;
while(t==0||t>=256)
    while(abs(At-((A/2*(sqrt(x2*x2-4*x1)+x2)-B)/sqrt(x2*x2-4*x1)))>vary&&t<=255)
        At=At+GP(t+1);
        t=t+1;
    end
    if(t>=256)
        t=0;
        At=0;
    end
    vary=vary+1;
end
threshold2=t-1;
newimg2=oldimg;
newimg2(newimg2<=threshold2)=0;
newimg2(newimg2>0)=1;
newimg2=double(newimg2);
vary-1
threshold2

%平均值平均-threshold3
t=127;
newt=0;
while(t~=newt)
    t=newt;
    At=sum(GP(1:t+1));
    Bt=sum(GP(1:t+1).*i(1:t+1));
    ub=Bt/At;uf=(B-Bt)/(A-At);
    newt=uint8((ub+uf)/2) ;
end
threshold3=t;
newimg3=oldimg;
newimg3(newimg3<=threshold3)=0;
newimg3(newimg3>0)=1;
newimg3=double(newimg3);
threshold3

imwrite(newimg1,'new1.jpg');
imwrite(newimg2,'new2.jpg');
imwrite(newimg3,'new3.jpg');
figure;
subplot(221);imshow(newimg1);title('中值法');
subplot(222);imshow(newimg2);title('动量矩不变');
subplot(223);imshow(newimg3);title('平均值平均');