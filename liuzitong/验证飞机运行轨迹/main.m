clear;
clc;
%% 星载场景模拟
%本程序分为3个部分，1--卫星、飞机运动模拟；2--飞机发报规则模拟；3--信号传输模拟
%1.卫星、飞机运动模拟
%这个部分主要通过构建AIRCRAFT对象完成，AIRCRAFT对象中包含飞行器的高度、经纬度、速度等参数
%模拟中采用clock作为计数器，每个仿真步进（simu_step）下，飞行器根据速度和方向角关系，
%更新其位置，实现对飞行器运动的模拟

%2.飞机发报规则模拟
%目前
simu_time =50;% 单位s
clock = 0;
simu_step =1e-3;%s
ratio = 6371;%KM
fc = 1090;%MHz   
c = 3e+5;%km/s




plane_lon = zeros(1,simu_time/simu_step);%经纬度
plane_lat = zeros(1,simu_time/simu_step);
mess_1 = [];%最后得到的收报时间，AP,AV,ID信息，多普勒频移；灵敏度
x1=zeros(1,simu_time/simu_step);
y1=zeros(1,simu_time/simu_step);
z1=zeros(1,simu_time/simu_step);

%初始化飞机的位置、高度、速度等信息

    %速度 km/s 高度在500km以内
plane = AIRCRAFT(0,50,0,0,10000,1,simu_time,simu_step,ceil(rand(1)*10),10,10,700,4.66,6);


%动态仿真，仿真时常：simu_time,仿真步进:simu_step.
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
      
    %将求坐标系的角度转化成经纬度；
    %经度大于0为东经，小于0为西经
     if plane.longitude>=0&&plane.longitude<=180
       plane_lon(1,clock) = plane.longitude;%经度
      else
       plane_lon(1,clock) = plane.longitude - 360;  
     end
     %纬度大于0为北纬；小于0为南纬
       plane_lat(1,clock) = 90 - plane.latitude;
       
  
      time_rec = clock*simu_step + norm(plane.r_r)/c;
      
      %位置信息
      if plane.broad_times(1,clock) == 1
         A = [ time_rec; plane_lon(1,clock);plane_lat(1,clock);0;0;0;plane.fd;plane.T_sen;plane.Los];
         mess_1 = [mess_1,A];
  else
       if plane.broad_times(1,clock) == 2
          A = [clock*simu_step;0;0;plane.NS_velocity;plane.EW_velocity;0;plane.fd;plane.T_sen;plane.Los]; 
          mess_1 = [mess_1,A];
       else
           %空中速度编码
           if plane.broad_times(1,clock) == 3
              A = [clock*simu_step;0;0;0;0;plane.ICAO;plane.fd;plane.T_sen;plane.Los];
              mess_1 = [mess_1,A];
              
       end
       end
    end  
end
plot3(x1,y1,z1);
axis equal;






    

