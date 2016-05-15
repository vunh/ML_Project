function [similarities]=Getcombinedsimilaritieswithmethod(similarities,newsimilarities) %#ok<INUSL>
%[similarities,wgtsimilarities]=Getcombinedsimilaritieswithmethod
%(similarities,STA,mrgmth,options,wgtsimilarities,mrgwgt(6));

if (any(size(similarities)~=size(newsimilarities)))
    fprintf('Similarities to combine of different sizes [%d,%d]-[%d,%d]\n',size(similarities,1),size(similarities,2),size(newsimilarities,1),size(newsimilarities,2));
    
    maxx=max(size(similarities,1),size(newsimilarities,1));
    maxy=max(size(similarities,2),size(newsimilarities,2));
    
    if ( (size(similarities,1)<maxx) || (size(similarities,2)<maxy) )
        [tmpx,tmpy,tmpv]=find(similarities);
        similarities=sparse(tmpx,tmpy,tmpv,maxx,maxy);
        fprintf('Similarities'' size adjusted\n');
    end
    if ( (size(newsimilarities,1)<maxx) || (size(newsimilarities,2)<maxy) )
        [tmpx,tmpy,tmpv]=find(newsimilarities);
        newsimilarities=sparse(tmpx,tmpy,tmpv,maxx,maxy);
        fprintf('Newsimilarities'' size adjusted\n');
    end
end



        domultiply=true;
        [similarities]=Averagesparsematriceswithweights(similarities,newsimilarities,domultiply);

end


