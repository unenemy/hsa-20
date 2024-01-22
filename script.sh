#!/bin/bash

# MySQL connection parameters
MYSQL_HOST="127.0.0.1"
MYSQL_PORT="3306"
MYSQL_USER="root"
MYSQL_PASSWORD="root"
MYSQL_DATABASE="mydb"

# Function to generate a random string
generate_random_string() {
  echo "$(LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$1")"
}

# Function to generate random data and insert into the products table
insert_random_data() {
  title=$(generate_random_string 10)
  price=$(awk -v min=10 -v max=100 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
  amount=$(shuf -i 1-100 -n 1)
  note=$(generate_random_string 20)
  weight=$(awk -v min=1 -v max=10 'BEGIN{srand(); print int((min+rand()*(max-min+1))*10)/10}')

  mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
    -e "INSERT INTO products (title, price, amount, note, weight) VALUES ('$title', $price, $amount, '$note', $weight);"
}

# Main loop to insert data until terminated
while true; do
  insert_random_data  # Adjust the sleep duration as needed
  sleep 1
done