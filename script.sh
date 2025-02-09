#!/bin/bash

function main_menu() {
    echo "============================="
    echo "    Bash DBMS System"
    echo "============================="
    echo "1) Create Database"
    echo "2) List Databases"
    echo "3) Connect to Database"
    echo "4) Drop Database"
    echo "5) Exit"
    echo "============================="
    echo "Choose an option: "
    read choice
    case $choice in
        1) create_database ;;
        2) list_databases ;;
        3) connect_database ;;
        4) drop_database ;;
        5) exit 0 ;;
        *) echo "Invalid option"; main_menu ;;
    esac
}
function create_database() {
    echo "Enter database name: "
    read dbname
    if [ -d "$dbname" ]; then
        echo "Database already exists!"
    else
        mkdir "$dbname"
        echo "Database '$dbname' created successfully."
    fi
    main_menu
}
function list_databases() {
    
    echo "Available Databases:"
    ls -d */
    main_menu
    
}
function connect_database() {
    echo "Enter database name to connect: "
    read dbname
    if [ -d "$dbname" ]; then
        cd "$dbname"
        echo " Connected to database '$dbname'."
        database_menu
    else
        echo "Database not found!"
        main_menu
    fi
}
function drop_database() {
    echo "Enter database name to delete: "
    read dbname
    if [ -d "$dbname" ]; then
        rm -r "$dbname"
        echo "Database '$dbname' deleted."
    else
        echo "Database not found!"
        main_menu
    fi
    
}
function database_menu() {
    echo "============================="
    echo "Managing Tables in $dbname"
    echo "============================="
    echo "1) Create Table"
    echo "2) List Table"
    echo "3) Drop Table"
    echo "4) Insert into Table"
    echo "5) Select From Table"
    echo "6) Delete From Table"
    echo "7) Update Table"
    echo "8) Return to Main Menu"
    echo "============================="
    read -p "Choose an option: " choice
    case $choice in
        1) create_table ;;
        2) list_tables ;;
        3) drop_table ;;
        4) insert_into_table ;;
        5) select_from_table ;;
        6) delete_from_table ;;
        7) update_table ;;
        8) main_menu ;;
        *) echo "Invalid option"; database_menu ;;
    esac
}

function create_table() {
    echo "Enter table name: "
    read table

    if [ -f "$table.txt" ]; then
        echo "Table already exists!"
    else
        read -p "Enter primary key column name: " primary_key

        echo "Enter number of columns: "
        read col_count

        columns=()
        data_types=()

        for ((i = 1; i <= col_count; i++)); do
            read -p "Enter name for column $i: " col_name
            read -p "Enter data type for column $col_name (e.g., INT, STRING, FLOAT): " col_type
            columns+=("$col_name")
            data_types+=("$col_type")
        done

        header="Primary Key: $primary_key | Columns: ${columns[*]} | Data Types: ${data_types[*]}"
        echo "$header" > "$table.txt"

        echo "Table '$table' with primary key '$primary_key' and columns [${columns[*]}] created successfully."
    fi

    database_menu
}

function list_tables() {
    echo "Available Tables:"
    ls *.txt
    database_menu
}
function drop_table() {
    echo "Enter table name to delete: "
    read table
    if [ -f "$table.txt" ]; then
        rm "$table.txt"
        echo "Table '$table' deleted."
    else
        echo "Table not found!"
    fi
    database_menu
}

