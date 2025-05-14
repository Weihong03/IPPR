function [plateRegion, bbox, detFigHandle] = detectLicensePlate(img, vehicleType)
    % Unified license plate detection function
    % Input:
    %   img - Input image
    %   vehicleType - String: 'Car', 'Motorcycle', 'Bus', or 'Truck'
    % Output:
    %   plateRegion - Cropped license plate region
    %   bbox - Bounding box coordinates [x, y, width, height]
    
    plateRegion = [];
    bbox = [];
    detFigHandle = [];
    
    % Convert to grayscale if it's a color image
    if size(img, 3) == 3
        grayImg = rgb2gray(img);
    else
        grayImg = img;
    end
    
    % Debug visualization with configured window
    detFigHandle = figure('Name', ['License Plate Detection - ' vehicleType], ...
                          'Color', [0.9294 0.9412 0.9412], ... % Match app background color
                          'Position', [100, 100, 800, 600]); % Set initial size
    
    % Get the current screen size
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);
    
    % Position the window on the left half of the screen, centered
    figPosition = get(detFigHandle, 'Position');
    figWidth = figPosition(3);
    figHeight = figPosition(4);
    
    % Calculate position for left half center alignment
    newLeft = (screenWidth/2 - figWidth)/2; % Center of left half
    newTop = (screenHeight - figHeight)/2; % Vertical center
    
    % Set the new position
    set(detFigHandle, 'Position', [newLeft, newTop, figWidth, figHeight]);
    
    subplot(2,4,1), imshow(grayImg), title('Original Grayscale');
    
    % Enhance contrast
    grayImg = imadjust(grayImg);
    subplot(2,4,2), imshow(grayImg), title('Enhanced Contrast');
    
    % Apply Gaussian blur
    grayImg = imgaussfilt(grayImg, 1);
    
    % Set vehicle-specific parameters
    switch vehicleType
        case 'Car'
            edgeThresh = [0.1 0.3];
            seSize = [3, 15];
            areaThresh = 300;
            aspectRatioMin = 1.5;
            aspectRatioMax = 8.0;
            aspectRatioTarget = 3.5;
            areaWeight = 0.2;
            extentWeight = 0.2;
            aspectWeight = 0.3;
            positionWeight = 0.3;
            usePositionScore = true;
            applyHeightPadding = false;
            
        case 'Motorcycle'
            edgeThresh = [0.1 0.3];
            seSize = [3, 10];
            areaThresh = 200;
            aspectRatioMin = 1.56;
            aspectRatioMax = 3.94;
            aspectRatioTarget = 3.0;
            areaWeight = 0.2;
            extentWeight = 0.3;
            aspectWeight = 0.6;
            positionWeight = 0;
            usePositionScore = false;
            applyHeightPadding = true;  % Enable height padding for motorcycles
            
        case 'Bus'
            edgeThresh = [0.1 0.3];
            seSize = [3, 15];
            areaThresh = 300;
            aspectRatioMin = 2.0;
            aspectRatioMax = 5.0;
            aspectRatioTarget = 3.5;
            areaWeight = 0.3;
            extentWeight = 0.3;
            aspectWeight = 0.4;
            positionWeight = 0;
            usePositionScore = false;
            applyHeightPadding = false;
            
        case 'Truck'
            edgeThresh = [0.1 0.3];
            seSize = [3, 15];
            areaThresh = 300;
            aspectRatioMin = 3.99;
            aspectRatioMax = 4.50;
            aspectRatioTarget = 3.5;
            areaWeight = 0.3;
            extentWeight = 0.3;
            aspectWeight = 0.4;
            positionWeight = 0;
            usePositionScore = false;
            applyHeightPadding = false;
            
        otherwise
            error('Invalid vehicle type: %s', vehicleType);
    end
    
    % Edge detection with vehicle-specific parameters
    edgeImg = edge(grayImg, 'canny', edgeThresh);
    subplot(2,4,3), imshow(edgeImg), title('Edge Detection');
    
    % Morphological operations with vehicle-specific structuring element
    se1 = strel('rectangle', seSize);
    closedImg = imclose(edgeImg, se1);
    subplot(2,4,4), imshow(closedImg), title('Morphological Close');
    
    % Fill holes
    filledImg = imfill(closedImg, 'holes');
    subplot(2,4,5), imshow(filledImg), title('Fill Holes');
    
    % Remove small objects
    cleanImg = bwareaopen(filledImg, areaThresh);
    subplot(2,4,6), imshow(cleanImg), title('Remove Small Objects');
    
    % Find connected components
    cc = bwconncomp(cleanImg);
    stats = regionprops(cc, 'BoundingBox', 'Area', 'Extent', 'Image');
    
    % Visualization
    imgWithBoxes = img;
    if size(imgWithBoxes, 3) == 1
        imgWithBoxes = repmat(imgWithBoxes, [1, 1, 3]);
    end
    
    % Initialize variables
    plateRegion = [];
    bbox = [];
    maxScore = 0;
    
    % Draw all candidates
    for i = 1:length(stats)
        currBbox = stats(i).BoundingBox;
        aspectRatio = currBbox(3) / currBbox(4);
        
        imgWithBoxes = insertShape(imgWithBoxes, 'Rectangle', currBbox, 'LineWidth', 2, 'Color', 'blue');
        text_position = [currBbox(1), currBbox(2)-10];
        imgWithBoxes = insertText(imgWithBoxes, text_position, sprintf('AR: %.2f', aspectRatio), 'FontSize', 12, 'BoxColor', 'yellow', 'TextColor', 'black');
    end
    
    subplot(2,4,7), imshow(imgWithBoxes), title('All Candidate Regions');
    
    % Special handling for motorcycle if needed
    if strcmp(vehicleType, 'Motorcycle') && isempty(stats)
        % Apply the special case code for motorcycles here
        [rows, cols, ~] = size(img);
        centerCol = cols / 2;
        
        % Define a region of interest in the bottom third of the image
        roiTop = round(rows * 0.6);
        roiWidth = round(cols * 0.5);
        roiLeft = max(1, round(centerCol - roiWidth/2));
        roiHeight = round(rows * 0.25);
        
        plateRegion = img(roiTop:min(rows, roiTop+roiHeight), roiLeft:min(cols, roiLeft+roiWidth), :);
        bbox = [roiLeft, roiTop, roiWidth, roiHeight];
        
        subplot(2,4,8), imshow(plateRegion), title('Detected Plate');
        return;
    end
    
    % Loop through components and find plates using vehicle-specific criteria
    for i = 1:length(stats)
        currBbox = stats(i).BoundingBox;
        aspectRatio = currBbox(3) / currBbox(4);
        
        if aspectRatio > aspectRatioMin && aspectRatio < aspectRatioMax
            % Score calculation
            areaScore = min(stats(i).Area / 8000, 1);
            extentScore = stats(i).Extent;
            aspectScore = 1 - abs(aspectRatio - aspectRatioTarget) / 2.0;
            
            % Position score calculation (used mainly for cars)
            positionScore = 0;
            if usePositionScore
                centerX = currBbox(1) + currBbox(3)/2;
                centerY = currBbox(2) + currBbox(4)/2;
                relativeX = centerX / size(img, 2);
                relativeY = centerY / size(img, 1);
                positionScore = (relativeY - 0.5) * (1 - 2 * abs(relativeX - 0.5));
                positionScore = max(0, positionScore);
            end
            
            % Calculate final score with vehicle-specific weights
            score = areaScore * areaWeight + extentScore * extentWeight + ...
                   aspectScore * aspectWeight + positionScore * positionWeight;
            
            if score > maxScore
                maxScore = score;
                bbox = round(currBbox);
                
                % Apply height padding for motorcycle plates
                if applyHeightPadding
                    heightPadding = round(bbox(4) * 0.1);
                    bbox(2) = max(1, round(bbox(2) - heightPadding)); % Move up (y position)
                    bbox(4) = bbox(4) + 1.9 * heightPadding;          % Increase height
                    
                    % Make sure the box doesn't go outside the image
                    if bbox(2) + bbox(4) > size(img, 1)
                        bbox(4) = size(img, 1) - bbox(2);
                    end
                end
                
                % Extract the plate region
                x = max(1, round(bbox(1)));              % Ensure x is an integer
                y = max(1, round(bbox(2)));              % Ensure y is an integer
                width = min(size(img, 2) - x, round(bbox(3)));   % Ensure width is an integer
                height = min(size(img, 1) - y, round(bbox(4)));  % Ensure height is an integer
                
                if x+width <= size(img, 2) && y+height <= size(img, 1)
                    plateRegion = img(y:y+height, x:x+width, :);
                end
            end
        end
    end
    
    % Show result
    if ~isempty(plateRegion)
        subplot(2,4,8), imshow(plateRegion), title('Detected Plate');
    else
        subplot(2,4,8), title('No plate detected');
    end
    
    % Make images fill their space better
    set(findall(gcf,'type','axes'), 'Box', 'off', 'XColor', 'none', 'YColor', 'none');
    set(gcf, 'DefaultAxesLooseInset', [0,0,0,0]);
end