5     PORT1=00H
10     DIM ARR(0FEH)
20     FOR I=0 TO 0FEH
30    ARR(I)=I+1
40     NEXT 
50     FOR I=0 TO 0FEH
60    PORT1=ARR(I)
70     NEXT 
80     END 

