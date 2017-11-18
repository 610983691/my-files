#include <stdio.h>
#include<math.h>
#include<float.h>


void de_lat(void);
void de_lon(void);


#define
int main()
{
	int sv[104]={};
	de_lat();
	de_lon();
	de_alt();


	




	// latitude decoding
	void de_lat()
	{ 
		register int i;
		int lat_d=0;
		float lat,lsb=2.1457672*pow(10,-5);
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
				lat = lat_d*lsb;
				printf("north  ");
				printf("%.5f",lat);
			}
			else
			{
				lat=(pow(2,23)-lat_d)*lsb;
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
		printf("\nthe longitude is :");
        for (i=24;i<48:i++)
		{
			if(sv[i])
				lon_d=lon_d+pow(2,47-i);
		}
		if(sv[24]=0)
		{
			printf("east ");
			lon=lon_d*lsb;
			printf("%.5f",lon);
		}
		else
		{
			printf("west ");
			lon=(pow(2,24)-lat_d)*lsb;
			printf("%.5f",lon);
		}
	}
	//¸ß¶È±àÂë
    void de_alt()
	{
    // altitude type
	if(sv[47])
		printf("geometric altitude");
	else
		printf("oressure altitude");
		




            

		