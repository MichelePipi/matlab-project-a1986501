% Version 3
% In the final stage of this project it is becoming much more complex.
% Instead of having the game logic in one consolidated loop, we are instead
% going to allow the player to run unlimited games. The players statistics
% will be recorded, including, but not limited to:
% - Games won
% - Games lost
% - W/L Ratio
% - Guesses Correct
% - guesses wrong
% - correct/wrong ratio
% - longest word played
% - shortest word played
% - least guesses to win z
% - most guesses to win
% all of these will also be able to be saved to a file, which can be loaded
% each time the game is started. 

clc; clear; % clear terminal
% CONSTANTS
WORD_LIST = word_list(); % get the word list from the word list array 
word_to_guess = WORD_LIST{randi(numel(WORD_LIST))}; % select a random word from the word list to act as our goal for the user
% revealed = {'-', '-', '-', '-', '-', '-'};
global ALPHABET 
ALPHABET = {'a','b','c','d','e','f','g','h','i','j','k','l','m', ...
            'n','o','p','q','r','s','t','u','v','w','x','y','z'};
HANGMAN_STAGES = hangman_stages(); 
player_stats = init_player_stats(); 
playing = true;

disp("Welcome to HANGMAN! Written by a1986501 for 'MATLAB & C; ENG1002.'"); % welcome message

while playing
    disp('Press "n" to start a NEW game');
    disp('Press "s" to VIEW stats');
    disp('Press "l" to LOAD saved data from a .txt file. (TODO)')
    disp('Press "e" to EXIT');
    choice = input("Please enter your choice: ", 's');

    switch lower(choice)
        case 'n'
            % we've encapsulated the game into its own function, which
            % returns a new version of player stats, so we can just call
            % that here:
            player_stats = play_hangman_game(WORD_LIST, HANGMAN_STAGES, player_stats);
        case 's'
            display_player_stats(player_stats);
        case 'e'
            disp("Thank you for playing! Your stats have been saved.")
            save_stats_to_file(player_stats, 'hangman_stats.txt');
            break; 
        case 'l'
            [filename, pathname] = uigetfile('*.txt', 'Select a stats file to load');
            if isequal(filename,0)
                disp('No file selected. Returning to main menu.');
            else
                fullpath = fullfile(pathname, filename);
                player_stats = load_stats_from_file(fullpath);
                disp('Player stats loaded successfully.');
            end
            % disp('NOT DONE')
        otherwise
            disp('Invalid choice. Please press "n", "l", or "e".')
    end
end 

% Display instructions
% disp("Welcome to HANGMAN! Written by a1986501 for 'MATLAB & C; ENG1002.'")
% disp("In this version (v1.0), the game will play after this message. You will have UNLIMITED guesses. To guess, type in any SINGLE ALPHABETIC character.")
% disp("You will WIN when you have guessed each letter in the hidden word, which will be revealed at the end.")
% fprintf("The word is currently: %s and it has %d letters in it.\n\n\n", cell2mat(revealed), length(revealed));

function display_player_stats(player_stats)
    fprintf('\n--- PLAYER STATS ---\n');
    fprintf('Games Played: %d | Won: %d | Lost: %d\n', player_stats.games_played, player_stats.games_won, player_stats.games_lost);
    fprintf('Correct Guesses: %d | Wrong Guesses: %d\n', player_stats.correct_guesses, player_stats.wrong_guesses);
    fprintf('Longest Word: %s | Shortest Word: %s\n', player_stats.longest_word, player_stats.shortest_word);
    fprintf('Least Guesses to Win: %d | Most Guesses to Win: %d\n', ...
        player_stats.least_guesses_to_win, player_stats.most_guesses_to_win);
    fprintf('-------------------\n\n');
end