function insert_into_table() {
    echo "Enter table name to insert into: "
    read table

    if [ -f "$table.txt" ]; then
        echo "Enter data to insert: comma-separated values, first value is Primary Key"
        read data

        primary_key_value=$(echo "$data" | cut -d ',' -f1)

        if grep -q "^$primary_key_value," "$table.txt"; then
            echo "Error: Primary key '$primary_key_value' already exists!"
        else
            metadata=$(head -n 1 "$table.txt")
            columns=$(echo "$metadata" | cut -d '|' -f2 | sed 's/ Columns: //')
            data_types=$(echo "$metadata" | cut -d '|' -f3 | sed 's/ Data Types: //')

            IFS=' ' read -ra type_array <<< "$data_types"
            IFS=',' read -ra value_array <<< "$data"

            has_error=false

            for ((i=1; i<=${#type_array[@]}; i++)); do
                case "${type_array[$((i-1))]}" in
                    INT) 
                        if ! [[ "${value_array[$i]}" =~ ^[0-9]+$ ]]; then 
                            echo "Error: Column $((i+1)) must be INT."
                            has_error=true
                        fi 
                        ;;
                    FLOAT) 
                        if ! [[ "${value_array[$i]}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then 
                            echo "Error: Column $((i+1)) must be FLOAT."
                            has_error=true
                        fi 
                        ;;
                    STRING) 
                        if ! [[ "${value_array[$i]}" =~ ^[a-zA-Z0-9@._-]+$ ]]; then 
                            echo "Error: Column $((i+1)) must be STRING."
                            has_error=true
                        fi 
                        ;;
                    *) echo "Warning: Unknown type '${type_array[$((i-1))]}'" ;;
                esac
            done

            if ! [ "$has_error" = true ]; then
                echo "$data" >> "$table.txt"
                echo "Data inserted into $table successfully."
            fi
            
        fi
    else
        echo "Table '$table' does not exist!"
    fi
    database_menu
}


function select_from_table() {
    echo "Enter table name to select from: "
    read table
    if [ -f "$table.txt" ]; then
        echo "Displaying table content columns in header:"
        # Show columns (first line) as headers
        header=$(head -n 1 "$table.txt")
        echo "Columns: $header"
        # Display data with line numbers
        nl -ba "$table.txt"
    else
        echo "Table '$table' does not exist!"
    fi
    database_menu
}
function delete_from_table() {
    echo "Enter table name to delete from: "
    read table
    if [ -f "$table.txt" ]; then
        echo "Displaying table content with line numbers:"
        # Show columns (first line) as headers
        header=$(head -n 1 "$table.txt")
        echo "Columns: $header"
        # Display data with line number
        nl -ba "$table.txt"
        echo "Enter the line number to delete: "
        read line
        sed -i "${line}d" "$table.txt"
        echo "Line $line deleted from "
        
    else
        echo "Table '$table' does not exist"
    fi
    database_menu
}


function update_table() {
    echo "Enter table name to update: "
    read table

    if [ -f "$table.txt" ]; then
        echo "Displaying table content with line numbers:"
        
        header=$(head -n 1 "$table.txt")
        echo "Columns: $header"

        nl -ba "$table.txt"

        echo "Enter the line number to update: "
        read line

        echo "Enter the new data comma-separated: "
        read new_data

        metadata=$(head -n 1 "$table.txt")
        data_types=$(echo "$metadata" | cut -d '|' -f3 | sed 's/ Data Types: //')

        IFS=' ' read -ra type_array <<< "$data_types"
        IFS=',' read -ra value_array <<< "$new_data"


        if [ "$line" -le 1 ] || [ "$line" -gt "$(wc -l < "$table.txt")" ]; then
            echo "Error: Invalid line number!"
            return
        fi

        has_error=false

        for ((i=1; i<=${#type_array[@]}; i++)); do
            case "${type_array[$((i-1))]}" in
                INT) 
                    if ! [[ "${value_array[$i]}" =~ ^[0-9]+$ ]]; then 
                        echo "Error: Column $((i+1)) must be INT."
                        has_error=true 
                    fi 
                    ;;
                FLOAT) 
                    if ! [[ "${value_array[$i]}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then 
                        echo "Error: Column $((i+1)) must be FLOAT."
                        has_error=true
                    fi 
                    ;;
                STRING) 
                    if ! [[ "${value_array[$i]}" =~ ^[a-zA-Z0-9@._-]+$ ]]; then 
                        echo "Error: Column $((i+1)) must be STRING."
                        has_error=true
                    fi 
                    ;;
                *) echo "Warning: Unknown type '${type_array[$((i-1))]}'" ;;
            esac
        done


        if ! [ "$has_error" = true ]; then
            formatted_data=$(echo "$new_data" | sed 's/[\/&]/\\&/g')
            sed -i "${line}s/.*/$formatted_data/" "$table.txt"
            echo "Line $line updated in $table"
        fi
        
    else
        echo "Table '$table' does not exist!"
    fi
    database_menu
}

main_menu
