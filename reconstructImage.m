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
function [displacementMap, reconstructedImage] = reconstructImage(imgR, motionVect, mbSize)

[row, col] = size(imgR);

mbCount = 1; cnt1 = 0; 
displacementMap = cell(row/mbSize, col/mbSize);
for i = 1:mbSize:row-mbSize+1
    cnt2 = 0; cnt1 = cnt1 + 1;
    for j = 1:mbSize:col-mbSize+1
        cnt2 = cnt2 + 1;
        % assign vector components
        dy = motionVect(1,mbCount);
        dx = motionVect(2,mbCount);
        
        displacementMap{cnt1, cnt2} = [dy, dx];
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