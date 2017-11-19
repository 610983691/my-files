classdef AIRCRAFT
    properties
        longitude;
        latitude;
        hight;
        EW_velocity;
        NS_velocity;
        time_step;
        simu_time;
        ICAO;
        broad_times;
        last_broadtime;
        last_AP=1;
        last_AV=2;
        last_ID=3;
        longitude_s;
        latitude_s;
        hight_s;
        EW_velocity_s;
        NS_velocity_s;
        r_s;
        v_s;
        Los;
        T_sen;
        r;
        v;
        fd;
        r_r;
        mess;
        binmess;
        cpr_f;
   
    end
    
    methods
        function obj=AIRCRAFT(lo,la,high,EW_v,NS_v,icao,simu_t,s_step,first_time,lo_s,la_s,high_s,NS_v_s,EW_v_s)
            obj.longitude=lo;
            obj.latitude=la;    
            obj.hight=high;
            obj.NS_velocity = NS_v;
            obj.EW_velocity = EW_v;
            obj.ICAO = icao;
            obj.longitude_s = lo_s;
            obj.latitude_s = la_s;
            obj.hight_s = high_s;
            obj.NS_velocity_s = NS_v_s;
            obj.EW_velocity_s = EW_v_s;
            obj.simu_time = simu_t;
            obj.time_step = s_step;
            obj.broad_times = zeros(1, simu_t/s_step);
            obj.last_broadtime = first_time;
            obj.broad_times(first_time) = 1;
            obj.mess = [];
            obj.binmess = [];
            obj.cpr_f = randi(2);%1表示奇编码 2 表示偶编码
     
            
        end
        
        %根据仿真步长，更新飞机位置.
       %飞机经纬度变化vθ=rdθ/dt，vφ=rsinθdφ/dt
        function obj=ChangePosition(obj,ratio)
            obj.longitude = mod(obj.longitude-obj.EW_velocity*obj.time_step/((obj.hight+ratio)*sin(mod(obj.latitude,360)*pi/180)),360);%经度变化
            obj.latitude =  obj.latitude+obj.NS_velocity*obj.time_step/(obj.hight+ratio);
        end
        %直角坐标系中位置表示
        function obj = axis(obj,ratio)
            obj.r = [(ratio+obj.hight)*sin(obj.latitude*pi/180)*cos(obj.longitude*pi/180);...
                (ratio+obj.hight)*sin(obj.latitude*pi/180)*sin(obj.longitude*pi/180);...
                (ratio+obj.hight)*cos(obj.latitude*pi/180)];          
        end
         %直角坐标系中速度表示
        function  obj =  velocity(obj)
            obj.v =[obj.NS_velocity*cos(obj.latitude*pi/180)*cos(obj.longitude*pi/180) + obj.EW_velocity*sin(obj.longitude*pi/180);...
                    obj.NS_velocity*cos(obj.latitude*pi/180)*sin(obj.longitude*pi/180) - obj.EW_velocity*cos(obj.longitude*pi/180);...
                    -obj.NS_velocity*sin(obj.latitude*pi/180)];
        end
        %卫星经纬度变化
        function obj=ChangePosition_s(obj,ratio)
             obj.longitude_s = obj.longitude_s+obj.EW_velocity_s*obj.time_step/((obj.hight_s+ratio)*cos(obj.latitude_s*pi/180));
             obj.latitude_s =  obj.latitude_s-obj.NS_velocity_s*obj.time_step/(obj.hight_s+ratio);
        end
        %卫星直角坐标系中位置表示
        function obj = axis_s(obj,ratio)
         obj.r_s = [(ratio+obj.hight_s)*sin(obj.latitude_s*pi/180)*cos(obj.longitude_s*pi/180);...
             (ratio+obj.hight_s)*sin(obj.latitude_s*pi/180)*sin(obj.longitude_s*pi/180);...
             (ratio+obj.hight_s)*cos(obj.latitude_s*pi/180)];
        end
       %卫星直角坐标系中速度表示     
        function  obj =  velocity_s(obj)
          obj.v_s =[obj.NS_velocity_s*cos(obj.latitude_s*pi/180)*cos(obj.longitude_s*pi/180) + obj.EW_velocity_s*sin(obj.longitude_s*pi/180);...
                    obj.NS_velocity_s*cos(obj.latitude_s*pi/180)*sin(obj.longitude_s*pi/180) - obj.EW_velocity_s*cos(obj.longitude_s*pi/180);...
                    -obj.NS_velocity_s*sin(obj.latitude_s*pi/180)];
        end 
        %多普勒频移计算fd=f/c×v×cosθ
        function obj=D_shift(obj,fc,c)
          %相对位置
  
          obj.r_r = obj.r - obj.r_s;
          %相对速度
          r_v = obj.v_s - obj.v;
           
          %夹角
          costheta = r_v'*obj.r_r/(norm(r_v)*norm(obj.r_r));
          %多普勒频移
         obj.fd = fc*norm(r_v)*costheta/c;%速度的单位都要是km/s
        end
        %传输损耗Los=32.44+20lgd(Km)+20lgf(MHz)
        function obj = Loss(obj,fc)
          obj.r_r = obj.r - obj.r_s;
          d = norm(obj.r_r);  
         obj.Los = 32.44 + 20*log10(fc + obj.fd)+ 20*log10(d);
         %发送功率500w
         power = 5*10^5/(10^(obj.Los/10));
         obj.T_sen = 10*log10(power);
        end
        
        %发报规律
        function obj=BroadCast(obj,count)
           
            %AP
            if(((count-obj.last_broadtime)*obj.time_step>=120e-6)&&...
                    ((count-obj.last_AP)*obj.time_step>=0.5))
                broadt=ceil(count+rand(1)*10);
                obj.last_broadtime=broadt;
                obj.last_AP=broadt;
                obj.broad_times(broadt)=1;
            end
            %AV
            if(((count-obj.last_broadtime)*obj.time_step>=120e-6) &&...
                    ((count-obj.last_AV)*obj.time_step>=0.5))
                broadt=ceil(count+rand(1)*10);
                obj.last_broadtime=broadt;
                obj.last_AV=broadt;
                obj.broad_times(broadt)=2;                    
            end
            %ID
            if(((count-obj.last_broadtime)*obj.time_step>=120e-6)&&...
                    ((count-obj.last_ID)*obj.time_step>=5))
                broadt=ceil(count+rand(1)*10);
                obj.last_broadtime=broadt;
                obj.last_ID=broadt;
                obj.broad_times(broadt)=3;                
            end
         
        end
    end
end