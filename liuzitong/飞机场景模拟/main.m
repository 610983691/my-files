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
simu_time = 0.6;% 单位s
simu_step =1e-3;%s
ratio = 6371;%KM
fc = 1090;%MHz   
c = 3e+5;%km/s
%飞机的数量
N = 100;
%100架飞机的速度
plane_EWv = zeros(1,N);
plane_NSv = zeros(1,N);
high = zeros(1,N);
lon = zeros(1,N);
lat = zeros(1,N);
type = zeros(1,5);%设备类型D C B A  
type_code = zeros(5,5);
for i = 1:N
    plane_EWv(i) = 10+rand(1)*10;
    plane_NSv(i) = 10+rand(1)*10;
    high(i) = rand(1)*10;
    lon(i) = rand(1)*10+10;
    lat(i) = rand(1)*10+10;
    type(i) = randi(4);
    type_code(i,:) = bitget(type(i),5:-1:1);     
end
plane_lon = zeros(N,simu_time/simu_step);%经纬度
plane_lat = zeros(N,simu_time/simu_step);
hig = zeros(1,12);%高度信息
others = [bitget(17,5:-1:1),1,1,0,zeros(1,24)];

%初始化飞机的位置、高度、速度等信息
for i = 1:N
    %速度 km/s 高度在500km以内
plane{i} = AIRCRAFT(lon(i),lat(i),high(i),plane_EWv(i),plane_NSv(i),{'A','B','1','4','7','2','3','9'},simu_time,simu_step,ceil(rand(1)*10),10,10,700,4.66,6);
%动态仿真，仿真时常：simu_time,仿真步进:simu_step.
end
for i = 1:N
    clock = 0;
