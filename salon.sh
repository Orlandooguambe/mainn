#!/bin/bash

# Function to display the list of services
display_services() {
    echo "~~~~~ MY SALON ~~~~~"
    echo "Welcome to My Salon, how can I help you?"
    local services=$(psql --username=freecodecamp --dbname=salon -c "SELECT service_id, name FROM services;" -t -A)
    local count=1

    echo "$services" | while IFS="|" read -r service_id name; do
        echo "$count) $name"
        count=$((count + 1))
    done
}

# Function to check if the service ID is valid
is_valid_service_id() {
    local service_id=$1
    local valid=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT COUNT(*) FROM services WHERE service_id=$service_id;")
    if [ "$valid" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

# Display services and prompt for input
display_services
while true; do
    echo "Please enter the service ID:"
    read SERVICE_ID_SELECTED
    if is_valid_service_id $SERVICE_ID_SELECTED; then
        break
    else
        echo "I could not find that service. What would you like today?"
        display_services
    fi
done

# Prompt for customer phone number
echo "What's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_EXISTS=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT COUNT(*) FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [ "$CUSTOMER_EXISTS" -eq 0 ]; then
    # Customer does not exist, ask for name and insert
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
else
    # Customer exists, prompt for their name
    CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
fi

# Prompt for service time
echo "What time would you like your $(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;"), $CUSTOMER_NAME?"
read SERVICE_TIME

# Retrieve customer_id and insert appointment
CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Output confirmation
SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
