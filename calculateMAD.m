%% Mean Absolute Difference - Cost Function
%--------------------------------------------------------------------------
%  
% Computes the Mean Absolute Difference (MAD) for the given two blocks
% 
% [in] : currentBlock (Block for which MAD is being calculated)
% [in] : referenceBlock (Block w.r.t which MAD is being calculated)
% [in] : mbSize (Macro-Block size)
%
% [out] : Cost -> (1/mbSize^2) * sum(|Ci - Ri|)
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : Skanda Bharadwaj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
function cost = calculateMAD(currentBlock, referenceBlock, mbSize)

    error = 0;
    for i = 1:mbSize
        for j = 1:mbSize
            error = error + abs((currentBlock(i,j) - referenceBlock(i,j)));
        end
    end
    cost = error / (mbSize*mbSize);
    
end
%--------------------------------------------------------------------------
%% END