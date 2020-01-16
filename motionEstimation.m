%% Motion Estimation
%--------------------------------------------------------------------------
%  
% From a given video sequence motion estimation done using block matching
% method. Adaptive Rood Pattern Search(ARPS) is used with Mean Absolute
% Difference to find matching blocks. 
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : Skanda Bharadwaj 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ========================================================================

clear; close all; clc;

%% ========================================================================

% Load data
imageName = 'caltrain';
imageDir  = dir('./caltrain/gray');
nFrames   = size(imageDir, 1)-2;

% Define block size and search region
macroBlockSize = 16; searchParameter = 7;

% Frame structure initialization
F1 = struct('cdata', zeros(size(nFrames, 1)-1, 1), ...
            'colormap', zeros(size(nFrames, 1)-1, 1));

F2 = struct('cdata', zeros(size(nFrames, 1)-1, 1), ...
            'colormap', zeros(size(nFrames, 1)-1, 1));
        
F3 = struct('cdata', zeros(size(nFrames, 1)-1, 1), ...
            'colormap', zeros(size(nFrames, 1)-1, 1));
        
        
%% Iterate through frames of video
frame_to_frame_displacement = cell(nFrames-2, 1);
differenceImage = cell(nFrames-1, 1);
for i = 0:nFrames-2
    
    %% Fetch currentframe
    currentFrameNum = i+1;
    if currentFrameNum < 10
        currentFrame = sprintf('./%s/gray/%s00%d.ras',imageName, imageName, currentFrameNum);
    elseif currentFrameNum < 100
        currentFrame = sprintf('./%s/gray/%s0%d.ras',imageName, imageName, currentFrameNum);
    end
    imgC = double(imread(currentFrame));
    
    %% Fetch reference frame
    referenceFrameNum = i;
    if referenceFrameNum < 10
        referenceFrame = sprintf('./%s/gray/%s00%d.ras',imageName, imageName, referenceFrameNum);
    elseif referenceFrameNum < 100
        referenceFrame = sprintf('./%s/gray/%s0%d.ras',imageName, imageName, referenceFrameNum);
    end
    imgR = double(imread(referenceFrame)); 
    [M, N] = size(imgR);
    
    %% Call ARPS 
    [motionVect, vectShift] = ARPS(imgC, imgR, macroBlockSize, ...
                                   searchParameter);
      
    %% Reconstruct image using motion vectors
    [displacementMap, imgRC] = reconstructImage(imgR, motionVect, macroBlockSize);
    frame_to_frame_displacement{i+1, 1} = displacementMap;
    diffImage = imabsdiff(imgR,imgRC);
    differenceImage{i+1, 1} = diffImage;
    imgD = imbinarize(diffImage);
    
    %% Create subplots for current, reference, reconstructed and difference
    %  image
    figure(1); 
    subplot(221); imagesc(imgR);
    xlabel('Reference Frame', 'FontSize', 14', 'Fontweight', 'bold');
    
    subplot(222); imagesc(imgC); 
    xlabel('Current Frame', 'FontSize', 14', 'Fontweight', 'bold');
    
    subplot(223); imagesc(imgRC);
    xlabel('Reconstructed Image', 'FontSize', 14', 'Fontweight', 'bold');
    
    subplot(224); imagesc(imgD); 
    xlabel('Diff Image (Current-Reconstructed)', 'FontSize', 14', ...
           'Fontweight', 'bold');
    
    text( -1100, -2000, 'Image Reconstruction using ARPS Block Matching',  ...
          'FontSize', 14', 'FontWeight', 'Bold', 'HorizontalAlignment',    ...
          'center', 'VerticalAlignment', 'top' ) ;

    % Capture frames
    F1(i+1) = getframe(gcf);
   
    %% Define motion vector parameters
    dy = vectShift(1, :);
    dx = vectShift(2, :);
    v  = vectShift(3, :);
    u  = vectShift(4, :);
    
    %% Draw motion vectors
    figure(2);
    quiver(u, v, dy, dx); axis([0, N, 0, M]);
    set(gca, 'Ydir', 'reverse');
    title('Motion Vectors', 'FontSize', 14', 'Fontweight', 'bold');
    F2(i+1) = getframe(gcf);
    
    %% Superimpose motion vector on reference image
    figure(3); 
    imagesc(imgR); colormap(gray); hold on
    quiver(u, v, dy, dx, 'r', 'Linewidth', 2);
    title('Motion Vectors', 'FontSize', 14', 'Fontweight', 'bold');
    F3(i+1) = getframe(gcf);
end

%% Create Videos for captured frames
framerate = 5;
RMSE = zeros(size(differenceImage));
for i = 1:size(differenceImage, 1)
    img = differenceImage{i, 1};
    [rows, cols] = size(img);
    RMSE(i, 1) = sqrt(sum(sum(img.^2))/(rows*cols));
end
% writeVideo(F1, framerate, 'caltrain.avi');
% writeVideo(F2, framerate, 'caltrain_vectorMotion.avi');
% writeVideo(F3, framerate, 'caltrain_vectorMotionOnImage.avi');

%--------------------------------------------------------------------------
%% END