param N integer >=1; # number of strips
param J{1..(2*N),1..(2*N+1)} >=0; # J[i,j] is time to complete job i and then transit to location j
                                  # J[i,2N+1] is time to complete job i and then finish

var X{i in 1..(2*N+1),j in 1..(2*N+1)} binary;
var T{i in 1..N};

minimize cost: sum{i in 1..(2*N),j in 1..(2*N+1)} J[i,j]*X[i,j];

subject to start_all{j in 1..N}: sum{i in 1..(2*N+1)} (X[i,2*j] + X[i,2*j-1]) = 1;
subject to start_last: sum{i in 1..(2*N)} X[i,2*N+1] = 1;

subject to complete_all{i in 1..N}: sum{j in 1..(2*N+1)} (X[2*i,j] + X[2*i-1,j]) = 1;
subject to complete_last: sum{j in 1..(2*N)} X[2*N+1,j] = 1;

subject to complete_start{i in 1..2*N}: sum{j in 1..(2*N+1)} X[i,j] = sum{j in 1..(2*N+1)} X[j,i];

subject to self1{i in 1..(2*N+1)}: X[i,i] = 0;
subject to self2{i in 1..N}: X[2*i,2*i-1] = 0;
subject to self3{i in 1..N}: X[2*i-1,2*i] = 0;

subject to noloop{i in 1..N, j in 1..N: i<>j}: T[j] >= T[i]+1+N*(X[2*i,2*j]+X[2*i-1,2*j]+X[2*i,2*j-1]+X[2*i-1,2*j-1]-1);