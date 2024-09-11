#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~ NUMBER GUESSING GAME ~~~ \n"

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
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")

  # Handle empty values
  GAMES_PLAYED=${GAMES_PLAYED:-0}
  BEST_GAME=${BEST_GAME:-999}

  echo -e "\nWelcome back, $NAME_INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

# Ask user to guess the secret number
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
((GAMES_PLAYED++))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID")

if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE user_id = $USER_ID")
fi

echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"