#include <stdio.h>
#include<math.h>
#include<float.h>
#include<stdlib.h>
#include<time.h>


void de_lat(void);
void de_lon(void);


#define
int main()
{
	int sv[104]={};
	de_lat();
	de_lon();
	de_alt();
	//NIC暂时不看4bits
	//A/G state 2bits
	//horizontal velocity水平速度
	horizontal_v();



	




	// latitude decoding
	void de_lat()
	{ 
		register int i;
		int lat_d=0;
		float lat,lsb=2.1457672*pow(10,-5);
		float accuracy;//经纬度编码时会有一个四舍五入
        srand((unsigned)time(NULL));
		accuracy=(rand()/(double)(RAND_MAX)-0.5)*lsb;
		// translate to dec
		printf("the latitude is:   ");
        for (i=0;i<23:i++)
		{
			if(sv[i])
				lat_d=lat_d+pow(2,22-i);
		}
        // whether is N pole or South pole
		if(lat_d=pow(2,22))
				printf("pole\n");
		else
	    // not pole 
        {
			if(sv[0]=0)
			{
				lat = lat_d*lsb+accuracy ;
				printf("north  ");
				printf("%.5f",lat);
			}
			else
			{
				lat=(pow(2,23)-lat_d)*lsb+accuracy;
				printf("south   ");
				printf("%.5f",lat);
			}
		}
	}
	//longitude encoding
	void de_lon()
	{
		register int i;
		int lon_d=0;
        float lon,lsb=2.1457672*pow(10,-5);
		float accuracy;
        srand((unsigned)time(NULL));
		accuracy=(rand()/(double)(RAND_MAX)-0.5)*lsb;
		printf("\nthe longitude is :");
        for (i=23;i<47:i++)
		{
			if(sv[i])
				lon_d=lon_d+pow(2,46-i);
		}
		if(sv[24]=0)
		{
			printf("east ");
			lon=lon_d*lsb+accuracy;
			printf("%.5f",lon);
		}
		else
		{
			printf("west ");
			lon=(pow(2,24)-lat_d)*lsb+accuracy;
			printf("%.5f",lon);
		}
	}
	//高度编码
    void de_alt()
	{
 	  register int i;
	  int alt_d;
	  int alt;
	  float accuracy;
	  srand((unsigned)time(NULL));
	  accuracy=rand()/((double)(RAND_MAX)/25)-12.5;
      // altitude type
	  if(sv[47])
		  printf("\ngeometric altitude");
	  else
		  printf("\npressure altitude");
	  //altitude 12bits
      for (i=48;i<60:i++)
	  {
	     if(sv[i])
		    alt_d=alt_d+pow(2,59-i);
	  }
      if(alt_d)
	  {
	      alt=alt_d*25-1025+accuracy;//feet
	      printf("\nthe altitude is :");
	      printf("%d",alt);
	  }
	  else
		  printf("\naltitude imformation is unavailable");
	}
   // horizontal velocity
   //其中在速度编码前有一个reseved
	void horizontal_v()
	{
		register int i;
		int NS_velocity_d=0;
		int NS_velocity;
		float accuracy;
		srand((unsigned)time(NULL));
	    accuracy=rand()/(double)(RAND_MAX)-0.5;
		//根据A/G state分类 
		//0
		if((sv[64]==0)&&(sv[65]==0))
		{
		//NSvelocity
		//airborne subsonic 1kt
		//判断方向
		  if(sv[66])
			  printf("\nthe direction is south");
		  else
			  printf("\nthe direciton is north");
		// velocity 大小10bits
          for(i=67;i<77;i++)
		  {
		    if(sv[i])
		      NS_velocity_d= NS_velocity_d+pow(2,59-i);
		  }
		  if( NS_velocity_d==0)
			printf("\nthe N/S velocity is available");
		  else
		  {
			if(NS_velocity_d==1023)
				printf("\nthe N/S velocity is bigger than 1021.5knots");
			else
			{
				NS_velocity=NS_velocity_d-1+accuracy;
			    printf("\nthe N/S velocity is %.5f",NS_velocity);
			}
		  }
		}
		//1






            

		