#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~ NUMBER GUESSING GAME ~~~ \n"

# Generate random number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

# Ask for username
echo -e "\nEnter your username:"
read NAME_INPUT

# Check if username exists
USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$NAME_INPUT'")

# If username doesn't exist
if [[ -z $USERNAME ]]
then
  # Insert new username
  NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$NAME_INPUT')")

  echo -e "\nWelcome, $NAME_INPUT! It looks like this is your first time here."
else
  # Get user info
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$NAME_INPUT'")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USER_ID")

  echo -e "\nWelcome back, $NAME_INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUMBER_GAME() {
  # Re-read USER_ID inside the function
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$NAME_INPUT'")

  # Ask user to guess secret number
  echo -e "\nGuess the secret number between 1 and 1000:"
  read GUESS

  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do
    # Check for valid integer
    if [[ $GUESS =~ ^[0-9]+$ ]] && [ "$GUESS" -ge 1 ] && [ "$GUESS" -le 1000 ]
    then
      ((NUMBER_OF_GUESSES++))

      # Provide hints
      if [[ $GUESS -lt $SECRET_NUMBER ]]
      then
        echo -e "\nIt's higher than that, guess again:"
      elif [[ $GUESS -gt $SECRET_NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
      fi
    else
      # Handle invalid input
      echo -e "\nThat is not an integer, guess again:"
    fi

    # Read the next guess
    read GUESS
  done

  # If the guess is correct
    INSERT_GUESSES_RESULT=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($NUMBER_OF_GUESSES, $USER_ID)")

  echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  exit
}

# Call the game function
NUMBER_GAME
