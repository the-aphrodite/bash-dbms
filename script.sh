#!/bin/bash

function main_menu() {
    choice=$(zenity --list --title="Bash DBMS System" --column="Options" \
        "Create Database" "List Databases" "Connect to Database" "Drop Database" "Exit")
    case $choice in
        "Create Database") create_database ;;
        "List Databases") list_databases ;;
        "Connect to Database") connect_database ;;
        "Drop Database") drop_database ;;
        "Exit") exit 0 ;;
        *) main_menu ;;
    esac
}

function create_database() {
    dbname=$(zenity --entry --title="Create Database" --text="Enter database name:")
    if [ -d "$dbname" ]; then
        zenity --error --text="Database already exists!"
    else
        mkdir "$dbname"
        zenity --info --text="Database '$dbname' created successfully."
    fi
    main_menu
}

function list_databases() {
    databases=$(ls -d */ 2>/dev/null)
    zenity --info --title="List Databases" --text="Available Databases:\n$databases"
    main_menu
}

function connect_database() {
    dbname=$(zenity --entry --title="Connect to Database" --text="Enter database name:")
    if [ -d "$dbname" ]; then
        cd "$dbname"
        zenity --info --text="Connected to database '$dbname'."
        database_menu
    else
        zenity --error --text="Database not found!"
        main_menu
    fi
}

function drop_database() {
    dbname=$(zenity --entry --title="Drop Database" --text="Enter database name to delete:")
    if [ -d "$dbname" ]; then
        rm -r "$dbname"
        zenity --info --text="Database '$dbname' deleted."
    else
        zenity --error --text="Database not found!"
    fi
    main_menu
}

function database_menu() {
    choice=$(zenity --list --title="Manage Tables" --column="Options" \
        "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" \
        "Delete From Table" "Update Table" "Return to Main Menu")
    case $choice in
        "Create Table") create_table ;;
        "List Tables") list_tables ;;
        "Drop Table") drop_table ;;
        "Insert into Table") insert_into_table ;;
        "Select From Table") select_from_table ;;
        "Delete From Table") delete_from_table ;;
        "Update Table") update_table ;;
        "Return to Main Menu") main_menu ;;
        *) database_menu ;;
    esac
}

function create_table() {
    table=$(zenity --entry --title="Create Table" --text="Enter table name:")
    if [ -f "$table.txt" ]; then
        zenity --error --text="Table already exists!"
    else
        primary_key=$(zenity --entry --title="Primary Key" --text="Enter primary key column name:")
        col_count=$(zenity --entry --title="Columns" --text="Enter number of columns:")
        
        columns=()
        data_types=()
        for ((i = 1; i <= col_count; i++)); do
            col_name=$(zenity --entry --title="Column $i" --text="Enter name for column $i:")
            col_type=$(zenity --list --title="Column Type" --column="Types" "INT" "STRING" "FLOAT")
            columns+=("$col_name")
            data_types+=("$col_type")
        done
        
        header="Primary Key: $primary_key | Columns: ${columns[*]} | Data Types: ${data_types[*]}"
        echo "$header" > "$table.txt"
        zenity --info --text="Table '$table' created successfully."
    fi
    database_menu
}

function list_tables() {
    tables=$(ls *.txt 2>/dev/null)
    zenity --info --title="List Tables" --text="Available Tables:\n$tables"
    database_menu
}

function drop_table() {
    table=$(zenity --entry --title="Drop Table" --text="Enter table name to delete:")
    if [ -f "$table.txt" ]; then
        rm "$table.txt"
        zenity --info --text="Table '$table' deleted."
    else
        zenity --error --text="Table not found!"
    fi
    database_menu
}

function insert_into_table() {
    table=$(zenity --entry --title="Insert Data" --text="Enter table name:")
    if [ -f "$table.txt" ]; then
        data=$(zenity --entry --title="Insert Data" --text="Enter comma-separated values:")
        echo "$data" >> "$table.txt"
        zenity --info --text="Data inserted into $table successfully."
    else
        zenity --error --text="Table does not exist!"
    fi
    database_menu
}

function select_from_table() {
    table=$(zenity --entry --title="Select Table" --text="Enter table name to view:")
    if [ -f "$table.txt" ]; then
        header=$(head -n 1 "$table.txt" | sed 's/|/ /g')
        data=$(tail -n +2 "$table.txt")

        formatted_data=""
        while IFS= read -r line; do
            formatted_data+="$(echo "$line" | sed 's/,/ /g') "
        done <<< "$data"
        
        if [ -z "$formatted_data" ]; then
            zenity --info --text="Table '$table' is empty."
        else
            zenity --list --title="Table: $table" --column="$header" $formatted_data
        fi
    else
        zenity --error --text="Table '$table' does not exist!"
    fi
    database_menu
}

function delete_from_table() {
    table=$(zenity --entry --title="Delete Data" --text="Enter table name:")
    if [ -f "$table.txt" ]; then
        line_num=$(zenity --entry --title="Delete Data" --text="Enter line number to delete:")
        sed -i "${line_num}d" "$table.txt"
        zenity --info --text="Line $line_num deleted."
    else
        zenity --error --text="Table does not exist!"
    fi
    database_menu
}

function update_table() {
    table=$(zenity --entry --title="Update Table" --text="Enter table name:")
    if [ -f "$table.txt" ]; then
        line_num=$(zenity --entry --title="Update Data" --text="Enter line number to update:")
        new_data=$(zenity --entry --title="Update Data" --text="Enter new comma-separated values:")
        sed -i "${line_num}s/.*/$new_data/" "$table.txt"
        zenity --info --text="Line $line_num updated in $table."
    else
        zenity --error --text="Table does not exist!"
    fi
    database_menu
}

main_menu
