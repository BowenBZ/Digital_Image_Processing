%{
此脚本用于测试图片集
%}
clear
clc
title1='old/fog';
title2='new/fog';
form='.jpg';
type1='_His.jpg';type2='_Dark.jpg';type3='_Reti.jpg';
for i=0:8
    oldimg=imread([title1 num2str(i) form]);
    [newimg1 newimg2 newimg3]=img_dfog(oldimg);
    figure;
    subplot(221);imshow(oldimg);title('原图');
    subplot(222);imshow(newimg1);title('直方图均衡化');
    subplot(223);imshow(newimg2);title('暗通道');
    subplot(224);imshow(newimg3);title('Retinex理论');
    
    imwrite(newimg1,[title2 num2str(i) type1]);
    imwrite(newimg2,[title2 num2str(i) type2]);
    imwrite(newimg3,[title2 num2str(i) type3]);
end


