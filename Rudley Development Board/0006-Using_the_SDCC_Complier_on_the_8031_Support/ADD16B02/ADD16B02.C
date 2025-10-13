#include <8051.h>
 
 int var1 = 5;
 int var2 = 6;
 int var3 = 7;
 
 void main(void)
{
	while (1)
	{
	var3 = var1 - var2;
	}
}