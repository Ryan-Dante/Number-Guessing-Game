#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~ NUMBER GUESSING GAME ~~~ \n"

# ask for username
echo -e "\nEnter your usename:"
read NAME_INPUT

 USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$NAME_INPUT'")

# if username doesn't exist
if [[ -z $USERNAME ]]
then

  # insert new username
  NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$NAME_INPUT')")

  echo -e "\nWelcome, $NAME_INPUT! It looks like this is your first time here."

else 

# get user info
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

if [[ -z $GAMES_PLAYED ]] && [[ -z $BEST_GAME ]]
then
GAMES_PLAYED=0
BEST_GAME=999
fi

echo -e "\nWelcome back, $(echo $USERNAME | sed -r 's/^ *| *$//g')! You have played $(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g') games, and your best game took $(echo $BEST_GAME | sed -r 's/^ *| *$//g') guesses."

fi

NUMBER_GAME() {

  # generate random number
  SECRET_NUMBER=$((RANDOM % 1000 + 1))
  NUMBER_OF_GUESSES=0

  # ask user to guess secret number
  echo -e "\nGuess the secret number between 1 and 1000:"
  read GUESS

  # check for valid integer input
  while $GUESS != $SECRET_NUMBER 

  if [[ $GUESS =~ ^[0-9]+$ ]] && [ "$GUESS" -ge 1 ] && [ "$GUESS" -le 1000 ]
  then

  # if guess is lower
  echo -e "\nIt's lower than that, guess again:"
  read GUESS

  # if guess is higher
  echo -e "\nIt's higher than that, guess again:"
  read GUESS

  # if correct guess
  echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

  # increment games played

  # check if best game 

  # if best game, replace old best record

  else

  # if not an integer
  echo -e "\nThat is not a valid integer between 1 and 1000"
  exit
  
  fi

  }

NUMBER_GAME