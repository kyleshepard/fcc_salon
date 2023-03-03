#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ The Salon ~~~~~"

function FRONT_DESK(){

  echo -e "\nWelcome in! What can we do for you?"
  
  SERVICES=$($PSQL "SELECT service_id, name FROM SERVICES ORDER BY service_id")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  
  # get service with selected id
  SERVICE_NAME=$($PSQL "SELECT NAME FROM SERVICES WHERE service_id=$SERVICE_ID_SELECTED")

  # check if service exists, somewhat crudely
  if [[ -z $SERVICE_NAME ]]
  then
    # send back to front desk
    FRONT_DESK
  else
    echo -e "What is your phone number?"
    read CUSTOMER_PHONE

    # get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if customer does not exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get the customer's name, then add them to the database
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    echo -e "\nWhat time would you like your service?"
    read SERVICE_TIME

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) values('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")

    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

FRONT_DESK
