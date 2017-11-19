clear;
clc;
%% ���س���ģ��
%�������Ϊ3�����֣�1--���ǡ��ɻ��˶�ģ�⣻2--�ɻ���������ģ�⣻3--�źŴ���ģ��
%1.���ǡ��ɻ��˶�ģ��
%���������Ҫͨ������AIRCRAFT������ɣ�AIRCRAFT�����а����������ĸ߶ȡ���γ�ȡ��ٶȵȲ���
%ģ���в���clock��Ϊ��������ÿ�����沽����simu_step���£������������ٶȺͷ���ǹ�ϵ��
%������λ�ã�ʵ�ֶԷ������˶���ģ��

%2.�ɻ���������ģ��
%Ŀǰ
simu_time =50;% ��λs
clock = 0;
simu_step =1e-3;%s
ratio = 6371;%KM
fc = 1090;%MHz   
c = 3e+5;%km/s




plane_lon = zeros(1,simu_time/simu_step);%��γ��
plane_lat = zeros(1,simu_time/simu_step);
mess_1 = [];%���õ����ձ�ʱ�䣬AP,AV,ID��Ϣ��������Ƶ�ƣ�������
x1=zeros(1,simu_time/simu_step);
y1=zeros(1,simu_time/simu_step);
z1=zeros(1,simu_time/simu_step);

%��ʼ���ɻ���λ�á��߶ȡ��ٶȵ���Ϣ

    %�ٶ� km/s �߶���500km����
plane = AIRCRAFT(0,50,0,0,10000,1,simu_time,simu_step,ceil(rand(1)*10),10,10,700,4.66,6);


%��̬���棬����ʱ����simu_time,���沽��:simu_step.
while(clock<(simu_time/simu_step))   
    plane=ChangePosition(plane,ratio);
    plane = axis(plane,ratio);
    plane =  velocity(plane);
    plane=ChangePosition_s(plane,ratio);
    plane = axis_s(plane,ratio);
    plane =  velocity_s(plane); 
    plane=axis(plane,ratio);
    plane = D_shift(plane,fc,c);
    plane = Loss(plane,fc);
    plane=BroadCast(plane,clock);
    clock = clock+1;
    x1(1,clock) = (ratio+plane.hight)*sin(plane.latitude*pi/180)*cos(plane.longitude*pi/180);
    y1(1,clock) = (ratio+plane.hight)*sin(plane.latitude*pi/180)*sin(plane.longitude*pi/180);
    z1(1,clock) = (ratio+plane.hight)*cos(plane.latitude*pi/180);
      
    %��������ϵ�ĽǶ�ת���ɾ�γ�ȣ�
    %���ȴ���0Ϊ������С��0Ϊ����
     if plane.longitude>=0&&plane.longitude<=180
       plane_lon(1,clock) = plane.longitude;%����
      else
       plane_lon(1,clock) = plane.longitude - 360;  
     end
     %γ�ȴ���0Ϊ��γ��С��0Ϊ��γ
       plane_lat(1,clock) = 90 - plane.latitude;
       
  
      time_rec = clock*simu_step + norm(plane.r_r)/c;
      
      %λ����Ϣ
      if plane.broad_times(1,clock) == 1
         A = [ time_rec; plane_lon(1,clock);plane_lat(1,clock);0;0;0;plane.fd;plane.T_sen;plane.Los];
         mess_1 = [mess_1,A];
  else
       if plane.broad_times(1,clock) == 2
          A = [clock*simu_step;0;0;plane.NS_velocity;plane.EW_velocity;0;plane.fd;plane.T_sen;plane.Los]; 
          mess_1 = [mess_1,A];
       else
           %�����ٶȱ���
           if plane.broad_times(1,clock) == 3
              A = [clock*simu_step;0;0;0;0;plane.ICAO;plane.fd;plane.T_sen;plane.Los];
              mess_1 = [mess_1,A];
              
       end
       end
    end  
end
plot3(x1,y1,z1);
axis equal;






    

