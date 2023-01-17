function [nI]=colorizeFun(gI,cI,solver)
% 默认参数
if ~exist('solver','var')
    solver=1;
end

% 应该是一个布尔掩码
colorIm=(sum(abs(gI-cI),3)>0.01);
colorIm=double(colorIm);
% 转化一下颜色空间
sgI=rgb2ntsc(gI);
scI=rgb2ntsc(cI);
% 
ntscIm(:,:,1)=sgI(:,:,1);
ntscIm(:,:,2)=scI(:,:,2);
ntscIm(:,:,3)=scI(:,:,3);

% 限制了一下图片的大小（量化）
% max_d = floor(log_2^{min(w, h)} - 2)
%       = floor(log_2^(min(w, h) / 4))
% max_d - 1 = log_2^(min(w, h) / 8)
% 2^(max_d - 1) = min(w, h) / 8 => 大概是1/8的大小
max_d=floor(log(min(size(ntscIm,1),size(ntscIm,2)))/log(2)-2);
iu=floor(size(ntscIm,1)/(2^(max_d-1)))*(2^(max_d-1));
ju=floor(size(ntscIm,2)/(2^(max_d-1)))*(2^(max_d-1));
id=1; jd=1;
colorIm=colorIm(id:iu,jd:ju,:);
ntscIm=ntscIm(id:iu,jd:ju,:);

if (solver==1)
  nI=getVolColor(colorIm,ntscIm,[],[],[],[],5,1);
  nI=ntsc2rgb(nI);
else
  nI=getColorExact(colorIm,ntscIm);
end

%figure, imshow(nI)

%imwrite(nI,out_name)
   
  

%Reminder: mex cmd
%mex -O getVolColor.cpp fmg.cpp mg.cpp  tensor2d.cpp  tensor3d.cpp
