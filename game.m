% Version 1 
% Main idea for this part is to have a simple CLI version of the game, 
% without an output of the actual "hangman" images, and have it display in a 'lives' version
% The word will be pre-selected, no main menu, no restart, etc... just playing a single game.
% 

word_to_guess = 'matlab';
revealed = {'-', '-', '-', '-', '-', '-'};
finished = false; 
guess_count = 0; 
while ~(finished)
    guess = input("What are you going to guess? ", 's');
    % todo input validation 
    guess_count = guess_count + 1;
    fprintf("You have currently made %d guess(es).\n", guess_count);
    guess = convertStringsToChars(guess); % we need to convert this guess into a character array as we cannot access it otherwise 
    for i = 1:strlength(word_to_guess)
        % disp(string(revealed))
        if (guess == word_to_guess(i))
            revealed{i}=word_to_guess(i);
            % disp(string(revealed))
            disp(cell2mat(revealed)) 
            % disp(revealed);
        end
    end
end