% Save stats to file for loading in later sessions
function save_stats_to_file(player_stats, filename)
    fid = fopen(filename, 'w');
    if fid == -1, error('Cannot open file for writing.'); end % fid == -1 means we couldn't open the file
    fprintf(fid, 'games_played,%d\n', player_stats.games_played);
    fprintf(fid, 'games_won,%d\n', player_stats.games_won);
    fprintf(fid, 'games_lost,%d\n', player_stats.games_lost);
    fprintf(fid, 'correct_guesses,%d\n', player_stats.correct_guesses);
    fprintf(fid, 'wrong_guesses,%d\n', player_stats.wrong_guesses);
    fprintf(fid, 'longest_word,%s\n', player_stats.longest_word);
    fprintf(fid, 'shortest_word,%s\n', player_stats.shortest_word);
    fprintf(fid, 'least_guesses_to_win,%d\n', player_stats.least_guesses_to_win);
    fprintf(fid, 'most_guesses_to_win,%d\n', player_stats.most_guesses_to_win);
    fclose(fid);
end

% Definition definitions: 
% HARD - 4 guesses, 0 hints.
% MEDIUM - 5 guesses, 1 hint.
% EASY - 6 guesses, 2 hints.
% TOO EASY - 6 guesses, 6 hints.
function player_stats = play_hangman_game(WORD_LIST, HANGMAN_STAGES, player_stats)
%PLAY_HANGMAN_GAME Play a single game of Hangman and update stats

    % --- Initialize game variables ---
    word_to_guess = WORD_LIST{randi(numel(WORD_LIST))};
    revealed = repmat({'-'},1,length(word_to_guess));
    global ALPHABET;

    % INITIAL GAME CONDITIONS 
    finished = false;
    won = false;
    guess_count = 0;
    lives = 0;
    hint_count = 0;  
    correct_guesses = {};
    difficulty_selected = false;

    % DIFFICULTY SELECTION
    while ~difficulty_selected
        disp('Select difficulty level:');
        disp('1 = Too Easy');
        disp('2 = Easy');
        disp('3 = Medium');
        disp('4 = Hard');
        
        user_input = input('Enter the number corresponding to your choice: ', 's');
        difficulty = str2double(user_input);  % convert string to number
        
        if ~isnan(difficulty) && ismember(difficulty, [1,2,3,4])
            difficulty_selected = true;
        else
            disp('Invalid choice. Please enter 1, 2, 3, or 4.');
        end
    end
    switch difficulty
        case 1  % Too Easy
            lives = 6;
            hint_count = 10;
        case 2  % Easy
            lives = 6;
            hint_count = 2;
        case 3  % Medium
            lives = 5;
            hint_count = 1;
        case 4  % Hard
            lives = 4;
            hint_count = 0;
    end


    fprintf('\nNew game started! The word has %d letters.\n', length(word_to_guess));
    
    %% --- Main Game Loop ---
    while ~finished
        if lives <= 0
            finished = true;
            continue;
        end
        
        fprintf("You have currently made %d guess(es). %d/%d are correct. You have %d guesses left\n", ...
            guess_count, length(correct_guesses), guess_count, lives);
        disp(HANGMAN_STAGES{guess_count+1});
        
        % --- Hint ---
        if hint_count <= 0
            disp("You have no more hints left.")
        else
            wants_hint = input("Would you like to use one of your " + hint_count + " hint(s)? Type ANYTHING into the input box for yes, leave empty otherwise. ", 's');
            if ~isempty(wants_hint)
                hint_count = hint_count - 1;
                index = find(strcmp(revealed,'-'), 1);
                revealed{index} = word_to_guess(index);
            
                if strcmp([revealed{:}], word_to_guess)
                    finished = true;
                    won = true;
                    continue;
                else
                    fprintf("You have just used ONE hint. The letter revealed was '%s'. You have %d hints left.\n", revealed{index}, hint_count);
                end
            end
        end
        
        fprintf("As it stands, the word is currently: %s\n", cell2mat(revealed));
        
        % --- Input Validation ---
        made_guess = false;
        while ~made_guess
            guess = input("What are you going to guess? ", 's');
            if ischar(guess) && isscalar(guess) && ismember(guess, ALPHABET)
                made_guess = true;
            else
                disp("Sorry, that doesn't seem right. Make sure you are entering a LOWERCASE ALPHABETIC character ('a', 'b', etc...)");
            end
        end
        
        guess_count = guess_count + 1;
        good_guess = false;
        guess = convertStringsToChars(guess);
        
        for i = 1:strlength(word_to_guess)
            if guess == word_to_guess(i)
                revealed{i} = word_to_guess(i);
                correct_guesses{end+1} = guess;
                good_guess = true;
            end
        end
        
        if ~good_guess
            disp("Your guess did not reveal anything.")
            lives = lives - 1; 
        end
        
        if strcmp([revealed{:}], word_to_guess)
            finished = true;
            won = true;
            continue;
        end
    end
    
    %% --- Update Player Stats ---
    player_stats.games_played = player_stats.games_played + 1;
    
    if won
        fprintf("Congratulations, you WON! You used %d guess(es) and %d hint(s). The word was %s.\n", guess_count, hint_count, word_to_guess);
        player_stats.games_won = player_stats.games_won + 1;
        player_stats.least_guesses_to_win = min(player_stats.least_guesses_to_win, guess_count);
        player_stats.most_guesses_to_win = max(player_stats.most_guesses_to_win, guess_count);
    else
        disp("Sorry! You lost. The word was " + word_to_guess + ".");
        player_stats.games_lost = player_stats.games_lost + 1;
    end
    
    % Update guesses stats
    player_stats.correct_guesses = player_stats.correct_guesses + length(correct_guesses);
    player_stats.wrong_guesses = player_stats.wrong_guesses + (guess_count - length(correct_guesses));
    
    % Update longest and shortest word
    if isempty(player_stats.longest_word) || length(word_to_guess) > length(player_stats.longest_word)
        player_stats.longest_word = word_to_guess;
    end
    if isempty(player_stats.shortest_word) || length(word_to_guess) < length(player_stats.shortest_word)
        player_stats.shortest_word = word_to_guess;
    end
    
