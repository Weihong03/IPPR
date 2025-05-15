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

    % 1. Check for diplomatic/consular/UN/Other International Orgs (containing hyphens)
    if contains(plateText, '-')
        if endsWith(plateText, 'DC')
            state = 'Diplomatic Corps';
        elseif endsWith(plateText, 'CC')
            state = 'Consular Corps';
        elseif endsWith(plateText, 'UN')
            state = 'United Nations';
        elseif endsWith(plateText, 'PA') % Other International Organisations
            state = 'Other International Organisation';
        else
            state = 'Diplomatic/Official Vehicle'; % Generic for other hyphenated
        end
        return;
    end

    % 2. Check for specific Commemorative/Special prefixes (longest and most distinct first)
    if startsWith(plateText, 'PUTRAJAYA') % Original Putrajaya series
        state = 'Putrajaya (Original Series)';
        return;
    elseif startsWith(plateText, 'MALAYSIA')
        state = 'Commemorative - MALAYSIA Series';
        return;
    elseif startsWith(plateText, 'SUKOM')
        state = 'Commemorative - SUKOM 1998 Commonwealth Games';
        return;
    elseif startsWith(plateText, 'PATRIOT')
        state = 'Commemorative - PATRIOT Series';
        return;
    elseif startsWith(plateText, 'PERFECT')
        state = 'Commemorative - PERFECT Series';
        return;
    elseif startsWith(plateText, 'RIMAU') % 2017 SEA Games
        state = 'Commemorative - RIMAU Series';
        return;
    elseif startsWith(plateText, 'LIMO ') % KLIA Limousines
        state = 'KLIA Airport Limousine';
        return;
    elseif startsWith(plateText, 'G1M') % Gagasan 1Malaysia
        state = 'Commemorative - G1M Series';
        return;
    elseif startsWith(plateText, '1M4U') % 1Malaysia for Youth
        state = 'Commemorative - 1M4U Series';
        return;
    elseif startsWith(plateText, 'FFF') % JPJ Anniversary
        state = 'Commemorative - FFF Series (JPJ Anniversary)';
        return;
    elseif startsWith(plateText, 'GOLD') % 50th FT Day
        state = 'Commemorative - GOLD Series';
        return;
    elseif startsWith(plateText, 'JAGUH') % Modenas Jaguh
        state = 'Commemorative - JAGUH Series';
        return;
    elseif startsWith(plateText, 'NBOS')
        state = 'Commemorative - NBOS Series';
        return;
    elseif startsWith(plateText, 'NAAM')
        state = 'Commemorative - NAAM Series';
        return;
    elseif startsWith(plateText, 'MADANI')
        state = 'Commemorative - MADANI Series';
        return;
    elseif startsWith(plateText, 'JDT') % Johor Darul Takzim football club - often a vanity plate
        state = 'Commemorative/Vanity - JDT';
        return;
    % Add more distinct multi-letter commemorative prefixes here if needed
    % University Prefixes (longer ones first to avoid conflict)
    elseif startsWith(plateText, 'UNIMAS')
        state = 'Commemorative - Universiti Malaysia Sarawak'; return;
    elseif startsWith(plateText, 'UNISZA')
        state = 'Commemorative - Universiti Sultan Zainal Abidin'; return;
    elseif startsWith(plateText, 'UTeM') % Universiti Teknikal Malaysia Melaka
        state = 'Commemorative - UTeM'; return;
    elseif startsWith(plateText, 'UTHM') % Universiti Tun Hussein Onn Malaysia
        state = 'Commemorative - UTHM'; return;
    elseif startsWith(plateText, 'IIUM') % International Islamic University Malaysia
        state = 'Commemorative - IIUM'; return;
    % Shorter University Acronyms - place carefully
    elseif startsWith(plateText, 'UMK') % Universiti Malaysia Kelantan
        state = 'Commemorative - UMK'; return;
    elseif startsWith(plateText, 'UPM')
        state = 'Commemorative - Universiti Putra Malaysia'; return;
    elseif startsWith(plateText, 'USM')
        state = 'Commemorative - Universiti Sains Malaysia'; return;
    elseif startsWith(plateText, 'UTM')
        state = 'Commemorative - Universiti Teknologi Malaysia'; return;
    elseif startsWith(plateText, 'UUM')
        state = 'Commemorative - Universiti Utara Malaysia'; return;
    elseif startsWith(plateText, 'UKM')
        state = 'Commemorative - Universiti Kebangsaan Malaysia'; return;
    elseif startsWith(plateText, 'UiTM')
        state = 'Commemorative - UiTM'; return;
    elseif startsWith(plateText, 'UM ') || (strcmp(plateText, 'UM') && len == 2) || (len > 2 && startsWith(plateText, 'UM') && isstrprop(plateText(3),'digit'))
        state = 'Commemorative - Universiti Malaya'; return; % UM followed by space or number
    end

    % 3. Check for Electric Vehicle specific series prefix
    if startsWith(plateText, 'EV') % EV Series (Page 14 of Wikipedia article)
        state = 'Electric Vehicle (EV Series)';
        return;
    end
    
    % 4. Check for Trade Plates (specific prefixes)
    if startsWith(plateText, 'W/TP') || startsWith(plateText, 'W/TS')
        state = 'Trade Plate - Kuala Lumpur';
        return;
    end
    % Note: Other trade plate formats (e.g., Sabah ### D, Sarawak ... Q) are harder to distinguish
    % from text alone without color or more specific formatting rules not easily parsed here.
    % The general Peninsular "x #### x" is also ambiguous.

    % 5. Check for Langkawi
    if startsWith(plateText, 'KV')
        state = 'Langkawi';
        return;
    end

    % 6. Check for Taxis (H prefix)
    if startsWith(plateText, 'H') && len >= 2
        taxiStateLetter = plateText(2);
        state = 'Taxi - ';
        switch taxiStateLetter
            case 'A', state = [state, 'Perak'];
            case 'B', state = [state, 'Selangor'];
            case 'C', state = [state, 'Pahang'];
            case 'D', state = [state, 'Kelantan'];
            case 'E', state = [state, 'Sabah (Old HE series)'];
            case 'J', state = [state, 'Johor'];
            case 'K', state = [state, 'Kedah'];
            case 'L', state = [state, 'Labuan'];
            case 'M', state = [state, 'Malacca'];
            case 'N', state = [state, 'Negeri Sembilan'];
            case 'P', state = [state, 'Penang'];
            case 'Q', state = [state, 'Sarawak'];
            case 'R', state = [state, 'Perlis'];
            case 'S', state = [state, 'Sabah (HS series)'];
            case 'T', state = [state, 'Terengganu'];
            case 'W', state = [state, 'Kuala Lumpur'];
            otherwise, state = [state, 'Unknown State'];
        end
        return;
    end
    
    % 7. Check for Sarawak plates (Q prefix)
    if startsWith(plateText, 'Q') && len >= 2
        % Check for Sarawak Government first
        if len >= 3 && strcmp(plateText(1:3), 'QSG')
            state = 'Sarawak Government';
            return;
        end
        
        state = 'Sarawak - ';
        sarawakDivision = plateText(2);
        switch sarawakDivision
            case {'A', 'K'} % QK (old), QA (current)
                state = [state, 'Kuching Division'];
            case 'B'
                state = [state, 'Sri Aman / Betong Division'];
            case 'C'
                state = [state, 'Samarahan / Serian Division'];
            case 'D' % QD (current for Bintulu)
                state = [state, 'Bintulu Division'];
            case 'L'
                state = [state, 'Limbang Division'];
            case 'M'
                state = [state, 'Miri Division'];
            case 'P'
                state = [state, 'Kapit Division'];
            case 'R'
                state = [state, 'Sarikei Division'];
            case 'S'
                state = [state, 'Sibu / Mukah Division'];
            case 'T' % QT (exhausted for Bintulu)
                state = [state, 'Bintulu Division (QT series - exhausted)'];
            otherwise
                state = 'Sarawak'; % Default to Sarawak if no specific division matches
        end
        return;
    end

    % 8. Check for Sabah plates (S prefix)
    if startsWith(plateText, 'S') && len >= 2
        % Check for Sabah Government first
        if len >= 3 && strcmp(plateText(1:3), 'SMJ')
            state = 'Sabah Government';
            return;
        elseif plateText(2) == 'G' % SG prefix for Sabah Government
             state = 'Sabah Government';
             return;
        end
        
        state = 'Sabah - ';
        sabahDivision = plateText(2);
        switch sabahDivision
            case 'A' % SA (West Coast, exhausted)
                state = [state, 'West Coast Division (SA series)'];
            case 'B'
                state = [state, 'Beaufort Division'];
            case 'D'
                state = [state, 'Lahad Datu Division'];
            case 'J' % SJ (current for Kota Kinabalu/West Coast)
                state = [state, 'West Coast Division (Kota Kinabalu - SJ series)'];
            case 'K'
                state = [state, 'Kudat Division'];
            case 'L' % SL (Labuan, when under Sabah - replaced)
                state = [state, 'Labuan (Old SL series, under Sabah)'];
            case 'M' % SM (Sandakan)
                state = [state, 'Sandakan Division (SM series)'];
            case 'S' % SS (Sandakan, exhausted)
                state = [state, 'Sandakan Division (SS series - exhausted)'];
            case 'T' % ST (Tawau, exhausted)
                state = [state, 'Tawau Division (ST series - exhausted)'];
            case 'U'
                state = [state, 'Keningau Division (Interior)'];
            case 'W' % SW (current for Tawau)
                state = [state, 'Tawau Division (SW series)'];
            case 'Y' % SY (West Coast, exhausted)
                state = [state, 'West Coast Division (SY series - exhausted)'];
            otherwise
                state = 'Sabah'; % Default to Sabah if no specific division matches
        end
        return;
    end

    % 9. Check for Military plates (Z prefix)
    if startsWith(plateText, 'Z')
        if startsWith(plateText, 'T/Z') % Military Trailers
            state = 'Military Trailer';
        elseif len >= 2
            militaryBranch = plateText(2);
            switch militaryBranch
                case 'L', state = 'Military - Royal Malaysian Navy';
                case 'U', state = 'Military - Royal Malaysian Air Force';
                case {'A', 'B', 'C', 'D'}
                    state = 'Military - Malaysian Army';
                case 'Z', state = 'Military - Ministry of Defence (MINDEF)';
                otherwise, state = 'Military'; % Generic Z prefix
            end
        else
            state = 'Military'; % Just Z
        end
        return;
    end

    % 10. Standard single-letter Peninsular Malaysia prefixes & V (KL), F (Putrajaya)
    if len >= 1
        firstChar = plateText(1);
        switch firstChar
            case 'A', state = 'Perak';
            case 'B', state = 'Selangor';
            case 'C', state = 'Pahang';
            case 'D', state = 'Kelantan';
            case 'F', state = 'Putrajaya (F Series)';
            case 'J', state = 'Johor';
            case 'K', state = 'Kedah';
            case 'L', state = 'Labuan';
            case 'M', state = 'Malacca';
            case 'N', state = 'Negeri Sembilan';
            case 'P', state = 'Penang';
            case 'R', state = 'Perlis';
            case 'T', state = 'Terengganu';
            case 'V', state = 'Kuala Lumpur (V Series)';
            case 'W', state = 'Kuala Lumpur (W Series)';
            % Check for other special single letter series from commemorative list if they are distinct enough
            case 'U'
                if (len > 1 && startsWith(plateText, 'UP')) || (len > 1 && startsWith(plateText, 'US')) || (len > 1 && startsWith(plateText, 'UA')) || (len > 1 && startsWith(plateText, 'UT'))
                    % These are specific 2-letter commemorative prefixes starting with U
                    if startsWith(plateText, 'UP'), state = 'Commemorative - UP Series (Unique Plates)'; end
                    if startsWith(plateText, 'US'), state = 'Commemorative - US Series (Untuk Seniman)'; end
                    if startsWith(plateText, 'UA'), state = 'Commemorative - UA Series'; end
                    if startsWith(plateText, 'UT'), state = 'Commemorative - UT Series (UPNM)'; end
                else
                    state = 'Commemorative - U/UU/UUU Series'; % General U series
                end
             % Add other single-letter commemorative prefixes if they don't conflict, e.g. X, Y
            case 'X'
                if len > 1 && startsWith(plateText, 'XX')
                     state = 'Commemorative - XX Series';
                else
                     state = 'Commemorative - X Series';
                end
            case 'Y'
                if len > 1 && (startsWith(plateText, 'YY') || startsWith(plateText, 'YA') || startsWith(plateText, 'YC'))
                    if startsWith(plateText, 'YY'), state = 'Commemorative - YY Series'; end
                    if startsWith(plateText, 'YA'), state = 'Commemorative - YA Series'; end
                    if startsWith(plateText, 'YC'), state = 'Commemorative - YC Series'; end
                else
                    state = 'Commemorative - Y Series';
                end

            otherwise
                % If it starts with a number, it's likely a special bidding plate or unidentifiable
                if isstrprop(firstChar, 'digit')
                    state = 'Special/Bidding Plate';
                end
        end
    end
end