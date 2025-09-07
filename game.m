% Version 1 
% Main idea for this part is to have a simple CLI version of the game, 
% without an output of the actual "hangman" images, and have it display
% with unlimited lives
% The word will be pre-selected, no main menu, no restart, etc... just playing a single game.
% 

word_to_guess = 'matlab';
revealed = {'-', '-', '-', '-', '-', '-'};
finished = false; 
won = false;
guess_count = 0; 

ALPHABET = {'a','b','c','d','e','f','g','h','i','j','k','l','m', ...
            'n','o','p','q','r','s','t','u','v','w','x','y','z'};

while ~(finished)
    fprintf("You have currently made %d guess(es).\n", guess_count);
    fprintf("As it stands, the word is currently: %s\n", cell2mat(revealed));
     % INPUT VALIDATION %
    % first check wehther guess is a character

    made_guess = false;
    while ~(made_guess) 
        guess = input("What are you going to guess? ", 's');
        if ischar(guess) && isscalar(guess) && ismember(guess,ALPHABET) == 1
            made_guess = true;
        else
            disp("Sorry, that doesn't seem right. Make sure you are entering a LOWERCASE ALPHABETIC character ('a', 'b', etc...)")
        end
    end

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