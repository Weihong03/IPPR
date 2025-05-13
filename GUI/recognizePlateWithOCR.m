function plateText = recognizePlateWithOCR(plateImage)
    % Preprocess the plate image for OCR
    if size(plateImage, 3) == 3
        grayPlate = rgb2gray(plateImage);
    else
        grayPlate = plateImage;
    end
    
    % Display original grayscale for debugging
    figure('Name', 'OCR Preprocessing');
    subplot(2,3,1), imshow(grayPlate), title('Original Grayscale');
    
    % Enhance contrast - using a different method to highlight edges
    enhancedPlate = adapthisteq(grayPlate); % Use CLAHE instead of imadjust
    subplot(2,3,2), imshow(enhancedPlate), title('Enhanced Contrast');
    
    % Create sharper edges 
    sharpenedPlate = imsharpen(enhancedPlate, 'Radius', 2, 'Amount', 1.5);
    
    % Standard binary image but with local adaptive threshold
    binaryPlate = imbinarize(sharpenedPlate, 'adaptive', 'Sensitivity', 0.4);
    binaryPlate = ~binaryPlate; % Invert so characters are white
    subplot(2,3,3), imshow(binaryPlate), title('Binary Image');
    
    % Minimal noise removal - preserve character details
    cleanPlate = bwareaopen(binaryPlate, 3);
    subplot(2,3,4), imshow(cleanPlate), title('Cleaned Binary');
    
    % Resize to a larger size for OCR
    resizedPlate = imresize(cleanPlate, 3);
    subplot(2,3,5), imshow(resizedPlate), title('Resized for OCR');
    
    % Try multiple OCR approaches with different parameters
    
    % Approach 1: Use the sharpened image directly
    ocrResults1 = ocr(sharpenedPlate, 'CharacterSet', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- ');
    
    % Approach 2: Try the binary image 
    ocrResults2 = ocr(binaryPlate, 'CharacterSet', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- ');
    
    % Approach 3: Use the clean binary
    ocrResults3 = ocr(cleanPlate, 'CharacterSet', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- ');
    
    % Approach 4: Use the resized image
    ocrResults4 = ocr(resizedPlate, 'CharacterSet', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- ');
    
    % Approach 5: Try with original grayscale
    ocrResults5 = ocr(grayPlate, 'CharacterSet', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- ');
    
    % Get the results
    text1 = strtrim(ocrResults1.Text);
    text2 = strtrim(ocrResults2.Text);
    text3 = strtrim(ocrResults3.Text);
    text4 = strtrim(ocrResults4.Text);
    text5 = strtrim(ocrResults5.Text);
    
    % Display text results
    disp('OCR Results:');
    disp(['Approach 1 (Sharpened): "', text1, '"']);
    disp(['Approach 2 (Binary): "', text2, '"']);
    disp(['Approach 3 (Clean): "', text3, '"']);
    disp(['Approach 4 (Resized): "', text4, '"']);
    disp(['Approach 5 (Original): "', text5, '"']);
    
    % Get the confidences
    conf1 = mean(ocrResults1.CharacterConfidences(~isnan(ocrResults1.CharacterConfidences)));
    conf2 = mean(ocrResults2.CharacterConfidences(~isnan(ocrResults2.CharacterConfidences)));
    conf3 = mean(ocrResults3.CharacterConfidences(~isnan(ocrResults3.CharacterConfidences)));
    conf4 = mean(ocrResults4.CharacterConfidences(~isnan(ocrResults4.CharacterConfidences)));
    conf5 = mean(ocrResults5.CharacterConfidences(~isnan(ocrResults5.CharacterConfidences)));
    
    % Display confidences
    disp('Confidences:');
    disp(['Approach 1: ', num2str(conf1)]);
    disp(['Approach 2: ', num2str(conf2)]);
    disp(['Approach 3: ', num2str(conf3)]);
    disp(['Approach 4: ', num2str(conf4)]);
    disp(['Approach 5: ', num2str(conf5)]);
    
    % Choose result using confidence and additional approaches if needed
    plateText = '';
    confidences = [conf1, conf2, conf3, conf4, conf5];
    texts = {text1, text2, text3, text4, text5};
    
    % Filter out empty or short results
    validIdx = cellfun(@(x) length(x) >= 3, texts);
    
    if any(validIdx)
        validConf = confidences(validIdx);
        validTexts = texts(validIdx);
        
        % Get the highest confidence result
        [~, maxIdx] = max(validConf);
        plateText = validTexts{maxIdx};
    end
    
    % If still no good result, try one more approach
    if isempty(plateText) || strcmpi(plateText, 'OCR_FAILED')
        % Try with a different OCR configuration
        letterResults = ocr(enhancedPlate, 'TextLayout', 'Block');
        plateText = strtrim(letterResults.Text);
    end
    
    % Clean up the text 
    if ~isempty(plateText)
        % Clean up non-alphanumeric characters
        plateText = regexprep(plateText, '[^0-9A-Za-z \-]', '');
        
        % Display final result
        subplot(2,3,6), text(0.5, 0.5, plateText, 'FontSize', 14, 'HorizontalAlignment', 'center');
        title('Final OCR Result');
        axis off;
        disp(['Final plate text: ', plateText]);
    else
        subplot(2,3,6), text(0.5, 0.5, 'OCR FAILED', 'FontSize', 14, 'HorizontalAlignment', 'center');
        title('No Valid OCR Result');
        axis off;
        plateText = 'OCR_FAILED';
        disp('OCR failed to detect any valid text.');
    end
end