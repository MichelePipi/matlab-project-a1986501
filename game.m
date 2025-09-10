% Version 3 - FINAL VERSION
% Hangman, created by a1986501 :)

clc; clear; % clear terminal
% CONSTANTS
WORD_LIST = word_list(); % get the word list from the word list array 
word_to_guess = WORD_LIST{randi(numel(WORD_LIST))}; % select a random word from the word list to act as our goal for the user. randi() = random integer, numel() = number of array elements.
global ALPHABET 
ALPHABET = {'a','b','c','d','e','f','g','h','i','j','k','l','m', ...
            'n','o','p','q','r','s','t','u','v','w','x','y','z'};
HANGMAN_STAGES = hangman_stages(); % see: hangman_stages.m
player_stats = init_player_stats();  % see: init_player_stats.m
words_played = {}; % Set up so we prevent repeated words
playing = true; % initialise the playing flag so we can begin the main game loop

disp("Welcome to HANGMAN! Written by a1986501 for 'MATLAB & C; ENG1002.'"); % welcome message

% MAIN GAME LOOP
while playing
    disp('Press "n" to start a NEW game');
    disp('Press "s" to VIEW stats');
    disp('Press "l" to LOAD saved data from a .txt file.')
    disp('Press "e" to EXIT');
    choice = input("Please enter your choice: ", 's');

    switch lower(choice)
        case 'n'
            % we've encapsulated the game into its own function, which
            % returns a new version of player stats, so we can just call
            % that here:
            player_stats = play_hangman_game(WORD_LIST, HANGMAN_STAGES, player_stats); % nice and simple.
        case 's' 
            display_player_stats(player_stats);
        case 'e'
            disp("Thank you for playing! Your stats have been saved.") 
            save_stats_to_file(player_stats, 'hangman_stats.txt'); % see the function definition at the end of this file. 
            break; 
        case 'l'
            [filename, pathname] = uigetfile('*.txt', 'Select a stats file to load'); % sese matlab docs: https://au.mathworks.com/help/matlab/ref/uigetfile.html
                                                                                      %uigetfile has many definitions for multiple outputs. in this case, we want the
                                                                                      % file name and pathname of the file we want to load, so we call that instance here.
            if isequal(filename,0) % did the user select nothing?
                disp('No file selected. Returning to main menu.'); 
            else % if the user *did* select something, we want its path, and the stats loaded.
                fullpath = fullfile(pathname, filename);
                player_stats = load_stats_from_file(fullpath);
                % disp('Player stats loaded successfully.'); redundant.
                % possible it fails to load which is handled in that
                % function now.
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
    % PICK WORD TO GUESS
    word_chosen = false;
    global words_played; 
    if numel(words_played) == numel(WORD_LIST) && all(ismember(WORD_LIST, words_played)) % if words_played is the same size as WORD_LIST, 
                                                                                        %  and all the elements of word_list are in words_played, 
                                                                                        %  we can conclude that every word has been played.
        words_played = {}; % reset the word list if the player has used all 1000 words.
        disp('It looks like you have used every single word! Resetting...');
    end
    while ~word_chosen
        word_to_guess = WORD_LIST{randi(numel(WORD_LIST))};
        if ~ismember(word_to_guess,words_played)
            word_chosen = true;
            words_played{end+1} = word_to_guess;
            % disp(words_played);
        end
    end
    revealed = repmat({'-'},1,length(word_to_guess)); % repmat = repeat matrix, so we're just repeating the single-element
    %                                                    matrix {'-'} N times, where N is the length of the word the user is guessing

    % INITIAL GAME CONDITIONS 
    % notice that in earlier versions of the game this used to be in the
    % definition outside of the loop. this is because this logic was for
    % only playing one game, but for each subsequent game all variables
    % need to be reset to ensure fairness and continuity. 
    global ALPHABET; % this allows the ALPHABET variable to be used.
    finished = false;
    won = false;
    guess_count = 0;
    lives = 0;
    hint_count = 0;  
    guesses = {};
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
        
        if ~isnan(difficulty) && ismember(difficulty, [1,2,3,4]) % is the difficulty a number, and is either 1,2,3 or 4? 
            difficulty_selected = true; % we can leave this loop. 
        else
            disp('Invalid choice. Please enter 1, 2, 3, or 4.');
        end
    end
    switch difficulty % switch statement to set up the lives and hint count vars.
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
            finished = true; % win is false until the player wins, so nothing else needs to be done 
                             % here other than force a new iteration of the loop (continue) which will 
                             % obviously break us out as finishted is now true, and then the outputs will occur later.
            continue;
        end
        
        fprintf("You have currently made %d guess(es). %d/%d are correct. You have %d guesses left\n", ...
            guess_count, length(correct_guesses), guess_count, lives);
        disp(HANGMAN_STAGES{guess_count+1});
        
        % --- Hint ---
        if hint_count <= 0
            disp("You have no more hints left. Proceeding to make a guess.")
        else
            wants_hint = input("Would you like to use one of your " + hint_count + " hint(s)? Type ANYTHING into the input box for yes, leave empty otherwise. ", 's'); 
            if ~isempty(wants_hint) % if the user did not input anything 
                                    % then we want to use a hint (see the
                                    % line above this)
                hint_count = hint_count - 1; % no need to check if they 
                                             % have enough guesses; see
                                             % above.
                index = find(strcmp(revealed,'-'), 1); % find the FIRST instance of 
                                                       % a SCRAMBLED
                                                       % LETTER. this is
                                                       % the letter which
                                                       % we will reveal.
                revealed{index} = word_to_guess(index); % reveal the letter.
            
                if strcmp([revealed{:}], word_to_guess) % since this hint
                                                        % could possibly
                                                        % have been at the
                                                        % end of the word,
                                                        % we need to check
                                                        % if this makes the
                                                        % user win.
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
            if ischar(guess) && isscalar(guess) && ismember(guess, ALPHABET) % is the guess a SINGLE (isscalar) CHARACTER (ischar) and is this character a LETTER (ismember).
                if ismember(guess,guesses) % if so, has this guess already been made?
                    disp("Sorry, it seems like you have guessed that letter already.") % make them guess again.
                else % otherwise, if they have not made this guess yet
                    made_guess = true; % we should set the flag to true so we break out this loop.
                end
            else
                disp("Sorry, that doesn't seem right. Make sure you are entering a LOWERCASE ALPHABETIC character ('a', 'b', etc...)");
            end
        end
        
        guesses{end+1} = guess; % we need this to prevent repeat guesses
        guess_count = guess_count + 1;
        good_guess = false;
        guess = convertStringsToChars(guess);
        
        for i = 1:strlength(word_to_guess) % loop once for each letter in the word to guess
            if guess == word_to_guess(i) % if the guess is the same as the ith letter
                revealed{i} = word_to_guess(i); % then set this element in the revealed array to the letter, so we can
                                                % begin displaying it to
                                                % the user
                correct_guesses{end+1} = guess; % add the correct guesses to the 
                                                % guess list.
                good_guess = true; % this is for later, when decrementing lives.
            end
        end
        
        if ~good_guess % see above. did the guess NOT reveal anything?
            disp("Your guess did not reveal anything.")
            lives = lives - 1; 
        end
        
        if strcmp([revealed{:}], word_to_guess) %revealed{:} finds the revealed string, and strcmp returns true if the given strings aare the same.
                                                % i.e, if the revealed
                                                % string and the word to
                                                % guess strings are the
                                                % same, this must mean the
                                                % player has guessed all
                                                % letters in the word.
            finished = true;
            won = true;
            continue; % skip to the next iteration of the loop, which will in turn break us out of it as the flag is now true.
        end
    end
    
    %% --- Update Player Stats ---
    player_stats.games_played = player_stats.games_played + 1;
    
    if won % self-explanatory; did the player win?
        fprintf("Congratulations, you WON! You used %d guess(es) and %d hint(s). The word was %s.\n", guess_count, hint_count, word_to_guess);
        player_stats.games_won = player_stats.games_won + 1; % increment their win count 
        player_stats.least_guesses_to_win = min(player_stats.least_guesses_to_win, guess_count); % use the min(a, b) function to determine whether they used less guesses than the current lowest guess count to win.
        player_stats.most_guesses_to_win = max(player_stats.most_guesses_to_win, guess_count); % same as above.
    else % again, self-explanatory. did the player lose?
        disp("Sorry! You lost. The word was " + word_to_guess + ".");
        player_stats.games_lost = player_stats.games_lost + 1; % increment their loss count
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

    fid = fopen(filename, 'r'); % from https://au.mathworks.com/help/matlab/ref/fopen.html:
                                % fopen simply opens the file we want to
                                % read in read mode ('r'). fid returns -1
                                % if there was an error.
    if fid == -1                % that is why we are checking whether fid is -1 here <-.
        warning('Cannot open file: %s. Returning default stats.', filename);
        return
    end

    try
        while ~feof(fid) % according to matlab docs (https://au.mathworks.com/help/matlab/ref/feof.html), 
                         % the feof file tests whether we are at the end of
                         % a file. therefore, while ~feof(fid) means we are
                         % going to run the following code until we are at
                         % the end of the file.
            line = fgetl(fid); % get the current line... (fgetl = get line from file)
            if ~ischar(line), continue; end  % if the line isnt a character array then skip the rest of the loop
            parts = strsplit(line, ','); % thus if it is a char array split each part seperated by ',' (see the hangman_stats.txt file for more info)
            if numel(parts) ~= 2, continue; end % if there isnt 2 elements then something went awry!
            
            key = strtrim(parts{1}); 
            value = strtrim(parts{2});
            % Initialize flag
            all_values_found = true;
            
            % Assign values safely. here, we are assuming that the file
            % contains the correct information in the correct fields.
            switch key
                case 'games_played' % the logic here will only be explained once as it is 
                                    % the same for each value.
                    val = str2double(value); 
                    if ~isnan(val) % is the value we want a number?
                        player_stats.games_played = val; % set it to the corresponding value.
                    else % if it is not a number
                        all_values_found = false; % chance our flag so we know to alert the user.
                    end
                case 'games_won'
                    val = str2double(value); % same logic here...
                    if ~isnan(val)
                        player_stats.games_won = val;
                    else
                        all_values_found = false;
                    end
                case 'games_lost'
                    val = str2double(value);
                    if ~isnan(val)
                        player_stats.games_lost = val;
                    else
                        all_values_found = false;
                    end
                case 'correct_guesses'
                    val = str2double(value);
                    if ~isnan(val)
                        player_stats.correct_guesses = val;
                    else
                        all_values_found = false;
                    end
                case 'wrong_guesses'
                    val = str2double(value);
                    if ~isnan(val)
                        player_stats.wrong_guesses = val;
                    else
                        all_values_found = false;
                    end
                case 'longest_word'
                    player_stats.longest_word = value;
                case 'shortest_word'
                    player_stats.shortest_word = value;
                case 'least_guesses_to_win'
                    val = str2double(value); 
                    if ~isnan(val)
                        if val == Inf
                            player_stats.least_guesses_to_win = 'N/A';
                        end
                        player_stats.least_guesses_to_win = val;
                    else
                        all_values_found = false;
                    end
                case 'most_guesses_to_win'
                    val = str2double(value);
                    if ~isnan(val)
                        player_stats.most_guesses_to_win = val;
                    else
                        all_values_found = false;
                    end
                otherwise
                    % Ignore unknown keys
            end
        end
        % To make the game more user-friendly, the all_values_found flag
        % will be checked and if it is not 'true', then we should send an
        % error message to the user.
        if ~all_values_found
            disp("There was an error while loading some of your stats. Default values were inserted instead.")
        end
    catch ME % from https://au.mathworks.com/help/matlab/ref/mexception.html: any matlab code which throws
             % an error throws an ME; a MException object. so in case of
             % any errors occur while reading the values, we should stop
             % immediately and set the player stats to dummy values, as
             % well as tell the user. 
        warning('Error reading file: %s. Returning default stats.', ME.message);
        player_stats = init_player_stats();  % reset to defaults
    end

    fclose(fid); % close the file to prevent issues
end
