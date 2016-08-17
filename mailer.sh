#!/bin/bash
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# mailer.sh E um simples programa para o envio de emails via smtp utilizando
# o modulo smtplib do python.
#
# Mateus Sousa, Agosto 2016
#
# Versao 1.0
#
# Licenca GPL
# TODO: adicionar mais servidores smtps. Em vez de usar 'ifs' use o 'case'!
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

zen='zenity'
PORT=
SERVER=
LOGIN=
MSG=
PASS=
TO=

send_mail(){
		foo="import smtplib;
		import time;
		var = smtplib.SMTP('"$SERVER"',"$PORT");
		var.ehlo();
		var.starttls();
		var.login('"$LOGIN"','"$PASS"');
		var.sendmail('"$LOGIN"','"$TO"','Subject: "$MSG"');
		time.sleep(2);
		var.quit()"
		foo=$(sed 's/^ //g' <<< $foo)
		
		python -c "$foo" 2> /tmp/error
		[ -z $(cat /tmp/error) ] && $zen --error --width 200 --text "Somethings goes wrong! Try later." && exit 2		
				
		$zen --info --text "Email send!" --width 200				
}

main(){
	$zen --info --width 200 --text "Welcome to the client smtp" 
	account=$($zen --entry --text "Insert the type of account. e.g gmail or hotmail" --width 400 --title "")

	if grep -i "gmail" <<< $account &> /dev/null 
	then
		SERVER='smtp.gmail.com'
		PORT=25
	elif grep -i "hotmail" <<< $account &> /dev/null
	then
		SERVER='smtp.live.com'
		PORT=25
	else	
		$zen --error --title "" --text "Invalid entry! Exiting..." --width 200
		exit 1
	fi

	LOGIN=$($zen --entry --text "Login" --title "" --width 200)
	[ -z "$LOGIN" ] && $zen --error --text "Invalid entry! Exiting..." && exit 2

	PASS=$($zen --password --text "Password")
	[ -z "$PASS" ] && $zen --error --text "Invalid entry! Exiting..." && exit 2
	
	TO=$($zen --entry --text "To" --title "" --width 200)
	[ -z "$TO" ] && $zen --error --text "Invalid entry! Exiting..." && exit 2
	
	MSG=$($zen --text-info --title "Mensagem" --editable)
	[ -z "$TO" ] && $zen --error --text "Invalid entry! Exiting..." && exit 2
	
	$zen --question 
	[ $? -ne 0 ] && $zen --info --text "Ok. Exiting..." --title "" --width 200
		
	send_mail
}

################################### CALL THE MAIN #######################################

main
