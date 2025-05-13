function state = identifyState(plateText)
    % Initialize state
    state = 'Unknown';
    
    % Check if plateText is empty
    if isempty(plateText)
        return;
    end

    plateText = strtrim(plateText);
    if isempty(plateText)
        return;
    end
     
    % Check for diplomatic plates (containing hyphens)
    if contains(plateText, '-')
        state = 'Diplomatic';
        return;
    end
    
    % If not diplomatic, continue with regular state identification
    if ~isempty(plateText)
        firstChar = plateText(1);
        
        % Standard single-letter mapping
        switch firstChar
            case 'A'
                state = 'Perak';
            case 'B'
                state = 'Selangor';
            case 'C'
                state = 'Pahang';
            case 'D'
                state = 'Kelantan';
            case 'F'
                state = 'Putrajaya';
            case 'J'
                state = 'Johor';
            case 'K'
                state = 'Kedah';
            case 'M'
                state = 'Malacca';
            case 'N'
                state = 'Negeri Sembilan';
            case 'P'
                state = 'Penang';
            case 'R'
                state = 'Perlis';
            case 'S'
                state = 'Sabah';
            case 'T'
                state = 'Terengganu';
            case 'V'
                state = 'Kuala Lumpur';
            case 'W'
                state = 'Kuala Lumpur';
            case 'Z'
                state = 'Military';
            otherwise
                % If starts with a number, likely special plate
                if ~isempty(firstChar) && isstrprop(firstChar, 'digit')
                    state = 'Special';
                end
        end
    end
end