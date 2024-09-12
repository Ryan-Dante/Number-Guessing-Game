#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only --no-align -c"

echo -e "\n~~~ NUMBER GUESSING GAME ~~~ \n"

# Ask for username
echo -e "\nEnter your username:"
read USERNAME

# Check if username info exists
USERNAME_CHECK=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")

# If username doesn't exist
if [[ -z $USERNAME_CHECK ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # Get user info
  
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number
SECRET_NUMBER=$((1 + $RANDOM % 1000))
NUMBER_OF_GUESSES=1

  # Re-read USER_ID inside the function
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

  # Ask user to guess secret number
  echo -e "\nGuess the secret number between 1 and 1000:"
  read GUESS

  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do
    # Check for valid integer
    if [[ $GUESS =~ ^[0-9]+$ ]]
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
