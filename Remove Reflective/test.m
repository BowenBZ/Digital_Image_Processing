%{
此脚本用于测试图片集
%}
clear
clc
title1='testimg/img';
title2='newimg/img';
form='.jpg';
for i=1:10
    filename=[title1 num2str(i) form];
    newimg=img_dereflect(filename);
    figure
    imshow(newimg)
    imwrite(newimg,[title2 num2str(i) form]);
end