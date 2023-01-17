function [nI,snI]=getColorExact(colorIm,ntscIm)
% 计算图片大小
n=size(ntscIm,1); m=size(ntscIm,2);
imgSize=n*m;

% 获取灰度图所对应的通道
nI(:,:,1)=ntscIm(:,:,1);
% 为每一个像素设定一个坐标(views as an 1-D array)
indsM=reshape([1:imgSize],n,m);
% 找出被上色的坐标
lblInds=find(colorIm);
% 邻域的宽度
wd=1; 

len=0;
consts_len=0;
% 每一个邻域中元素的列坐标
col_inds=zeros(imgSize*(2*wd+1)^2,1);
% 每一个邻域中元素的行坐标
row_inds=zeros(imgSize*(2*wd+1)^2,1);
vals=zeros(imgSize*(2*wd+1)^2,1);
gvals=zeros(1,(2*wd+1)^2);

% 遍历每一个像素点
for j=1:m
   for i=1:n
      % 每一个元素都计数
      consts_len=consts_len+1;
      % 如果没有标注颜色
      if (~colorIm(i,j))   
        tlen=0;
        % 遍历邻域
        for ii=max(1,i-wd):min(i+wd,n)
           for jj=max(1,j-wd):min(j+wd,m)
              % 除了自己以外
              if (ii~=i)|(jj~=j)
                 len=len+1; tlen=tlen+1;
                 row_inds(len)= consts_len;
                 col_inds(len)=indsM(ii,jj);
                 % 记录一下邻域的值
                 gvals(tlen)=ntscIm(ii,jj,1);
              end
           end
        end
        % 该元素的值
        t_val=ntscIm(i,j,1);
        % 保存到gvals数组中
        gvals(tlen+1)=t_val;
        % 领域内像素值的方差
        c_var=mean((gvals(1:tlen+1)-mean(gvals(1:tlen+1))).^2);
        csig=c_var*0.6;
        mgv=min((gvals(1:tlen)-t_val).^2);
        if (csig<(-mgv/log(0.01)))
            csig=-mgv/log(0.01);
        end
        if (csig<0.000002)
            csig=0.000002;
        end

        gvals(1:tlen)=exp(-(gvals(1:tlen)-t_val).^2/csig);
        % 归一化
        gvals(1:tlen)=gvals(1:tlen)/sum(gvals(1:tlen));
        % 保存这个邻域内的值
        vals(len-tlen+1:len)=-gvals(1:tlen);
      end

      % 自己的权重是1?
      len=len+1;
      row_inds(len)= consts_len;
      col_inds(len)=indsM(i,j);
      vals(len)=1; 

   end
end

vals=vals(1:len);
col_inds=col_inds(1:len);
row_inds=row_inds(1:len);


A=sparse(row_inds,col_inds,vals,consts_len,imgSize);
b=zeros(size(A,1),1);


for t=2:3
    curIm=ntscIm(:,:,t);
    b(lblInds)=curIm(lblInds);
    new_vals=A\b;   
    nI(:,:,t)=reshape(new_vals,n,m,1);    
end



snI=nI;
nI=ntsc2rgb(nI);

