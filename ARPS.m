%% Motion Estimation
%--------------------------------------------------------------------------
%  
% The function implements the ARPS block matching for the input frames. 
% 
% [in] : imgC (current frame)
% [in] : imgR (Reference frame)
% [in] : mbsize (Macro-Block size)
% [in] : p (search area parameter)
%
% [out] : motion vectors
% [out] : vectorShift (Tail and head of motion vectors)
%
% -------- This scripts needs optimization and proper commenting ----------
%         (Optimaization and commenting only partially completed)
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Oignial Author : Aroh Barjatya
% Author : Skanda Bharadwaj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
function [motionVect, vectorShift] = ARPS(imgC, imgR, mbSize, p)

    % Image size
    [row, col] = size(imgR);

    % Motion vectors
    vectors = zeros(2,row*col/mbSize^2);

    % Defines tail and head of the motion vector
    vectorShift = zeros(4, row*col/mbSize^2);

    % Cost of each points on the diamond pattern 
    costs = ones(1, 6) * 65537;

    % The index points for Small Diamond Search Pattern
    SDSP(1,:) = [ 0 -1];
    SDSP(2,:) = [-1  0];
    SDSP(3,:) = [ 0  0];
    SDSP(4,:) = [ 1  0];
    SDSP(5,:) = [ 0  1];

    % Definition of the search area and the calculation of costs:
    %
    %
    %                      Searh Area |<---- P ---->|
    %                     |-----------*-------------|
    %                     |                         | 
    %                     |       *   *---*---------|-------------|
    %                     |           |             |             |
    %                     |           *             |             |
    %                     |-------------------------|             |
    %                                 |                           |
    %                                 |                           |
    %                                 |---------------------------| 
    %                                                imgP/imgI superImposed
    %
    %
    % Cost calculated by placing the reference frame(imgI) on each of the
    % points of the diamond(*) is stored in 'costs' 
    %
    % Once the cost is calcualted at a certain point, the point is marked 
    % '1' in the check matrix that is initialized to zeros. The center of 
    % the diamond is the center of the search area at start.
    %
    % computations keeps track of the number of computations carried out.
    %
    checkMatrix = zeros(2*p+1,2*p+1);

    computations = 0;
    
    %% Raster scan
    %
    % Starting from top left corner of the image macro block is moved in
    % steps of mbsize. mbCoubt keeps track of number of evaluated blocks.
    %
    mbCount = 1;
    for i = 1 : mbSize : row-mbSize+1
        for j = 1 : mbSize : col-mbSize+1

            % (x, y) represent the origin of the diamond. Initally, the
            % point is set to the top left corner of the sub-image. 
            x = j;
            y = i;

            subImgI = imgR(i:i+mbSize-1,j:j+mbSize-1);
            subImgP = imgC(i:i+mbSize-1,j:j+mbSize-1);

            costs(3) = calculateMAD(subImgP, subImgI,mbSize);

            checkMatrix(p+1,p+1) = 1;
            computations =  computations + 1; 
            
            % if we are in the left most column then we have to make sure that
            % we just do the LDSP with stepSize = 2
            if (j-1 < 1)
                stepSize = 2;
                maxIndex = 5;
            else 
                stepSize = max(abs(vectors(1,mbCount-1)), abs(vectors(2,mbCount-1)));

                % now we have to make sure that if the point due to motion
                % vector is one of the LDSP points then we dont calculate it
                % again
                if ( (abs(vectors(1,mbCount-1)) == stepSize && vectors(2,mbCount-1) == 0) ...
                     || (abs(vectors(2,mbCount-1)) == stepSize && vectors(1,mbCount-1) == 0)) ...

                    maxIndex = 5; % we just have to check at the rood pattern 5 points

                else
                    maxIndex = 6; % we have to check 6 points
                    LDSP(6,:) = [ vectors(2, mbCount-1)  vectors(1, mbCount-1)];
                end
            end

            % The index points for first and only Large Diamond search pattern
            LDSP(1,:) = [        0  -stepSize];
            LDSP(2,:) = [-stepSize          0]; 
            LDSP(3,:) = [        0          0];
            LDSP(4,:) = [ stepSize          0];
            LDSP(5,:) = [        0   stepSize];


            %% do the LDSP
            for k = 1:maxIndex
                refBlkVer = y + LDSP(k,2);   % row/Vert co-ordinate for ref block
                refBlkHor = x + LDSP(k,1);   % col/Horizontal co-ordinate
                if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                     || refBlkHor < 1 || refBlkHor+mbSize-1 > col)

                    continue; % outside image boundary
                end

                if (k == 3 || stepSize == 0)
                    continue; % center point already calculated
                end
                costs(k) = calculateMAD(imgC(i:i+mbSize-1,j:j+mbSize-1),    ...
                                       imgR(refBlkVer:refBlkVer+mbSize-1,  ...
                                            refBlkHor:refBlkHor+mbSize-1), ...
                                       mbSize);
                                   
                computations =  computations + 1;
                checkMatrix(LDSP(k,2) + p+1, LDSP(k,1) + p+1) = 1;
            end

            [cost, point] = min(costs);
            % The doneFlag is set to 1 when the minimum
            % is at the center of the diamond           

            x = x + LDSP(point, 1);
            y = y + LDSP(point, 2);
            costs = ones(1,5) * 65537;
            costs(3) = cost;

            %% SDSP
            doneFlag = 0;   
            while (doneFlag == 0)
                for k = 1:5
                    refBlkVer = y + SDSP(k,2);   % row/Vert co-ordinate for ref block
                    refBlkHor = x + SDSP(k,1);   % col/Horizontal co-ordinate
                    if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                          || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                          continue;
                    end

                    if (k == 3)
                        continue
                    elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                            continue;
                    elseif (checkMatrix(y-i+SDSP(k,2)+p+1 , x-j+SDSP(k,1)+p+1) == 1)
                        continue
                    end

                    costs(k) = calculateMAD(imgC(i:i+mbSize-1,j:j+mbSize-1), ...
                                 imgR(refBlkVer:refBlkVer+mbSize-1, ...
                                     refBlkHor:refBlkHor+mbSize-1), mbSize);
                    checkMatrix(y-i+SDSP(k,2)+p+1, x-j+SDSP(k,1)+p+1) = 1;
                    computations =  computations + 1;


                end

                [cost, point] = min(costs);

                if (point == 3)
                    doneFlag = 1;
                else
                    x = x + SDSP(point, 1);
                    y = y + SDSP(point, 2);
                    costs = ones(1,5) * 65537;
                    costs(3) = cost;
                end

            end  % while loop ends here

            %% Calculate Motion vectors
            vectors(1,mbCount) = y - i;    % row co-ordinate for the vector
            vectors(2,mbCount) = x - j;    % col co-ordinate for the vector  

            vectorShift(1,mbCount) = y - i;
            vectorShift(2,mbCount) = x - j;
            vectorShift(3,mbCount) = i;
            vectorShift(4,mbCount) = j;

            mbCount = mbCount + 1;
            costs = ones(1,6) * 65537;

            checkMatrix = zeros(2*p+1,2*p+1);
        end
    end

    motionVect = vectors;
    
end
    
    
 