%% Image segmentation and extraction
%% Read Image
imagen=imread('aze.jpg');
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
imagen=imgaussfilt(imagen, 6, 'FilterSize', 71);
imagen=imgaussfilt(imagen, 20, 'FilterSize', [15,1]);
imshow(imagen);
%% Convert to binary image
threshold = graythresh(imagen);
imagenBin =~im2bw(imagen,threshold);
%% Remove all object containing fewer than 30 pixels
imagenBin = bwareaopen(imagenBin,1);
%% Show image binary image
figure(2)
imshow(~imagenBin);
title('INPUT IMAGE WITHOUT NOISE')
%% Label connected components
[L, Ne]=bwlabel(imagenBin);
%% Measure properties of image regions
propied=regionprops(L,'BoundingBox');
hold on
%% Blur based on avg rectangle size
for n=1:size(propied,1)
    avg1=mean(propied(n).BoundingBox(1,3));
    avg2=mean(propied(n).BoundingBox(1,4));
end
%% Plot Bounding Box
for n=1:size(propied,1)
    rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
end
hold off
%% Lines identification
[linesMapr, linesMapc] = size(imagenBin);
 linesMap=not(zeros(linesMapr,1));
 for r=1:linesMapr
     for c=1:linesMapc
         if(imagenBin(r,c)==1)
             linesMap(r,1)=0;
             if (r<linesMapr)
                 r=r+1;
             end
         end
     end
 end
 breaksMap=zeros(linesMapr,linesMapc);
 breaksCounter=0;
 
for r=1:length(linesMap)
    if (linesMap(r)==1)
        imagenBin(r,:)=1;
    end
end
 
 figure(3)
 imshow (~imagenBin);
%% Objects extraction
boxes=zeros(length(propied(:,1)),4);
for r=1:length(propied(:,1))
    boxes(r,:)=propied(r).BoundingBox;
end

sortedBoxes=sortrows(boxes,2);
search=1;
firstBox=1;
wend=0;
beg=2;
name=1;
flushed=1;
for r=2:length(imagenBin(:,1))
    
    if(imagenBin(r)==0 && imagenBin(r-1)==1)
        beg=r;
        flushed=1;
    elseif (imagenBin(r)==1 && imagenBin(r-1)==0)
        wend=r;
        flushed=0;
    end
    
    if(wend>beg && flushed==0)
        firstBox=search;
        
        while (wend>sortedBoxes(search,2))
            search=search+1;
            if(search>length(sortedBoxes(:,1)))
                break;
            end
        end
        
        SSBoxes=[sortrows(sortedBoxes(firstBox:search-1,:), 1), not(zeros(search-firstBox, 1))];
        
        for SSr=1:length(SSBoxes(:,1))
            for SSc=1:length(SSBoxes(:,1))
                if((SSBoxes(SSr,1)>SSBoxes(SSc,1) && SSBoxes(SSr,1)<SSBoxes(SSc,1)+SSBoxes(SSc,3)) || (SSBoxes(SSr,1)+SSBoxes(SSr,3)>SSBoxes(SSc,1) && SSBoxes(SSr,1)+SSBoxes(SSr,3)<SSBoxes(SSc,1)+SSBoxes(SSc,3)))
                    if(SSBoxes(SSr,3)<SSBoxes(SSc,3))
                        SSBoxes(SSr,5)=0;
                    else
                        SSBoxes(SSc,5)=0;
                    end
                end
            end
        end
    
        for c=length(SSBoxes(:,1)):-1:1
            if(SSBoxes(c,5)==1)
                y1=beg;
                y2=wend;
                x1=floor(SSBoxes(c,1));
                x2=floor(SSBoxes(c,1))+SSBoxes(c,3);

                n1=original(y1:y2,x1:x2);

                [n1r, n1c]=size(n1);
                n2=n1;
                if(n1r>400)
                    n1 = imresize(n1,[400 NaN]);
                    n2 = imresize(n1,[400 NaN]);
                    [n2r, n2c]=size(n2);
                    if(n2c>600)
                        n2 = imresize(n2,[NaN 600]);
                        n1 = imresize(n2,[NaN 600]);
                    end
                end

                if(n1c>600)
                    n1 = imresize(n1,[NaN 600]);
                    n2 = imresize(n1,[NaN 600]);
                    [n2r,n2c]=size(n2);
                    if(n2r>400)
                        n1 = imresize(n2,[400 NaN]);
                        n2 = imresize(n2,[400 NaN]);
                    end
                end

                [n2r, n2c]=size(n2);

                n2=padarray(n2,[floor((400-n2r)/2),floor((600-n2c)/2)],255);
                [n2r, n2c]=size(n2);
                figure(7)
                imshow(n2);
                pause(0.5);
                imwrite(n2,sprintf('/Users/Abdullah/Documents/qusasat/preprocessig/samples/img%03d.png',name));
                name=name+1;
            end
        end
        flushed=1;
    end
    if(search>length(sortedBoxes(:,1)))
        break;
    end
end