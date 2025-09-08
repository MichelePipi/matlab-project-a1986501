% In C++ I used structs to handle data as something before classes, and I
% think that they'll be useful for this to handle the player stats. 
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

function player_stats = init_player_stats()

    % Overall game counts
    player_stats.games_played = 0;             % Total games played
    player_stats.games_won = 0;                % Total games won
    player_stats.games_lost = 0;               % Total games lost

    % Guess tracking
    player_stats.correct_guesses = 0;          % Total correct guesses across all games
    player_stats.wrong_guesses = 0;            % Total wrong guesses across all games

    % Word length tracking
    player_stats.longest_word = '';            % Longest word the player has played
    player_stats.shortest_word = '';           % Shortest word the player has played

    % Guesses to win tracking
    player_stats.least_guesses_to_win = Inf;  % Minimum guesses used to win a game
    player_stats.most_guesses_to_win = 0;     % Maximum guesses used to win a game
end