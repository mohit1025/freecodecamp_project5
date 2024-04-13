#!/bin/bash

# Function to generate a random number between 1 and 1000
GENERATE_RANDOM_NUMBER() {
  echo $(( ( RANDOM % 1000 ) + 1 ))
}

# PSQL variable defined
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Function to prompt for username and check if it exists in the database
PROMPT_USERNAME() {
  echo "Enter your username:"
  read USERNAME
  EXISTING_USER=$($PSQL "SELECT username FROM guesses WHERE username='$USERNAME'")
  if [[ -z "$EXISTING_USER" ]]; then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM guesses WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM guesses WHERE username='$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

# Function to run the game
RUN_GAME() {
  SECRET_NUMBER=$(GENERATE_RANDOM_NUMBER)
  NUMBER_OF_GUESSES=0
  echo "Guess the secret number between 1 and 1000:"
  while true; do
    read GUESS
    if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
    else
      ((NUMBER_OF_GUESSES++))
      if [[ $GUESS -eq $SECRET_NUMBER ]]; then

        # Check if the user already exists
        EXISTING_USER=$($PSQL "SELECT username FROM guesses WHERE username='$USERNAME'")
        
        if [[ -z "$EXISTING_USER" ]]; then
          # Insert a new record if the user doesn't exist
          $PSQL "INSERT INTO guesses (username, games_played, best_game) VALUES ('$USERNAME', 1, $NUMBER_OF_GUESSES);" > /dev/null
        else
          # Update the existing record
          $PSQL "UPDATE guesses SET games_played = games_played + 1, best_game = LEAST($NUMBER_OF_GUESSES, best_game) WHERE username='$USERNAME';" > /dev/null
        fi
        echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
        break
      elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
        echo "It's higher than that, guess again:"
      else
        echo "It's lower than that, guess again:"
      fi
    fi
  done
}

PROMPT_USERNAME
RUN_GAME
