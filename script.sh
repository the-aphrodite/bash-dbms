#!/bin/bash

CURRENT_DB=""

function main_menu(){
echo "============================"
echo "      Bash DBMS System      "
echo "============================"

echo "1) Create Database"
echo "2) List Databases"
echo "3) Connect to Database"
echo "4) Drop Database"
echo "5) Exit"
echo "============================"
echo "Choose an option: "
read choice
case $choice in
1) create_database ;;
2) list_databases ;;
3) connect_database ;;
4) drop_database ;;
5) exit 0 ;;
*) echo "Invalid option"; main_menu;;
esac
}

function create_database() {
echo "Enter database name: "
read dbname
if [[ -z "$dbname" || "$dbname" =~ [^a-zA-Z0-9_] ]]; then
echo "Invalid database name!"
elif [ -d "$dbname" ]; then
echo "Database already exists!"
else
mkdir "$dbname"
echo "Database $dbname created successfully."
fi
main_menu
}

function list_databases(){
echo "Available Databases:"
ls -d */ | sed 's#/##'
main_menu
}

function connect_database(){
echo "Enter database name to connect: "
read dbname
if [ -d "$dbname" ]; then
CURRENT_DB="$dbname"
echo "Connected to database '$dbname'"
database_menu
else
echo "Database not found!"
main_menu
fi
}

function drop_database(){
echo "Enter database name to delete: "
read dbname
if [ -d "$dbname" ]; then
rm -r "$dbname"
echo "Database '$dbname' deleted."
else
echo "Database not found!"
fi
main_menu
}

function database_menu(){
echo "============================"
echo "Mapping Tables in $CURRENT_DB"
echo "============================"
echo "1) Create Table"
echo "2) List Table"
echo "3) Drop Table"
echo "4) Insert into Table"
echo "5) Select from Table"
echo "6) Delete from Table"
echo "7) Update Table"
echo "8) Return to Main Menu"
echo "============================"
read -p "Choose an option: " choice
case $choice in
1) create_table ;;
2) list_table ;;
3) drop_table ;;
4) insert_into_table ;;
5) select_from_table ;;
6) delete_from_table ;;
7) update_table ;;
8) main_menu;;
*) echo "Invalid option"; database_menu ;;
esac
}

function create_table(){
  echo "Enter table name: "
  read table
  if [[ -z "$table" || "$table" =~ [^a-zA-Z0-9_] ]]; then
    echo "Invalid table name!"
  elif [ -f "$CURRENT_DB/$table.txt" ]; then
    echo "Table already exists!"
  else
    echo "Enter column names (comma-separated): "
    read columns
    IFS=',' read -r -a column_array <<< "$columns"
    echo "Enter the primary key column name: "
    read primary_key
    if [[ ! " ${column_array[@]} " =~ " $primary_key " ]]; then
      echo "Invalid primary key!"
      database_menu
    fi
    echo "$columns" > "$CURRENT_DB/$table.txt"
    echo "$primary_key" > "$CURRENT_DB/$table.schema"
    echo "Table '$table' created successfully with primary key '$primary_key'."
  fi
  database_menu
}

function list_table(){
echo "Available Tables:"
ls "$CURRENT_DB"/*.txt 2>/dev/null | xargs -n 1 basename | sed 's/\.txt$//'
database_menu
}

function drop_table(){
echo "Enter table name to delete: "
read table
if [ -f "$CURRENT_DB/$table.txt" ]; then
rm "$CURRENT_DB/$table.txt" "$CURRENT_DB/$table.schema"
echo "Table '$table' deleted."
else
echo "Table not found"
fi
database_menu
}

function insert_into_table() {
  echo "Enter table name to insert into: "
  read table
  if [ -f "$CURRENT_DB/$table.txt" ]; then
    header=$(head -n 1 "$CURRENT_DB/$table.txt")
    primary_key=$(cat "$CURRENT_DB/$table.schema")
    IFS=',' read -r -a column_array <<< "$header"
    echo "Enter data to insert (comma-separated values): "
    read data
    IFS=',' read -r -a data_array <<< "$data"
    primary_key_value="${data_array[$(echo "${column_array[@]}" | tr ' ' '\n' | nl -w 1 | grep -i "$primary_key" | awk '{print $1}' | head -n1)]}"
    if grep -q "^$primary_key_value," "$CURRENT_DB/$table.txt"; then
      echo "Error: Primary key '$primary_key_value' already exists!"
    else
      echo "$data" >> "$CURRENT_DB/$table.txt"
      echo "Data inserted into table '$table'."
    fi
  else
    echo "Table '$table' does not exist!"
  fi
  database_menu
}

function select_from_table() {
  echo "Enter table name to select from: "
  read table
  if [ -f "$CURRENT_DB/$table.txt" ]; then
    nl -ba "$CURRENT_DB/$table.txt"
  else
    echo "Table '$table' does not exist!"
  fi
  database_menu
}

function delete_from_table() {
  echo "Enter table name to delete from: "
  read table
  if [ -f "$CURRENT_DB/$table.txt" ]; then
    nl -ba "$CURRENT_DB/$table.txt"
    echo "Enter the line number to delete: "
    read line
    sed -i "${line}d" "$CURRENT_DB/$table.txt"
    echo "Line $line deleted from $table."
  else
    echo "Table '$table' does not exist!"
  fi
  database_menu
}

function update_table() {
  echo "Enter table name to update: "
  read table
  if [ -f "$CURRENT_DB/$table.txt" ]; then
    nl -ba "$CURRENT_DB/$table.txt"
    echo "Enter the line number to update: "
    read line
    echo "Enter the new data (comma-separated): "
    read new_data
    sed -i "${line}s/.*/$new_data/" "$CURRENT_DB/$table.txt"
    echo "Line $line updated in $table."
  else
    echo "Table '$table' does not exist!"
  fi
  database_menu
}

main_menu
