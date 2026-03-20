#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$((RANDOM % 1000 + 1))

echo "Enter your username:"
read INPUT

USER_ID=$($PSQL"SELECT user_id FROM users WHERE username='$INPUT';")
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE user_id=$USER_ID")
BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM users INNER JOIN games USING(user_id) WHERE user_id=$USER_ID")

if [[ -z $USER_ID ]]
then
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$INPUT');")
  echo "Welcome, $INPUT! It looks like this is your first time here."
else
  if [[ -z $BEST_GAME ]]
  then
    BEST_GAME=0
  fi
  echo "Welcome back, $INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
TRIES=1

while [[ $GUESS != $NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif (( GUESS > NUMBER ))
  then
    echo "It's lower than that, guess again:"
  elif (( GUESS < NUMBER ))
  then
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  ((TRIES++))
done
echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"

USER_ID=$($PSQL"SELECT user_id FROM users WHERE username='$INPUT';")
INSERT_GAME=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($TRIES, $USER_ID);")
