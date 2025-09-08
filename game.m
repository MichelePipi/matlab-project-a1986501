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
revealed = {'-', '-', '-', '-', '-', '-'};
ALPHABET = {'a','b','c','d','e','f','g','h','i','j','k','l','m', ...
            'n','o','p','q','r','s','t','u','v','w','x','y','z'};
HANGMAN_STAGES = hangman_stages();
player_stats = init_player_stats(); 

% GAME CONDITIONS 
finished = false; 
won = false;
playing = true;

% PLAYER STATS
guess_count = 0; 
lives = 8;
hint_count = 999999;
initial_hints = hint_count; 
correct_guesses = {};

while playing
    disp("Welcome to HANGMAN! Written by a1986501 for 'MATLAB & C; ENG1002.'");
    disp('Press "n" to start a NEW game');
    disp('Press "s" to VIEW stats');
    disp('Press "l" to LOAD saved data from a .txt file. (TODO)')
    disp('Press "e" to EXIT');
    choice("Please enter your choice.", 's');

    switch lower(choice)
        case 'n'
        case 's'
        case 'e'
            disp("Thank you for playing! Your stats have been saved.")
            playing = true;
        case 'l'
            disp('NOT DONE')
        otherwise
            disp('Invalid choice. Please press "n", "l", or "e".')
    end
end 

% Display instructions
disp("Welcome to HANGMAN! Written by a1986501 for 'MATLAB & C; ENG1002.'")
disp("In this version (v1.0), the game will play after this message. You will have UNLIMITED guesses. To guess, type in any SINGLE ALPHABETIC character.")
disp("You will WIN when you have guessed each letter in the hidden word, which will be revealed at the end.")
fprintf("The word is currently: %s and it has %d letters in it.\n\n\n", cell2mat(revealed), length(revealed));
while ~(finished)
    if (lives <= 0) % we first check if he has run out of lives as otherwise, we would allow the user to find another 
        finished = true;
        continue;
    end
    fprintf("You have currently made %d guess(es). %d/%d are correct. You have %d guesses left\n", guess_count, length(correct_guesses), guess_count, lives);
    %fprintf("You currently have %d live(s) left.\n", lives);
    disp(HANGMAN_STAGES{guess_count+1})
    %fprintf("As it stands, the word is currently: %s\n", cell2mat(revealed));
    % Hint
    wants_hint = input("Would you like to use one of your " + hint_count + " hint(s)? Type ANYTHING into the input box for yes, leave empty otherwise. ", 's');
    if ~(isempty(wants_hint)) % if the input isn't empty then we consider that as a yes
        hint_count = hint_count - 1; % decrement the amount of hints they have left
        % find index of first element of revealed array that is a '-'
        index = find(strcmp(revealed, '-'), 1); % strcmp returns 1 when the strings are exactly the same 
        revealed{index} = word_to_guess(index);
        fprintf("You have just used ONE hint. The letter revealed was '%s'. You have %d hints left.\n", revealed{index}, hint_count);
       % fprintf("As it stands, the word is currently: %s\n", cell2mat(revealed));
    end
    fprintf("As it stands, the word is currently: %s\n", cell2mat(revealed));
     % INPUT VALIDATION %
    made_guess = false;
    while ~(made_guess) % put user in a loop until they make a VALID guess. 
        guess = input("What are you going to guess? ", 's');
        if ischar(guess) && isscalar(guess) && ismember(guess,ALPHABET) == 1 % is it a character, with one element, and is it a member of the ALPHABET array ...
                                                                             % i.e is it a lowercase alphabetic character?
            made_guess = true; % we can move on now.
        else % make an error
            disp("Sorry, that doesn't seem right. Make sure you are entering a LOWERCASE ALPHABETIC character ('a', 'b', etc...)")
        end
    end

    guess_count = guess_count + 1;
    % Since this is hangman, we only want to take a life/guess away when
    % they guess something wrong, so lets make a flag here to determine
    % whether they made a good guess.
    good_guess = false; 
    %lives = lives - 1;
    guess = convertStringsToChars(guess); % we need to convert this guess into a character array as we cannot access it otherwise 
    for i = 1:strlength(word_to_guess) % right now this is redundant as the strlength is constant, 
                                       % but when we begin choosing a random word from a list this must use strlength to account for this.
        % disp(string(revealed))
        if (guess == word_to_guess(i))
            revealed{i}=word_to_guess(i);
            correct_guesses{end+1} = guess;
            good_guess = true;
        end 
    end 
    if ~good_guess
        %guess_count = guess_count + 1;
        lives = lives - 1;
    end
    if strcmp([revealed{:}], word_to_guess) % if the characters that have been guessed fill up the revealed string, i.e if we have finished
        finished = true; % break out of the main game loop
        won = true; % make sure the game knows that the user has WON rather than LOST so we can print out the correct output later. 
        continue;
    end
end


if won
    fprintf("Congratulations, you WON! You used %d guess(es) and %d hint(s). The word was %s\n.", guess_count, hint_count, word_to_guess);
    disp("Congratulations! You WON! You took " + guess_count + " guess(es). The word was " + word_to_guess + ".")
else
    disp("Sorry! You lost. The word was " + word_to_guess + ".")
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