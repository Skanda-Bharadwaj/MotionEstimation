%% Mean Absolute Difference - Cost Function
%--------------------------------------------------------------------------
%  
% Computes the Mean Absolute Difference (MAD) for the given two blocks
% 
% [in] : referenceImage (Image used to reconstruct the succeeding frame)
% [in] : motionVect (motion vectors for reconstruction)
% [in] : mbSize (Macro-Block size)
%
% [out] : reconstructedImage (Reconstructed image from the reference frame)
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : Skanda Bharadwaj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
function reconstructedImage = reconstructImage(imgR, motionVect, mbSize)

[row, col] = size(imgR);

mbCount = 1;
for i = 1:mbSize:row-mbSize+1
    for j = 1:mbSize:col-mbSize+1
        
        % assign vector components
        dy = motionVect(1,mbCount);
        dx = motionVect(2,mbCount);
        
        % Find the shift for the reference block
        pixelRowInReferenceBlock = i + dy;
        pixelColumnInReferenceBlock = j + dx;
        
        % Reconstruct current frame using the reference frame and motion
        % vectors
        newImage(i:i+mbSize-1,j:j+mbSize-1) = ...
          imgR(pixelRowInReferenceBlock:pixelRowInReferenceBlock+mbSize-1, ...
               pixelColumnInReferenceBlock:pixelColumnInReferenceBlock+mbSize-1);
    
        mbCount = mbCount + 1;
    end
end

reconstructedImage = newImage;
%--------------------------------------------------------------------------
%% END