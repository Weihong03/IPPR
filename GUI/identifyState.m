function state = identifyState(plateText)
    % Initialize state
    state = 'Unknown';
    
    % Check if plateText is empty
    if isempty(plateText)
        return;
    end

    % Process input once at the beginning
    plateText = upper(strtrim(plateText));
    if isempty(plateText)
        return;
    end
    
    % Store length for efficiency
    len = length(plateText);
     
    % Check for diplomatic plates (containing hyphens)
    if contains(plateText, '-')
        state = 'Diplomatic';
        % Examples: PA-1234-DC, PB-5678-DC (Diplomatic Corps)
        return;
    end
    
    % Check for commemorative/special plates (prioritizing more specific/longer prefixes)
    if len >= 5 && strcmp(plateText(1:5), 'SUKOM')
        state = 'Commemorative - Commonwealth Games 1998';
        return;
    elseif len >= 8 && strcmp(plateText(1:8), 'MALAYSIA')
        state = 'Malaysia Special Series';
        return;
    elseif len >= 5 && strcmp(plateText(1:5), 'LIMO ')
        state = 'Airport Limousine';
        return;
    elseif len >= 8 && strcmp(plateText(1:8), 'PUTRAJAYA')
        state = 'Putrajaya';
        return;
    elseif len >= 3 && strcmp(plateText(1:3), 'JDT')
        state = 'Commemorative - Johor Darul Takzim';
        return;
    elseif len >= 3 && strcmp(plateText(1:3), 'G1M')
        state = 'Commemorative - Gagasan 1Malaysia';
        return;
    elseif len >= 4 && strcmp(plateText(1:4), '1M4U')
        state = 'Commemorative - 1Malaysia for Youth';
        return;
    
    % Check for EV prefix (Electric Vehicles)
    elseif len >= 2 && strcmp(plateText(1:2), 'EV')
        state = 'Electric Vehicle';
        return;
    end
    
    % Check for two or three-letter prefixes
    if len >= 2
        firstTwoChars = plateText(1:min(2, len));
        
        % Check for Langkawi
        if strcmp(firstTwoChars, 'KV')
            state = 'Langkawi';
            return;
        end
        
        % Check for taxis (H prefix followed by state letter)
        if firstTwoChars(1) == 'H' && len >= 2
            taxiState = plateText(2);
            state = 'Taxi - ';
            
            switch taxiState
                case 'A'
                    state = [state, 'Perak'];
                case 'B'
                    state = [state, 'Selangor'];
                case 'C'
                    state = [state, 'Pahang'];
                case 'D'
                    state = [state, 'Kelantan'];
                case 'J'
                    state = [state, 'Johor'];
                case 'K'
                    state = [state, 'Kedah'];
                case 'L'
                    state = [state, 'Labuan'];
                case 'M'
                    state = [state, 'Malacca'];
                case 'N'
                    state = [state, 'Negeri Sembilan'];
                case 'P'
                    state = [state, 'Penang'];
                case 'Q'
                    state = [state, 'Sarawak'];
                case 'R'
                    state = [state, 'Perlis'];
                case 'S'
                    state = [state, 'Sabah'];
                case 'T'
                    state = [state, 'Terengganu'];
                case 'W'
                    state = [state, 'Kuala Lumpur'];
                otherwise
                    state = [state, 'Unknown'];
            end
            return;
        end
    end
    
    % Check for special prefixes with multiple characters
    if len >= 2
        firstChar = plateText(1);
        
        % Handle Sarawak plates (Q prefix)
        if firstChar == 'Q' && len >= 2
            state = 'Sarawak - ';
            
            % Check if it's Sarawak Government first (QSG)
            if len >= 3 && strcmp(plateText(1:3), 'QSG')
                state = 'Sarawak Government';
                return;
            end
            
            if len >= 2
                sarawakDivision = plateText(2);
                switch sarawakDivision
                    case 'A'
                        state = [state, 'Kuching'];
                    case 'B'
                        state = [state, 'Sri Aman/Betong'];
                    case 'C'
                        state = [state, 'Samarahan/Serian'];
                    case 'D'
                        state = [state, 'Bintulu'];
                    case 'K'
                        state = [state, 'Kuching'];
                    case 'L'
                        state = [state, 'Limbang'];
                    case 'M'
                        state = [state, 'Miri'];
                    case 'P'
                        state = [state, 'Kapit'];
                    case 'R'
                        state = [state, 'Sarikei'];
                    case 'S'
                        state = [state, 'Sibu/Mukah'];
                    case 'T'
                        state = [state, 'Bintulu'];
                    otherwise
                        state = 'Sarawak'; % Default to Sarawak if no specific division matches
                end
            else
                state = 'Sarawak';
            end
            return;
        end
        
        % Handle Sabah plates (S prefix)
        if firstChar == 'S' && len >= 2
            % Check if it's Sabah Government first
            if len >= 2 && plateText(2) == 'G'
                state = 'Sabah Government';
                return;
            elseif len >= 3 && strcmp(plateText(1:3), 'SMJ')
                state = 'Sabah Government';
                return;
            end
            
            state = 'Sabah - ';
            if len >= 2
                sabahDivision = plateText(2);
                switch sabahDivision
                    case 'A'
                        state = [state, 'West Coast'];
                    case 'B'
                        state = [state, 'Beaufort'];
                    case 'D'
                        state = [state, 'Lahad Datu'];
                    case 'J'
                        state = [state, 'Kota Kinabalu'];
                    case 'K'
                        state = [state, 'Kudat'];
                    case 'M'
                        state = [state, 'Sandakan'];
                    case 'S'
                        state = [state, 'Sandakan'];
                    case 'T'
                        state = [state, 'Tawau'];
                    case 'U'
                        state = [state, 'Keningau'];
                    case 'W'
                        state = [state, 'Tawau'];
                    case 'Y'
                        state = [state, 'West Coast'];
                    otherwise
                        state = 'Sabah'; % Default to Sabah if no specific division matches
                end
            else
                state = 'Sabah';
            end
            return;
        end
    end
    
    % Look at first character for basic identification
    if len >= 1
        firstChar = plateText(1);
        
        % Extended military vehicle identification (Z prefix)
        if firstChar == 'Z'
            if len >= 2
                militaryBranch = plateText(2);
                switch militaryBranch
                    case 'L'
                        state = 'Military - Royal Malaysian Navy';
                    case 'U'
                        state = 'Military - Royal Malaysian Air Force';
                    case 'A'
                        state = 'Military - Malaysian Army';
                    case 'B'
                        state = 'Military - Malaysian Army';
                    case 'C'
                        state = 'Military - Malaysian Army';
                    case 'D'
                        state = 'Military - Malaysian Army';
                    case 'Z'
                        state = 'Military - Ministry of Defense';
                    otherwise
                        state = 'Military';
                end
            else
                state = 'Military';
            end
            return;
        end
        
        % Standard single-letter mapping for Peninsular Malaysia
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
            case 'L'
                state = 'Labuan';
            case 'M'
                state = 'Malacca';
            case 'N'
                state = 'Negeri Sembilan';
            case 'P'
                state = 'Penang';
            case 'R'
                state = 'Perlis';
            case 'T'
                state = 'Terengganu';
            case 'V'
                state = 'Kuala Lumpur';
            case 'W'
                state = 'Kuala Lumpur';
            otherwise
                % Explicitly check if it starts with a number - likely special plate
                if isstrprop(firstChar, 'digit')
                    state = 'Special';
                end
        end
    end
end