end


function player_stats = load_stats_from_file(filename)
%LOAD_STATS_FROM_FILE Load Hangman player stats from a text file safely
%   Returns a valid player_stats structure even if the file is invalid.

    % Initialize default stats
    player_stats = init_player_stats();  

    % Check if file exists
    if ~isfile(filename)
        warning('File does not exist. Returning default stats.');
        return
    end

    fid = fopen(filename, 'r');
    if fid == -1
        warning('Cannot open file: %s. Returning default stats.', filename);
        return
    end

    try
        while ~feof(fid)
            line = fgetl(fid);
            if ~ischar(line), continue; end
            parts = strsplit(line, ',');
            if numel(parts) ~= 2, continue; end
            
            key = strtrim(parts{1});
            value = strtrim(parts{2});
            
            % Assign values safely
            switch key
                case 'games_played'
                    val = str2double(value);
                    if ~isnan(val), player_stats.games_played = val; end
                case 'games_won'
                    val = str2double(value);
                    if ~isnan(val), player_stats.games_won = val; end
                case 'games_lost'
                    val = str2double(value);
                    if ~isnan(val), player_stats.games_lost = val; end
                case 'correct_guesses'
                    val = str2double(value);
                    if ~isnan(val), player_stats.correct_guesses = val; end
                case 'wrong_guesses'
                    val = str2double(value);
                    if ~isnan(val), player_stats.wrong_guesses = val; end
                case 'longest_word'
                    player_stats.longest_word = value;
                case 'shortest_word'
                    player_stats.shortest_word = value;
                case 'least_guesses_to_win'
                    val = str2double(value);
                    if ~isnan(val), player_stats.least_guesses_to_win = val; end
                case 'most_guesses_to_win'
                    val = str2double(value);
                    if ~isnan(val), player_stats.most_guesses_to_win = val; end
                otherwise
                    % Ignore unknown keys
            end
        end
    catch ME
        warning('Error reading file: %s. Returning default stats.', ME.message);
        player_stats = init_player_stats();  % reset to defaults
    end

    fclose(fid);
end
