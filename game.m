% Version 1 
% Main idea for this part is to have a simple CLI version of the game, 
% without an output of the actual "hangman" images, and have it display in a 'lives' version
% The word will be pre-selected, no main menu, no restart, etc... just playing a single game.
% 

word_to_guess = 'matlab';
revealed = {'-', '-', '-', '-', '-', '-'};
disp(word_to_guess(1))
finished = false; 
while ~(finished)
    guess = input("What are you going to guess? ", 's');
    % todo input validation 
    guess = convertStringsToChars(guess);
    for i = 1:strlength(word_to_guess)
        if (guess == word_to_guess(i))
            disp("omg")
        end
    end
end