while(clock<(simu_time/simu_step)) 
    plane{i} = ChangePosition(plane{i},ratio);
    plane{i} = axis(plane{i},ratio);
    plane{i} =  velocity(plane{i});
    plane{i} = ChangePosition_s(plane{i},ratio);
    plane{i} = axis_s(plane{i},ratio);
    plane{i} =  velocity_s(plane{i}); 
    plane{i} = axis(plane{i},ratio);
    plane{i} = D_shift(plane{i},fc,c);
    plane{i} = Loss(plane{i},fc);
    plane{i} = BroadCast(plane{i},clock);
    clock = clock+1;
      
    %将求坐标系的角度转化成经纬度；
    %经度大于0为东经，小于0为西经
     if plane{i}.longitude>=0&&plane{i}.longitude<=180
       plane_lon(i,clock) = plane{i}.longitude;%经度
      else
       plane_lon(i,clock) = plane{i}.longitude - 360;  
     end
     %纬度大于0为北纬；小于0为南
       plane_lat(i,clock) = 90 - plane{i}.latitude;
       
      %卫星覆盖范围
    a = sqrt((plane{i}.hight_s+ratio)^2-ratio^2)-sqrt((plane{i}.hight+ratio)^2-ratio^2);
     %在卫星覆盖范围内
    if norm(plane{i}.r-plane{i}.r_s)<=a  
      %接收时间
      time_rec = clock*simu_step + norm(plane{i}.r_r)/c;
      %位置信息
      if plane{i}.broad_times(1,clock) == 1
         A = [time_rec; plane_lon(i,clock);plane_lat(i,clock);0;0;0;plane{i}.fd;plane{i}.T_sen;plane{i}.Los];
         plane{i}.mess = [plane{i}.mess,A];
       %高度信息编码
       b= round(plane{i}.hight/0.0003048);
       if b>50175
           int1 = fix((b+1200)/500);
           bin_1 = bitget(int1,8:-1:1);
           gry1 = bitxor(bin_1,[0,bin_1(1,1:7)]);
           int2 = fix(rem(b+1200,500)/100);
           bin_2 = bitget(int2,3:-1:1);
           gry2 = bitxor(bin_2,[0,bin_2(1,1:2)]);
           hig = [gry2(1,1),gry1(1,3),gry2(1,2),gry1(1,4),gry2(1,3),gry1(1,5),gry1(1,6),0,...
               gry1(1,7),gry1(1,1),gry1(1,8),gry1(1,2)];
       else
           n = ceil((plane{i}.hight/0.0003048+12.5+1000)/25);
           bin = bitget(n,11:-1:1);
           hig = [bin(1,1:7),1,bin(1,8:11)];  
       end
       plane{i}.cpr_f = 3-plane{i}.cpr_f;%prc formt 决定是奇编码还是偶编码
       
       %经纬度编码
       NZ = 15;
       Nb = 17;
           Dlat = 360/(4*NZ-plane{i}.cpr_f+1);
           lat =  plane{i}.latitude;
           yz = floor(2^17*mod(lat,Dlat)/Dlat+0.5);
           Rlat = Dlat*(yz/(2^17)+floor(lat/Dlat));
           NL = floor(2*pi/(acos(1-(1-cos(pi/(2*NZ)))/(cos(abs(plane{i}.latitude)*pi/180)^2))));
           if NL-plane{i}.cpr_f+1 >0
              Dlon = 360/(4*NZ-plane{i}.cpr_f+1);
           else
              Dlon = 360; 
           end
            xz = floor(2^17*mod(plane{i}.longitude,Dlon)/Dlon+0.5);
            yz = mod(yz,2^17);
            xz = mod(xz,2^17);
            bin_lat = bitget(yz,17:-1:1);
            bin_lon = bitget(xz,17:-1:1);
           %高度，经纬度编码完成，生成ME字段
           B = [1,0,1,1,0,0,0,0,hig(1,1:12),0,plane{i}.cpr_f,bin_lat(1,1:17),bin_lon(1,1:17)];
           plane{i}.binmess = [plane{i}.binmess;time_rec,others(1,1:32),B,zeros(1,24)];
       
      else
       if plane{i}.broad_times(1,clock) == 2
          A = [time_rec;0;0;plane{i}.NS_velocity;plane{i}.EW_velocity;0;plane{i}.fd;plane{i}.T_sen;plane{i}.Los]; 
          plane{i}.mess = [plane{i}.mess,A];
          
          %ID信息编码
          ID= zeros(1,48);
          for j = 1:8 
              if ((plane{i}.ICAO{j}>='0')&&(plane{i}.ICAO{j}<='9'))||((plane{i}.ICAO{j}>='A')&&(plane{i}.ICAO{j}<='Z'))
                 ID(1,(j*6-5):(j*6)) = bitand(bitget(double(plane{i}.ICAO{j}),6:-1:1),[1,1,1,1,1,1]);  
              else
                 ID(1,(j*6-5):(j*6)) = [1,0,0,0,0,0];
              end
          end
          B = [type_code(i,1:5),0,0,0,ID(1,1:48)];
          plane{i}.binmess = [plane{i}.binmess;time_rec,others(1,1:32),B,zeros(1,24)];

       else
           %空中速度编码
              plane{i}.broad_times(1,clock) == 3
              A = [time_rec;0;0;0;0;1;plane{i}.fd;plane{i}.T_sen;plane{i}.Los];
              plane{i}.mess = [plane{i}.mess,A];
              %subtype and 空速
              if (plane{i}.EW_velocity^2+plane{i}.NS_velocity^2 >= 21.3^2)
                  subtype = bitget(3,3:-1:1);
                  v =round( sqrt(plane{i}.EW_velocity^2+plane{i}.NS_velocity^2)/1.852);
                  N_v = v+1;
                  bin_v = bitget(N_v,10:-1:1);
              else
                  subtype = bitget(4,3:-1:1);
                  v =sqrt(plane{i}.EW_velocity^2+plane{i}.NS_velocity^2)/1.852;
                  N_v = round(v/4+1);
                  bin_v = bitget(N_v,10:-1:1);
              end  %超音速为4，非超音速为3
              %航向角
              if plane{i}.EW_velocity/plane{i}.NS_velocity>=0
                  if plane{i}.EW_velocity>=0
                      angle = atan(plane{i}.EW_velocity/plane{i}.NS_velocity)*180/pi;
                      N_a = round(angle/0.3515625);
                      bin_a = bitget(N_a,10:-1:1);
                  else
                      angle = (atan(plane{i}.EW_velocity/plane{i}.NS_velocity)+pi)*180/pi;
                      N_a = round(angle/0.3515625);
                      bin_a = bitget(N_a,10:-1:1);
                  end
              else
                  if plane{i}.EW_velocity>0
                      angle = (2*pi-atan(plane{i}.EW_velocity/plane{i}.NS_velocity))*180/pi;
                      N_a = round(angle/0.3515625);
                      bin_a = bitget(N_a,10:-1:1); 
                  else
                      angle = (-atan(plane{i}.EW_velocity/plane{i}.NS_velocity)+pi)*180/pi;
                      N_a = round(angle/0.3515625);
                      bin_a = bitget(N_a,10:-1:1);
                  end
              end
            B = [type_code(i,1:5),subtype(1,1:3),0,0,0,0,0,1,bin_a(1,1:10),1,bin_v(1,1:10),zeros(1,20),1];
            plane{i}.binmess = [plane{i}.binmess;time_rec,others(1,1:32),B,zeros(1,24)];
       end
       end
    end  
    end
end
    
    







    

