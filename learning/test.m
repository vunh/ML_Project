aa = a1 *0;
aa(a1>0.5) =1 ;
sum(abs(aa-label_intra)) / numel(label_intra)
