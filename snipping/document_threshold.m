% Demo to threshold a document with text where the image is noisy and
% there is severe non-uniformity of illumination.
function document_threshold()
clc;
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;

% Check that user has the Image Processing Toolbox installed.
hasIPT = license('test', 'image_toolbox');
if ~hasIPT
	% User does not have the toolbox installed.
	message = sprintf('Sorry, but you do not seem to have the Image Processing Toolbox.\nDo you want to try to continue anyway?');
	reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
	if strcmpi(reply, 'No')
		% User said No, so exit.
		return;
	end
end

% Read in gray scale demo image.
folder = pwd; % Change this if the image is not in the same folder as this m-file.
baseFileName = 'Lincoln_Letter.png';
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
subplot(2, 3, 1);
imshow(grayImage, []);
axis on;
title('Original Grayscale Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Give a name to the title bar.
set(gcf, 'Name', 'Demo to Threshold Document', 'NumberTitle', 'Off') 

% Let's compute and display the histogram.
[pixelCount, grayLevels] = imhist(grayImage);
subplot(2, 3, 2); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Original Image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.

% Do a local Otsu of the gray level image.
fun = @(x) LocalOtsu(x); 
A = im2double(grayImage);
localThresh = nlfilter(A, [15, 15], fun); 
% Display the image.
subplot(2, 3, 3);
imshow(localThresh, []);
title('Local Otsu', 'FontSize', fontSize);

% Do a Sobel filter
sobelImage = imgradient(grayImage, 'Sobel');
% Display the image.
subplot(2, 3, 4);
imshow(sobelImage, []);
title('Sobel Image', 'FontSize', fontSize);

% Calculate the local standard deviation
sdImage = stdfilt(sobelImage, ones(9));
% Display the image.
subplot(2, 3, 5);
imshow(sdImage, []);
title('StdDev of Sobel Image', 'FontSize', fontSize);
% binsToSuppress = [1];
% [lowThreshold, highThreshold, lastThresholdedBand]=threshold(83, 255, sdImage, binsToSuppress);

% Do a global Otsu of the stddev image.
% Threshold the center pixel only.
binaryImage = sdImage > 50;
% Display the image.
subplot(2, 3, 6);
imshow(binaryImage, []);
title('Thresholded StdDev Image', 'FontSize', fontSize);

% AND the two images to produce the final image.
finalImage = ~(localThresh & binaryImage);
% Display the image.
figure;
subplot(1, 2, 1);
imshow(grayImage, []);
fontSize = 40;
title('Initial Image', 'FontSize', fontSize);
subplot(1, 2, 2);
imshow(finalImage, []);
title('Final Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Give a name to the title bar.
set(gcf, 'Name', 'Demo to Threshold Document - Final Results', 'NumberTitle', 'Off') 


% Function to take the Otsu threshold of the small patch of gray levels passed in by nlfilter().
function oneThresholdedPixel = LocalOtsu(grayImagePatch)
	oneThresholdedPixel = false;
	try
		[rows, columns] = size(grayImagePatch);
		middleRow = ceil(rows/2);
		middleColumn = ceil(columns/2);
		level = graythresh(grayImagePatch);
		% Threshold the center pixel only.
		oneThresholdedPixel = ~im2bw(grayImagePatch(middleRow, middleColumn), level);
	catch ME
		errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
			ME.stack(1).name, ME.stack(1).line, ME.message);
		fprintf(1, '%s\n', errorMessage);
		uiwait(warndlg(errorMessage));
	end
	return; % from LocalOtsu()


