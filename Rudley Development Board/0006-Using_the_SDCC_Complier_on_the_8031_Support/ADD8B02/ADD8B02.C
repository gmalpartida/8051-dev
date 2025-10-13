#include <8051.h>
 
 char var1 = 5;
 char var2 = 6;
 char var3 = 7;
 
 void main(void)
{
    while(1)
    {
         var3 = var1 + var2;
    }
}