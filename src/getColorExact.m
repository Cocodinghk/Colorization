function [nI,snI]=getColorExact(colorIm,ntscIm)
% ����ͼƬ��С
n=size(ntscIm,1); m=size(ntscIm,2);
imgSize=n*m;

% ��ȡ�Ҷ�ͼ����Ӧ��ͨ��
nI(:,:,1)=ntscIm(:,:,1);
% Ϊÿһ�������趨һ������(views as an 1-D array)
indsM=reshape([1:imgSize],n,m);
% �ҳ�����ɫ������
lblInds=find(colorIm);
% ����Ŀ��
wd=1; 

len=0;
consts_len=0;
% ÿһ��������Ԫ�ص�������
col_inds=zeros(imgSize*(2*wd+1)^2,1);
% ÿһ��������Ԫ�ص�������
row_inds=zeros(imgSize*(2*wd+1)^2,1);
vals=zeros(imgSize*(2*wd+1)^2,1);
gvals=zeros(1,(2*wd+1)^2);

% ����ÿһ�����ص�
for j=1:m
   for i=1:n
      % ÿһ��Ԫ�ض�����
      consts_len=consts_len+1;
      % ���û�б�ע��ɫ
      if (~colorIm(i,j))   
        tlen=0;
        % ��������
        for ii=max(1,i-wd):min(i+wd,n)
           for jj=max(1,j-wd):min(j+wd,m)
              % �����Լ�����
              if (ii~=i)|(jj~=j)
                 len=len+1; tlen=tlen+1;
                 row_inds(len)= consts_len;
                 col_inds(len)=indsM(ii,jj);
                 % ��¼һ�������ֵ
                 gvals(tlen)=ntscIm(ii,jj,1);
              end
           end
        end
        % ��Ԫ�ص�ֵ
        t_val=ntscIm(i,j,1);
        % ���浽gvals������
        gvals(tlen+1)=t_val;
        % ����������ֵ�ķ���
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
        % ��һ��
        gvals(1:tlen)=gvals(1:tlen)/sum(gvals(1:tlen));
        % ������������ڵ�ֵ
        vals(len-tlen+1:len)=-gvals(1:tlen);
      end

      % �Լ���Ȩ����1?
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

