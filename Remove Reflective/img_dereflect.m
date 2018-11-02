%{
本程序功能为去反光，调用方式为newimg=img_dereflect(filename)

自42 张博文 2014011455
%}

%-------------------------
%主函数
%--------------------------
function newimg=img_dereflect(filename)
%读入图像
oldimg=imread(filename);
grayimg=rgb2gray(oldimg);
%取掩模 工件为0，背景为1
mask=getmask(grayimg,1,100);

%同态滤波取光照图
Fs=fftshift(fft2(log(double(grayimg))));
H=GuassianL(Fs,10);
newFs=Fs.*H;
lightimg=real(ifft2(ifftshift(newFs)));

%原图减去光照图
lightimg=extend(log(double(0.7*grayimg)),lightimg);
imgdlight=log(double(grayimg))-double(lightimg);
imgdlight=exp(imgdlight);
imgextend=uint8(extend(grayimg,imgdlight));

%为反光区赋合适的值
newgray=adjustcolor(grayimg,imgextend,mask);

%由灰度图计算最终RGB图
newimg=getRGB(oldimg,newgray);

%RGB图取掩模
newimg(:,:,1)=newimg(:,:,1).*(1-uint8(mask(:,:)));
newimg(:,:,2)=newimg(:,:,2).*(1-uint8(mask(:,:)));
newimg(:,:,3)=newimg(:,:,3).*(1-uint8(mask(:,:)));
end

%%
%-------------------------
%其它函数
%--------------------------
%1高斯低通滤波器
function H=GuassianL(img,D0)
[height width]=size(img);
[X Y]=meshgrid(1:width,1:height);
D=(Y-double(height)/2).^2+(X-double(width)/2).^2;
H=exp(-1*D/(2*D0^2));
end

%2取工件的掩模
function ym=getmask(img,low,high)
%背景为1白 工件为0黑
%先模糊再取掩模
Fs=fftshift(fft2(img));
H=GuassianL(Fs,40);
newFs=Fs.*H;
newimg=real(ifft2(ifftshift(newFs)));
%形成掩模
square=divide(newimg,low,high);
square=fillblack(square);
ym=square;
end

%2.1阈值分割
function H=divide(img,a,b)
%背景为1白 工件为0黑
[height width]=size(img);
k1=uint8(ceil(a-double(img)));
k2=uint8(ceil(double(img)-b));
H=k1|k2;
end

%2.2填补掩模中间的白色部分
function ymnew=fillblack(ymold)
%去掉四角,把四角变白
ymnew=ymold;
[height width]=size(ymold);
ymnew(1:height,1:int64(width/10))=1;
ymnew(1:height,int64(9*width/10):width)=1;

allblack=find(ymnew==0);
[x y]=ind2sub(size(ymold),allblack);
minx=min(x);
maxx=max(x);
miny=min(y);
maxy=max(y);
middley=(maxy+miny)/2;

for i=minx+1:maxx
    for j=miny+1:middley
        if(ymnew(i,j)==1)
            if(ymnew(i-1,j)==0&&ymnew(i,j-1)==0)
                ymnew(i,j)=0;
            end
        end
    end
end

for i=minx+1:maxx
    for j=maxy-1:-1:middley
        if(ymnew(i,j)==1)
            if(ymnew(i-1,j)==0&&ymnew(i,j+1)==0)
                ymnew(i,j)=0;
            end
        end
    end
end
end

%3调整颜色
function newimg=adjustcolor(oldgray,newgray,mask)
%背景区域RGB变为255
[height width]=size(oldgray);

oldgraymask=oldgray.*(uint8(244)*uint8(mask)+uint8(1));
%取工件颜色
clr=0;
num=0;
for k=10:100
    temp=length(find(oldgraymask==k));  %计算每级灰度出现的个数
    num=num+temp;
    clr=clr+k*temp;
end
clr=double(clr)/num;
noisy=rand(height,width);

%取轮廓区域
contour=getcontour(oldgray);
%取光亮集中区
imgsquare=newgray.*(uint8(244)*uint8(mask)+uint8(1));
highlight=gethighlight(imgsquare);
%计算各部分变化
vary=30;
colorchange=uint8(ceil(abs(double(oldgray)-double(newgray))-vary));
%除强烈反光区外，将其余部分以灰度图赋值
%强光区域为clr+noisy
k1=(1-mask)&(colorchange)&(1-contour)&(highlight);
newimg=double(k1).*(clr+(double(noisy)-0.5)*10)+double(~k1).*double(oldgray);
end

%3.1取反光集中部分
function highlight=gethighlight(grayimg)
%1为反光强烈区域
%模糊化，使离散的光照区被滤掉，留下集中的反光区
Fs=fftshift(fft2(grayimg));
H=GuassianL(Fs,10);
newFs=Fs.*H;
imgsquare=uint8(real(ifft2(ifftshift(newFs))));
highlight=divide(imgsquare,30,225);     %60
end

%3.2取工件轮廓
function contour=getcontour(grayimg)
%1的区域为轮廓
%高通滤波
Fs=fftshift(fft2(grayimg));
H=1-GuassianL(Fs,80);
newFs=Fs.*H;
lunkuo=real(ifft2(ifftshift(newFs)));
lunkuo=uint8(extend(grayimg,lunkuo));

%和原来相比看那些部分变化小，变化小的即为轮廓
vary=40;
[height width]=size(grayimg);
H=uint8(ceil(vary-abs(double(lunkuo)-double(grayimg))));
contour=H&1;
end

%4变化取值范围
function newimg=extend(standard,oldimg)
maxold=double(max(max(oldimg)));
minold=double(min(min(oldimg)));
maxstd=double(max(max(standard)));
minstd=double(min(min(standard)));
newimg=(double(oldimg)-minold)*(maxstd-minstd)/(maxold-minold)+minstd;
end

%5获取最终的RGB图
function newimg=getRGB(oldimg,newgray)
grayimg=rgb2gray(oldimg);

%灰度图直接转回RGB
newimg1=gray2rgb(newgray,oldimg);

%通过hsv通道转回
hsvimg=rgb2hsv(oldimg);
newhsv=extend(hsvimg(:,:,3),newgray);
hsvimg(:,:,3)=newhsv;
newimg2=hsv2rgb(hsvimg);

%两种取平均
newimg3=uint8((double(newimg1)+double(newimg2))/2);
newimg=newimg3;
end

%5.1灰度图转RGB
function newrgb=gray2rgb(newgray,oldrgb)
oldgray=rgb2gray(oldrgb);
[height width]=size(newgray);
k=double(newgray)./double(oldgray);
newrgb(:,:,1)=uint8(double(oldrgb(:,:,1)).*k);
newrgb(:,:,2)=uint8(double(oldrgb(:,:,2)).*k);
newrgb(:,:,3)=uint8(double(oldrgb(:,:,3)).*k);
end