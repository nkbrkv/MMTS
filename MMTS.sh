#!/bin/bash

function file_migration () {

    #enter value
    echo "file migration"
    read -p "Source path: " SOURCE
    read -p "Destination path: " DESTINATION

    if [[ "$DESTINATION" == *"$USER"* ]]; then

        #sync content
        rsync -avhP $SOURCE $DESTINATION 1>/dev/null
        
        #change owner
        chown -R $USER:$USER $DESTINATION
        chown -v $USER:nobody $DESTINATION
        

    fi
}

function mail_migration () {
    
    echo "In developing"
    
    }

function create_db () {
    
    #enter value
    echo
    PASS_DB=$(openssl rand -base64 12)
    NAME_DB=$(cat /dev/urandom | tr -d -c '0-9A-Z' | fold -w 5 | head -1)

    /scripts/shellaccess $USER > /dev/null 2>&1
    #create database
    su $USER -c "uapi Mysql create_database name='$USER'_'$NAME_DB'"

    #create user
    su $USER -c "uapi Mysql create_user name='$USER'_'$NAME_DB' password='$PASS_DB'"

    #privileges
    su $USER -c "uapi Mysql set_privileges_on_database user='$USER'_'$NAME_DB' database='$USER'_'$NAME_DB' privileges=ALL%20PRIVILEGES"

    clear

    echo 
    echo
    echo "+++++++++++ DATABASE INFO ++++++++++++++++"
    echo "DB: $USER"_"$NAME_DB" 
    echo "Pass: $PASS_DB"
    echo "++++++++++++++++++++++++++++++++++++++++++"
    echo
    echo

}

function create_mailbox () {

    #enter value
    echo
    read -p "Enter mailbox name: " MAILBOX_NAME
    read -p "Enter password: " PASSWORD
    read -p "Enter domain: " DOMAIN

    #create mailbox
    uapi --user=$USER Email add_pop email=$MAILBOX_NAME password=$PASSWORD quota=0 domain=$DOMAIN skip_update_db=1
    echo
}

function create_mailboxes_from_list () {
    
    echo
    read -p "LIST FILENAME: " LIST_FILENAME
    read -p "Enter password: " PASSWORD
    read -p "Enter domain: " DOMAIN

    for i in $(cat $LIST_FILENAME)
    do
    #create mailbox
        uapi --user=$USER Email add_pop email=$i password=$PASSWORD quota=0 domain=$DOMAIN skip_update_db=1
    done
    echo
}

function change_owner () {

    read -p "Enter reseller name: " RESELLER_NAME

    #change owner
    whmapi1 modifyacct user=$USER owner=$RESELLER_NAME
    echo

}

#START PROGRAM

echo
echo "++++++++++++++++++++++++++++++++++++++++++"
echo "++++++                             +++++++"
echo "++++++ MIGRATION MULTI-TOOL SCRIPT +++++++"
echo "++++++                             +++++++"
echo "++++++++++++++++++++++++++++++++++++++++++"
echo

#enter username
read -p "Username: " USER
echo

#MENU
PS3="Select an operation or press 7 to exit:"

select opt in "File migration" "Mail migration" "Change owner" "Create mailbox" "Create mailboxes from the list" "Create MySQL DB" "Exit"
do
    case $opt in

        "File migration")
            file_migration ;;
        "Mail migration")
            mail_migration ;;
        "Change owner")
            change_owner ;;    
        "Create mailbox")
            create_mailbox ;;
        "Create mailboxes from the list")
            create_mailboxes_from_list ;;
        "Create MySQL DB")
            create_db ;; 
        "Exit")
            echo
            echo "Exit"
            echo
            break ;;
        *)
            echo 'Invalid option';;
    esac
done


