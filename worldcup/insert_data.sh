#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOAL OPPONENT_GOAL
do
  if [[ $YEAR != "year" ]]
  then
    # get team_id winner
    TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # if not found
    if [[ -z $TEAM_ID_WINNER ]]
    then

      # insert into teams table
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")

      if [[ $INSERT_TEAM == 'INSERT 0 1' ]]
      then
        echo "Team inserted into table teams: $WINNER"
      fi

      # get new team_id
      TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # get team_id opponent
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if not found
    if [[ -z $TEAM_ID_OPPONENT ]]
    then
      # insert into teams table
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")

      if [[ $INSERT_TEAM == 'INSERT 0 1' ]]
      then
        echo "Team inserted into table teams: $OPPONENT"
      fi

      # get new team_id
      TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  
    # insert into games
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID_WINNER, $TEAM_ID_OPPONENT, $WINNER_GOAL, $OPPONENT_GOAL)")
    if [[ $INSERT_GAME == 'INSERT 0 1' ]]
    then
      echo "Game $ROUND of $YEAR inserted: $WINNER (id $TEAM_ID_WINNER) vs. $OPPONENT (id $TEAM_ID_OPPONENT), ended $WINNER_GOAL - $OPPONENT_GOAL"
    fi
  fi
done