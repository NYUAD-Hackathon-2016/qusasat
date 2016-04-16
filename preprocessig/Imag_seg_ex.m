%% Image segmentation and extraction
%% Read Image
imagen=imread('New test.jpg');
original=imagen;
%% Show image
figure(1)
imshow(imagen);
title('INPUT IMAGE WITH NOISE')
%% Convert to gray scale
if size(imagen,3)==3 % RGB image
    imagen=rgb2gray(imagen);
end
%% Blur image
imagen=imgaussfilt(imagen, 4, 'FilterSize', 31);
imshow(imagen);
%% Convert to binary image
threshold = graythresh(imagen);
imagenBin =~im2bw(imagen,threshold);
%% Remove all object containing fewer than 30 pixels
imagenBin = bwareaopen(imagenBin,1);
pause(1)
%% Show image binary image
figure(2)
imshow(~imagenBin);
title('INPUT IMAGE WITHOUT NOISE')
%% Label connected components
[L Ne]=bwlabel(imagenBin);
%% Measure properties of image regions
propied=regionprops(L,'BoundingBox');
hold on
%% Blur based on avg rectangle size
for n=1:size(propied,1)
    avg1=mean(propied(n).BoundingBox(1,3));
    avg2=mean(propied(n).BoundingBox(1,4));
end
gsize=[avg1 avg2];
imagen=imgaussfilt(imagen, 'FilterSize', 11);

%% Plot Bounding Box
for n=1:size(propied,1)
    rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
    propied(n).BoundingBox
end
hold off
pause (1)
%% Remove figures
% for n=1:Ne
%     [r,c] = find(L==n);
%     
%         
%     
%     n1=original(min(r):max(r),min(c):max(c));
%     imshow(n1);
%     pause(0.5)
% end
%% Lines identification
[linesMapr linesMapc] = size(imagenBin);
linesmap=not(zeros(linesMapr,1));
for r=1:linesMapr
    for c=1:linesMapc
        if(imagenBin(r,c)==1)
            linesmap(r,1)=0;
            if (r<linesMapr)
                r=r+1;
            end
        end
    end
end
figure (3)
imshow(linesmap)


%% Objects extraction
% figure (4)
% for n=1:Ne
%     [r,c] = find(L==n);
%     
%         
%     
%     n1=original(min(r):max(r),min(c):max(c));
%     imshow(n1);
%     pause(0.5)
% end