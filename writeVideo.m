%% Write video
%--------------------------------------------------------------------------
%  
% This scripts write a given set of frame into a video. 
%  
% [in] : frames (set of frames)
% [in] : framerate
% [in] : videoName (name of the video file with which it will be saved)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : Skanda Bharadwaj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
function writeVideo(frames, framerate, videoName)
    
    % Create the video file (.avi)
    writerObj = VideoWriter(videoName);
    
    % Set framerate
    writerObj.FrameRate = framerate;

    % open the video writer
    open(writerObj);
    
    % write the frames to the video
    for i=1:length(frames)
        % convert the image to a frame
        frame = frames(i) ;    
        writeVideo(writerObj, frame);
    end
    
    % close the writer object
    close(writerObj);
    
end
%--------------------------------------------------------------------------
%% END