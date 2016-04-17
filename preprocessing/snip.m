function snip(image)
    %% Image segmentation and extraction
    %% Read Image
    %imagen=imread('test2.jpg');
    imagen=imread(image);
    original=imagen;
    %% Show image
    figure(1)
    imshow(imagen);
    title('INPUT IMAGE WITH NOISE')
    %% Convert to gray scale
    if size(imagen,3)==3 % If it is an RGB image
        imagen=rgb2gray(imagen);
    end
    %% Blur image
    imagen=imgaussfilt(imagen, 6, 'FilterSize', 71); %Blur to reduce fragmentation
    %imagen=imgaussfilt(imagen, 20, 'FilterSize', [15,1]); % Severly blur
    %virtically to include the whole snippet
    % imshow(imagen);
    %% Convert to binary image
    threshold = graythresh(imagen);
    imagenBin =~im2bw(imagen,threshold);
    %% Remove all object containing fewer than 30 pixels
    imagenBin = bwareaopen(imagenBin,1);
    %% Show image binary image
    % figure(2)
    % imshow(~imagenBin);
    %title('INPUT IMAGE WITHOUT NOISE')
    %% Label connected components
    [L, Ne]=bwlabel(imagenBin);
    %% Measure properties of image regions
    propied=regionprops(L,'BoundingBox');
    hold on
    %% Plot Bounding Box
    figure(3)
    imshow(original);
    title('DETECTED SNIPPETS')
    for n=1:size(propied,1)
        rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
    end
    hold off
    %% Draw lines
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

    for r=1:length(linesMap)
        if (linesMap(r)==1)
            imagenBin(r,:)=1;
        end
    end

    %  figure(4)
    %  imshow (~imagenBin);
    %% Objects extraction
    boxes=zeros(length(propied(:,1)),4);
    for r=1:length(propied(:,1))
        boxes(r,:)=propied(r).BoundingBox;
    end

    search=1; %an index to search for words through each line

    sortedSnippets=sortrows(boxes,2); %sorted boxes stack
    firstBox=1; %an index to keep track of the first word in a line foun in the stack
    beg=2; %an index to keep track of the first row in a line
    wend=0; %an index to keep track of the last row in a line
    flushed=1; %a flag to make sure that all the words 
    %from the last detected line were popped from the stack

    name=1; %an index to keep track of snippets naming

    for r=2:length(imagenBin(:,1)) %go through the image looking for already drown lines

        if(imagenBin(r)==0 && imagenBin(r-1)==1) %check for the beginning of a line
            beg=r;
            flushed=1;
        elseif (imagenBin(r)==1 && imagenBin(r-1)==0) %check for the end of a line
            wend=r;
            flushed=0;
        end

        if(wend>beg && flushed==0)  %check if it's itirating within a line 
            firstBox=search;        %and if there are still words from the stack
                                    %in the current line to be popped

            while (wend>sortedSnippets(search,2))      %go through the stack checking for
                search=search+1;                    %for words in the current line
                if(search>length(sortedSnippets(:,1))) %given the end of the line
                    break;
                end
            end

            %sort snippets in the same line based on their horizental
            %coordinates
            csSnippets=[sortrows(sortedSnippets(firstBox:search-1,:), 1), not(zeros(search-firstBox, 1))];

            for SSr=1:length(csSnippets(:,1)) %remove replicas and intersected snippets
                for SSc=1:length(csSnippets(:,1))
                    if((csSnippets(SSr,1)>csSnippets(SSc,1) && csSnippets(SSr,1)<csSnippets(SSc,1)+csSnippets(SSc,3)) || (csSnippets(SSr,1)+csSnippets(SSr,3)>csSnippets(SSc,1) && csSnippets(SSr,1)+csSnippets(SSr,3)<csSnippets(SSc,1)+csSnippets(SSc,3)))
                        if(csSnippets(SSr,3)<csSnippets(SSc,3))
                            csSnippets(SSr,5)=0;
                            
                        else
                            csSnippets(SSc,5)=0;
                        end
                    end
                end
            end

            for c=length(csSnippets(:,1)):-1:1 %enhance snippets dimentions & save them
                if(csSnippets(c,5)==1)
                    y1=beg;
                    y2=wend;
                    x1=floor(csSnippets(c,1));
                    x2=floor(csSnippets(c,1))+csSnippets(c,3);

                    unpaddedImg=original(y1:y2,x1:x2);

                    [iR, iC]=size(unpaddedImg);
                    finalImg=unpaddedImg;

                    if(iR>400) %check if the image hieght is higher than 400 and resize it
                        unpaddedImg = imresize(unpaddedImg,[400 NaN]);
                        finalImg = imresize(unpaddedImg,[400 NaN]);
                        [fR, fC]=size(finalImg);
                        %check if the image width is still higher than 600 and resize it agin
                        if(fC>600) 
                            finalImg = imresize(finalImg,[NaN 600]);
                            unpaddedImg = imresize(finalImg,[NaN 600]);
                        end
                    end

                    if(iC>600) %check if the image width is higher than 600 and resize it agin
                        unpaddedImg = imresize(unpaddedImg,[NaN 600]);
                        finalImg = imresize(unpaddedImg,[NaN 600]);
                        [fR,fC]=size(finalImg);
                        %check if the image hieght is still higher than 400 and resize it
                        if(fR>400)
                            unpaddedImg = imresize(finalImg,[400 NaN]);
                            finalImg = imresize(finalImg,[400 NaN]);
                        end
                    end

                    [fR, fC]=size(finalImg); %check the size of the final image for padding

                    %padd with white space on all sides
                    finalImg=padarray(finalImg,[floor((400-fR)/2),floor((600-fC)/2)],255,'both');

                    [fR, fC]=size(finalImg); %check size after padding on all sizes

                    %padd on one side to fill odd left spaces
                    finalImg=padarray(finalImg,[400-fR,600-fC],255,'pre');

    %                 figure(5)
    %                 imshow(finalImg);
    %                 pause(0.5);

                    %save images in a sequence
                    imwrite(finalImg,sprintf('/Users/Abdullah/Documents/qusasat/preprocessig/samples/img%03d.png',name));
                    name=name+1;
                end
            end
            flushed=1; %mark that all words in a line are popped from a stack
        end
        if(search>length(sortedSnippets(:,1)))
            break;
        end
    end
end