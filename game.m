% Version 1 
% Main idea for this part is to have a simple CLI version of the game, 
% without an output of the actual "hangman" images, and have it display in a 'lives' version
% The word will be pre-selected, no main menu, no restart, etc... just playing a single game.
% 

word_to_guess = 'matlab';
revealed = {'-', '-', '-', '-', '-', '-'};
finished = false; 
won = false;
guess_count = 0; 
while ~(finished)
    fprintf("You have currently made %d guess(es).\n", guess_count);
    fprintf("As it stands, the word is currently: %s\n", cell2mat(revealed));
    guess = input("What are you going to guess? ", 's');
    % todo input validation 
    guess_count = guess_count + 1;
    guess = convertStringsToChars(guess); % we need to convert this guess into a character array as we cannot access it otherwise 
    for i = 1:strlength(word_to_guess)
        % disp(string(revealed))
        if (guess == word_to_guess(i))
            revealed{i}=word_to_guess(i);
        end
    end
    if strcmp([revealed{:}], word_to_guess) % if the characters that have been guessed fill up the revealed string, i.e if we have finished
        finished = true;
        won = true;
        continue;
    end
end


if won
    disp("Congratulations! You WON! You took " + guess_count + " guess(es). The word was " + word_to_guess + ".")
else
    disp("Sorry! You lost. The word was " + word_to_guess + ".")
end