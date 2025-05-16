#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"
echo -e "\n~~~~~ MY SALON ~~~~~"

SALON_SERVICES () {
  echo -e "\nWelcome to My Salon, how can I help you?"
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICE_LIST" | while IFS="|" read ID NAME
do
  echo "$ID) $NAME"
done
read SERVICE_ID_SELECTED
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
  echo -e "\nI could not find that service. What would you like today?"
  SALON_SERVICES
  else
  echo -e "What's your phone number?"
  read CUSTOMER_PHONE
  FIND_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  FIND_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      #check phone if it found
      if [[ -z $FIND_CUSTOMER_NAME ]]
          then
               #procees if phone not found
                echo -e "\nI don't have a record for that phone number, what's your name?"
                read CUSTOMER_NAME
                    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME? EX:10:30am"
                    read SERVICE_TIME
                    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
                    ($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") > /dev/null 2>&1
                    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
                    ($PSQL "INSERT INTO appointments(time, service_id, customer_id) VALUES('$SERVICE_TIME', '$SERVICE_ID_SELECTED', $CUSTOMER_ID)") > /dev/null 2>&1
                    echo -e "thank you for visiting us"
      else
      #process if phone found
      echo -e "\nWhat time would you like your $SERVICE_NAME, $FIND_CUSTOMER_NAME? EX:10:30am"
      read SERVICE_TIME
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $FIND_CUSTOMER_NAME."
      ($PSQL "UPDATE appointments SET time='$SERVICE_TIME', service_id=$SERVICE_ID_SELECTED WHERE customer_id=$FIND_CUSTOMER_ID") > /dev/null 2>&1
      echo -e "\nThanks for visiting us"
      fi
fi
}
SALON_SERVICES
