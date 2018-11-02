%{
本程序功能为HDR

自42 张博文 2014011455
%}

%-------------------------
%主函数
%--------------------------
function HDRmain()
clear
clc
%输入六幅图像
for i=0:5
    oldimg(:,:,:,i+1)=imread([num2str(i),'.jpg']);
end

newimg(:,:,1)=grayHDR(oldimg(:,:,1,:),0.1);
newimg(:,:,2)=grayHDR(oldimg(:,:,2,:),0.1);
newimg(:,:,3)=grayHDR(oldimg(:,:,3,:),0.1);

newimg2(:,:,1)=grayHDR(oldimg(:,:,1,:),1000);
newimg2(:,:,2)=grayHDR(oldimg(:,:,2,:),1000);
newimg2(:,:,3)=grayHDR(oldimg(:,:,3,:),1000);

hisimg(:,:,1)=adapthisteq(newimg(:,:,1));
hisimg(:,:,2)=adapthisteq(newimg(:,:,2));
hisimg(:,:,3)=adapthisteq(newimg(:,:,3));

figure;
subplot(221);imshow(oldimg(:,:,:,1));title('最小曝光时间');
subplot(222);imshow(oldimg(:,:,:,6));title('最大曝光时间');
subplot(223);imshow(newimg);title('HDR合成 lamada=0.1');
subplot(224);imshow(newimg2);title('HDR合成 lamada=1000');
figure;
subplot(121);imshow(newimg);title('普通处理');
subplot(122);imshow(hisimg);title('直方图均衡化');

imwrite(newimg,'HDR_0.1.jpg');
imwrite(newimg2,'HDR_1000.jpg');
imwrite(hisimg,'HDR均衡化.jpg');
end
%%
%-------------------------
%其它函数
%--------------------------
function newimg=grayHDR(oldimg,lamada)
%输入六幅图像 oldimg(:,:,1:6)
%计算g(z)
%图像采样
selectNum=20;
selectHeight=int64(linspace(1,size(oldimg,1),selectNum));
selectWidth=int64(linspace(1,size(oldimg,2),selectNum));
for i=1:6
    tempimg=oldimg(selectHeight(:),selectWidth(:),i);
    selectimg(:,i)=tempimg(:);
end
detaT=linspace(0.00625,0.01,6);
detaT=log(detaT);
for i=0:255
    if(i<=(255)/2)
        w(i+1)=i;
    else
        w(i+1)=255-i;
    end
end
[g,lE]=gsolve(selectimg,detaT,lamada,w);
%a=[0:1:255];
%figure;plot(g,a);
%根据g(z)恢复图像
newimg=zeros(size(oldimg,1),size(oldimg,2));
sum=zeros(size(oldimg,1),size(oldimg,2));
for k=1:6
    newimg(:,:)=newimg(:,:)+w(oldimg(:,:,k)+1).*(g(oldimg(:,:,k)+1)-detaT(k));
    sum=sum+w(oldimg(:,:,k)+1);
end
newimg=newimg./sum;
newimg=exp(newimg)/max(max(exp(newimg)));
end

function [g,lE]=gsolve(Z,B,l,w)
n = 256;
A = zeros(size(Z,1)*size(Z,2)+n+1,n+size(Z,1));
b = zeros(size(A,1),1);
%% Include the data?fitting equations
k = 1;
for i=1:size(Z,1)
    for j=1:size(Z,2) 
        wij = w(Z(i,j)+1);
        A(k,Z(i,j)+1) = wij; 
        A(k,n+i) = -wij; 
        b(k,1) = wij * B(j);
        k=k+1;
    end
end
%% Fix the curve by setting its middle value to 0
A(k,129) = 1;
k=k+1;
%% Include the smoothness equations
for i=1:n-2
    A(k,i)=l*w(i+1); 
    A(k,i+1)=-2*l*w(i+1); 
    A(k,i+2)=l*w(i+1);
    k=k+1;
end
%% Solve the system using SVD
x = A\b;
g = x(1:n);
lE = x(n+1:size(x,1));
end