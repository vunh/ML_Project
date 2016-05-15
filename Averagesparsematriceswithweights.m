function [cc]=Averagesparsematriceswithweights(aa,bb,domultiply)
%Is it correct to include exclusive points without weighting?
%The function is symmetric in the two input
%The weight matrices do not need be normalized, and the wcmatrix is not
%normalized either (it is just a sum of wamatrix and wbmatrix)

if ( (~exist('domultiply','var')) || (isempty(domultiply)) )
    domultiply=false;
end

%Sum the two matrices
%This sum gives the exclusive values
cc=aa+bb;

%To divide by 2
commonelements=find(aa&bb);

if (domultiply)
    
    cc(commonelements)=aa(commonelements).*bb(commonelements)./...
        ( aa(commonelements).*bb(commonelements) + (1-aa(commonelements)).*(1-bb(commonelements)) );
    
end

end

%To include as sums
% xor(aa,bb)

%Checks
% numel(find(aa))
% numel(find(bb))
% numel(find(aa&bb))
% numel(find(xor(aa,bb)))
% numel(find(cc))
% numel(find(xor(aa,bb)))+numel(find(aa&bb))
