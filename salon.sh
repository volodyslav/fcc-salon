#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

SERVICE_CHOOSE(){
  SERVICE_DATA=$($PSQL "select service_id, name from services" )
  echo "$SERVICE_DATA" | while read SERVICE_ID BAR NAME
  do 
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_CHOOSE "Not a valid service"
  else
     FIND_SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
     if [[ -z $FIND_SERVICE ]]
     then
      SERVICE_CHOOSE "I could not find that service. What would you like today?" 
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" )
          echo -e "\nWhat time would you like your$FIND_SERVICE, $CUSTOMER_NAME?"
          read SERVICE_TIME
          echo -e "\nI have put you down for a $FIND_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME. "
          FIND_CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
          INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($FIND_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" )
        else
          echo -e "\nWhat time would you like your $FIND_SERVICE, $CUSTOMER_NAME?"
          read SERVICE_TIME
          echo -e "\n I have put you down for a $FIND_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME. "
          FIND_CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
          INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($FIND_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" )
        fi
     fi
  fi
}
SERVICE_CHOOSE
