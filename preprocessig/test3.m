clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
fontSize = 14;

% Read in a standard MATLAB gray scale demo image.
folder = 'C:\Users\ahmed\Documents\Temporary';
baseFileName = 'image_a.JPG';
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
% Check if file exists.
if ~exist(fullFileName, 'file')
	% File doesn't exist -- didn't find it there.  Check the search path for it.
	fullFileName = baseFileName; % No path this time.
	if ~exist(fullFileName, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end
grayImage = imread(fullFileName);
% Get the dimensions of the image.  
% numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(grayImage);
if numberOfColorBands > 1
	% It's not really gray scale like we expected - it's color.
	% Convert it to gray scale by taking only the green channel.
	grayImage = grayImage(:, :, 2); % Take green channel.
end
% Display the original gray scale image.
subplot(2, 2, 1);
imshow(grayImage, []);
axis on;
title('Original Grayscale Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 

% Let's compute and display the histogram.
[pixelCount, grayLevels] = imhist(grayImage);
pixelCount(end) = 0; % Suppress spike so we can see shape.
subplot(2, 2, 2); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of original image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.

verticalProfile = mean(grayImage, 2);
subplot(2, 2, 3);
plot(verticalProfile);
% Find the white spaces
whiteGaps = verticalProfile > 250;
% Get the centroids of the white gaps
measurements = regionprops(whiteGaps, 'Centroid');
allCentroids = [measurements.Centroid];
centroidX = allCentroids(1:2:end);
centroidY = allCentroids(2:2:end);
% Now we have the lines to crop out.
% Make a new figure
binaryImage = grayImage < 125;
for k = 1 : length(centroidY)-1
	line1 = int32(centroidY(k));
	line2 = int32(centroidY(k+1));
	thisLine = binaryImage(line1:line2, :);
	subplot(2,4,k);
	imshow(thisLine);
	caption = sprintf('Line #%d', k);
	title(caption, 'FontSize', fontSize);
end

