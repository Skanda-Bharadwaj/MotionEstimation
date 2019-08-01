********************************************************************************
**************************** RUNNING INSTRUCTIONS ******************************
********************************************************************************

motionEstimation.m

	Run this script to perform ARPS block matching. This script loads the datset,
	initializes all parameters, calls ARPS.m, reconstructImage.m and writeVideo.m.
	Creates a subplot of current frame, reference frame, reconstructed image and 
	the difference image. It also draws the motion vectors and creates a videos.

ARPS.m
	
	This scripts implements the Adaptive Rood Pattern Search algorithm for block
	matching. It calls the function calculateMAD.m to find the cost. 

calculateMAD.m
	
	Implements Mean Absolute difference as cost function.

reconstructImage.m
	
	This script reconstructs the image from the reference frame using the motion 
	vectors. 

writeVideo.m
	
	Given a set of frames, this scripts creates a video of the format .avi


**********************************************************************************
****************************** Caller Graph **************************************
**********************************************************************************

motionEstimation.m
	|
	|------>ARPS.m
	|		|---->calculateMAD.m
	|              
	|------>reconstructImage.m
	|
	|------>writeVideo.m

**********************************************************************************