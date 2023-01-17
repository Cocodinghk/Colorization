function []=cheapUI(im1);
% 输入的图像像素值范围是0到1
strokeW=3;
% 转换为灰度图
gg=rgb2gray(im1);
figure(1);
hold off;
imshow(gg);
% 将灰度图当作一个通道复制三次
imMarked=im1;
imMarked(:,:,1)=gg;
imMarked(:,:,2)=gg;
imMarked(:,:,3)=gg;

% 制作一个显示HSV颜色空间的选色板, -128是因为对称
[xx,yy]=meshgrid(1:256);xx=xx-128;yy=yy-128;
% 不同的角度对应不同的色调
hh=atan2(yy,xx); hh=(hh+pi)/(2*pi); % hue of chooser
% 离中心的距离决定了饱和度
ss=sqrt(xx.^2+yy.^2); % saturation of chooser
ss=ss/128; ss=min(ss,1);
% quanitzed chooser looks better
ss=round(10*ss)/10;
hh=round(20*hh)/20;
colorChooser=zeros([256 256 3]);
colorChooser(:,:,1)=hh;
colorChooser(:,:,2)=ss;
% 明亮程度是0.5
colorChooser(:,:,3)=0.5;
% 转化为RGB显示在UI界面上
colorRGB=hsv2rgb(colorChooser);
colorRGB = uint8(colorRGB * 255);

figure(3);
imshow(colorRGB);
figure(2);
clf;
figure(1);

g3=imMarked; % gray level in 3 channel format
disp('(d)rawline (a)pply solver (A)pply exact (c)hoose color (esc) quit');
hold on;
x=[];
y=[];
[sx,sy]=size(gg);
while(1)
    % 从figure1(灰度图)中获取输入
    [xx,yy,button]=ginput(1);
    if (button==100); % 'd'
        mask=0;
        if length(x) < 2;
            disp("please as least 2 pixels");
            continue;
        end
        for i=2:length(x)
            x0=x(i-1);y0=y(i-1);
            x1=x(i);y1=y(i);
            mask=mask+drawLine([x0 y0],[x1 y1],strokeW,sx,sy);
        end
        mask=(mask>0);
        I=find(mask);
        medianC=zeros(3,1);
        % 遍历每一个通道
        for cc=1:3
            imC=im1(:,:,cc);
            % 取出线段上经过的原图的色彩的中位数
%              medianC(cc)=median(imC(I));
             medianC(cc) = mean(imC(I));
            % 使用中位数来标注图片
            imMarked(:,:,cc)=uint8(mask)*medianC(cc) ...
                +uint8((1-mask)).*imMarked(:,:,cc);
        end

        hold off;
        imMarked_with_edge = add_edge(imMarked, 0.5);
        imshow(imMarked_with_edge);
        % 清空所有的点
        x=[];y=[];
        hold on;
    elseif (button==99);% 'c'
        % first figure out luminances
        % 弹出选色板
        figure(3);
        imshow(colorRGB);
        % 获取选色板上点击的坐标
        [cx,cy]=ginput(1);cx=round(cx);cy=round(cy);
        % 获取颜色
        medianC(1)=colorRGB(cy,cx,1);
        medianC(2)=colorRGB(cy,cx,2);
        medianC(3)=colorRGB(cy,cx,3);
         mask=0;
        for i=2:length(x)
            x0=x(i-1);y0=y(i-1);
            x1=x(i);y1=y(i);
            mask=mask+drawLine([x0 y0],[x1 y1],strokeW,sx,sy);
        end
        mask=(mask>0);
        % 上色
        for cc=1:3
            imC=im1(:,:,cc);
            imMarked(:,:,cc)=uint8(mask)*medianC(cc) ...
                +uint8((1-mask)).*imMarked(:,:,cc);
        end

        figure(1);
        hold off;
        imMarked_with_edge = add_edge(imMarked, 0.2);
        imshow(imMarked_with_edge);
        x=[];y=[];
        hold on;


%     elseif (button==97); %'a'
%         disp('applying multigrid');
%         nI=colorizeFun(g3,imMarked);
%         figure(2);
%         imshow(nI);
%         figure(1);
%         x=[];y=[];
     elseif (button==65); %'A'
        disp('running exact solver');
        % g3 => 原来的灰度图
        % imMarked => 标注好的图片
        % 2 => 求解的方法, 使用matlab的操作符
        nI=colorizeFun(g3,imMarked,2);
        figure(2);
        imshow(nI);
        figure(1);
        x=[];y=[];
    elseif (button==27); % esc
        break;
    % 什么都不做
    else

    figure(1);
    plot(xx,yy,'x');
    % 记录一下鼠标所点击的位置
    x=[x;xx];
    y=[y;yy];
end
end


function [mask]=drawLine(x0,x1,strokeW,sx,sy)
% x0: 起始点
% x1: 终点
% strokeW / norm(d) = 1 / npts => npts = norm(d) / strokeW, 表示两点间隔
% sx, sy 图像的宽高
[xG,yG]=meshgrid(1:sy,1:sx);
mask=zeros(sx,sy);
d=x1-x0;
step=strokeW/norm(d);
for t=0:step:1
    xn=x0+t*d;
    % 计算图像上的所有点到该点的距离
    dImage=(xG-xn(1)).^2+(yG-xn(2)).^2;
    % 在该点周围取一个邻域, 这样线条才有宽度
    mask=mask+(dImage<strokeW^2);
end
% mask保存了线段上的所有点
mask=(mask>0);
