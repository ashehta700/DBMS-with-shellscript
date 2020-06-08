#!/bin/bash

#functions dbms
clear
DBMS="databases";
if [[ ! -d ./$DBMS ]];
then 
    mkdir $DBMS
fi 
#-------------------------------------------------#   
#----------------------DataBase-------------------#
# to Create New DB    -----  #1
function createDB {
    read -p "Enter Database Name : " dbName;
	if [[ ! -d ./$DBMS/$dbName ]];
	then 
        mkdir ./$DBMS/$dbName;
		if [[ $? == 0 ]]; 
		then
		  echo $dbName" Database Created Successfully" ;
		else	
		 echo "Error While Creating the Database" ;
		fi
	else	
	  echo "Database Already Exists";
	fi

}
# To connect To DataBase -----   #3  
function connectDB {
  echo -e "Enter Database Name: \c"
  read dbName
  cd ./$DBMS/$dbName 
  2>>./.error.log
  if [[ $? == 0 ]]; 
  then  
  echo "Database $dbName was Successfully Selected"  
  else  
  echo "Database $dbName wasn't found"   
  fi
}
#To Delete DB
function dropDB {
  read -p "Enter Database Name : " dbName;
  if [[ -d ./$DBMS/$dbName ]];
  then
      rm -r ./$DBMS/$dbName 
	  echo "Database Dropped Successfully"
  else
	  echo "Database Not found"
  fi
	 
}

#-----------------------------------------------#
#----------------------Tables-------------------#
# Create A new Table   ------- # 5
function createTable {
    read -p "Enter Database Name : " dbName;
    #we must check the table that is found or not
    if [[ -d ./$DBMS/$dbName ]];
	then 
       cd ./$DBMS/$dbName
       read -p "Enter Table Name : " tableName;
	   if [[ -f $tableName ]];
	   then 
	       echo "Table Already Exists"
	   else
           sep=":"
           newLine="\n"
           pKeyFlag="0"
           metaData="Field"$sep"Type"$sep"Key"$sep"Default"$sep"Unique"$sep"Null"
           read -p "Enter Number Of Columns : " colN;
           for((i=1;i<=colN;i++))
           {
             read -p "Enter The Name Of Column No.$i : " colName;
             echo "Type Of Column $colName : "
             select type in int str
             do
               case $type in
                   int) colType="int";break;;
                   str) colType="str";break;;
                   *) echo "Invalid Option";;
               esac
             done
             if [[ $pKeyFlag == "0" ]];
             then
                 echo "Is Column $colName a Primary Key? "
                 select pk in yes no
                 do
                   case $pk in
                       yes) 
                       pKeyFlag="1"
                       primaryKey="PK";
                       isUnique="yes";
                       acceptNull="no"
                       defaultValue=""
                       metaData+=$newLine$colName$sep$colType$sep$primaryKey$sep$defaultValue$sep$isUnique$sep$acceptNull;
                       break;;
                       no) 
                       primaryKey="";
                       echo "Is Column $colName Unique? "
                       select unique in yes no
                       do
                         case $unique in
                             yes) isUnique="yes";break;;
                             no) isUnique="no";break;;
                             *) echo "Invalid Option";;
                         esac
                       done
                       echo "Does Column $colName Accept NULL? "
                       select null in yes no
                       do
                         case $null in
                             yes) acceptNull="yes";break;;
                             no) acceptNull="no";break;;
                             *) echo "Invalid Option";;
                         esac
                       done
                       echo "Does Column $colName Have a Default Value? "
                       select default in yes no
                       do
                         case $default in
                             yes) read -p "Enter The Default Value Of Column $colName : " defaultValue;break;;
                             no) defaultValue="";break;;
                             *) echo "Invalid Option";;
                         esac
                       done
                       metaData+=$newLine$colName$sep$colType$sep$primaryKey$sep$defaultValue$sep$isUnique$sep$acceptNull;
                       break;;
                       *) echo "Invalid Option";;
                   esac
                 done           
             else
             primaryKey="";
             echo "Is Column $colName Unique? "
             select unique in yes no
             do
               case $unique in
                   yes) isUnique="yes";break;;
                   no) isUnique="no";break;;
                   *) echo "Invalid Option";;
               esac
             done
             echo "Does Column $colName Accept NULL? "
             select null in yes no
             do
               case $null in
                   yes) acceptNull="yes";break;;
                   no) acceptNull="no";break;;
                   *) echo "Invalid Option";;
               esac
             done
             echo "Does Column $colName Have a Default Value? "
             select default in yes no
             do
               case $default in
                   yes) read -p "Enter The Default Value Of Column $colName : " defaultValue;break;;
                   no) defaultValue="";break;;
                   *) echo "Invalid Option";;
               esac
             done
             metaData+=$newLine$colName$sep$colType$sep$primaryKey$sep$defaultValue$sep$isUnique$sep$acceptNull;
             fi
             if [[ $i == $colN ]]; 
             then
             columns+=$colName;
             else
             columns+=$colName$sep;
             fi
           }
        touch .$tableName
        echo -e $metaData  >> .$tableName
        touch $tableName
        echo -e $columns >> $tableName
        columns=""
        if [[ $? == 0 ]]
        then
          echo "Table Created Successfully"
        else
          echo "Error Creating Table $tableName"     
	    fi
       fi
        cd ../..
	else
           echo "Database Not found";
	fi
}

#insert into table  ----------#6
function insertTable
{
  row=""
read -p "Enter Database Name : " dbName;
  if ! [[ -d ./$DBMS/$dbName ]];then
     echo "Database Not found";
  else
    cd ./$DBMS/$dbName
    read -p "Enter Table Name : " tableName;
    if ! [[ -f $tableName ]];then
          echo "Table $tableName doesn't exist"
    else
        colsNum=$(cat .$tableName | wc -l)
        sep=":"
        newLine="\n"
        for (( i=2; i<=$colsNum; i++))
        do        
          name=$(awk -F ":" '{ if(NR=='$i') print $1}' .$tableName)
          ttype=$( awk -F ":" '{if(NR=='$i') print $2}' .$tableName)
          key=$( awk -F ":" '{if(NR=='$i') print $3}' .$tableName)
          default=$( awk -F ":" '{if(NR=='$i') print $4}' .$tableName)
          unique=$( awk -F ":" '{if(NR=='$i') print $5}' .$tableName)
          null=$( awk -F ":" '{if(NR=='$i') print $6}' .$tableName)
            echo -e "Enter $name ($ttype) Value: \n"         
          read input
          if [[ $null == "no" ]]; then
           while [[ true ]]; do
            if [[ $input = "" ]]; then
             echo -e "invalid input, coulmn doesn't accept null !!"
            else
             break;
            fi
            echo -e "Enter $name ($ttype) Value: \n"         
            read input
           done
         fi
         if ! [[ $default == "" ]]; then
          if [[ $input = "" ]]; then
            input=$default
          fi  
         fi 
         if [[ $ttype == "int" ]]; then
           while ! [[ $input =~ ^[0-9]*$ ]]; do
            echo -e "invalid DataType !!"
            cd ../..
            insert
            return
           done
         fi
        if [[ $key == "PK" ]]; then        
            if [[ $input =~ ^[`awk 'BEGIN{FS=":" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
             echo -e "invalid input for Primary Key !!"
            cd ../..
            insert
            return          
         fi
         fi
      if [[ $unique == "yes" ]]; then         
            if [[ $input =~ ^[`awk 'BEGIN{FS=":" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
             echo -e "enter a unique value!!"         
            cd ../..
            insert
            return
         fi
         fi   
      if [[ $i == $colsNum ]]; then
       row+=$input$newLine
      else
       row+=$input$sep
      fi
      done #for end
        echo -e $row"\c" >> $tableName
        if [[ $? == 0 ]]
        then
         echo "Data Inserted Successfully"
        else
         echo "Error Inserting Data into Table $tableName"
        fi
  row=""
cd ../..
    fi
fi
}

# List the Table ------------# 6
function displayTable {
    read -p "Enter Database Name : " dbName;
    if [[ -d ./$DBMS/$dbName ]];
	  then 
       ls ./$DBMS/$dbName
	  else
           echo "Database Not found";
	fi
}

#To Select From Tables ---------- # 7
function selectR {
	read -p "Enter Database Name : " dbName;
        if [[ -d ./$DBMS/$dbName ]];
	then 
	   cd ./$DBMS/$dbName
	   read -p "Enter Table Name : " tableName;
           if [[ -f $tableName ]];
	   then 
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"	
		echo "         S E L E C T- M E N U          "
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		echo "1. Select Records Matching Word"
		echo "2. Select One Field"
		echo "3. Select More Than Field"
		echo "4. Select * From Table"
		echo "5. Exit"
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		local choice
		read -p "Enter A Choice [ 1 - 4 ] " choice
		case $choice in
		1)selectRecordA;;
		2)selectRecordO;;
		3)selectRecordM;;
		4)selectT;;
		5)exit 0;; 
		*) echo "Invalid Option";;
	        esac
	   else
		echo "Table Not found";      
           fi
	   cd ../.. 
       else 
        echo "Database Not found";
       fi

}
#To Select From Tables ---------- # 7 (.cont)
function selectT {
	 read -p "Enter Format HTML or CSV : " format;
	 result=$(cat $tableName)
	   if [[ -z $result ]]
           then
                  echo "Not Found"
           else
			case $format in
			HTML)
			  echo "$result <br>" > "$tableName.html";;
			CSV) 
		          echo "$result" > "$tableName.csv";;
			*) echo "Invalid Choice"
		        esac
	
      fi
            
	

}
#To Select From Tables ---------- # 7 (.cont)
function selectRecordA {
	 read -p "Enter value that you want to search : " value;
	 read -p "Enter Format HTML or CSV : " format;
		result=$(sed -n -e'/'$value'/p' $tableName)
                if [[ -z $result ]]
                then
                  echo "Not Found"
                else
			case $format in
			HTML)
			  echo "$result <br>" > "$tableName.html";;
			CSV) 
		          echo "$result" > "$tableName.csv";;
			*) echo "Invalid Choice"
		        esac
	
                fi
            
}
#To Select From Tables ---------- # 7 (.cont)
function selectRecordO {
	read -p "Enter Field Name that you want select it" Field
	read -p "Enter Field Name to search in it " FieldS
        Fieldnum=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$Field'") print i}}}' $tableName)
	FieldnumS=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$FieldS'") print i}}}' $tableName)
 	echo $FieldnumS
	read -p "Enter Condition that you want to search : " condition
	read -p "Enter Format HTML or CSV : " format;
	      
	res=$(awk -v c="$condition" 'BEGIN{FS=":"} $"'$FieldnumS'" == c {print $'$Fieldnum'}' $tableName)
	echo $res
	if [ -z $res ]
        then
              echo "Not Found"
        else
                       case $format in
			HTML)
			  echo "$res <br>" > "$tableName.html";;
			CSV) 
		          echo "$res" > "$tableName.csv";;
			*) echo "Invalid Choice"
		        esac
	

       fi
 
}
#To Select From Tables ---------- # 7 (.cont)
function selectRecordM {
  read -p "Enter Fields Names that you want select it" Fields
  read -p "Enter Field Name to search in it " Field
	FieldnumS=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$Field'") print i}}}' $tableName)
  IFS=' ' read -r -a array <<< "$Fields"
  read -p "Enter condition that you want to search : " condition;
  read -p "Enter Format HTML or CSV : " format;
  rm $tableName.html 
  for element in "${array[@]}"
  do
   : 
   Fieldnum=$(awk 'BEGIN{FS=":";}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$element'") print i}}}' $tableName)

	  if [[ $Fieldnum == "" ]]
	  then
	    echo "Not Found"
	  else
		result=$(awk -v c="$condition" 'BEGIN{FS=":"} $"'$FieldnumS'" == c {print $'$Fieldnum'}' $tableName)
	
		if [[ -z $result ]]
                then
                  echo "Not Found"
                else
                   case $format in
			HTML)
			  echo "$result <br>"  >> "$tableName.html";;
			  
			CSV) 
		          echo "$result" >> "$tableName.csv";;
			*) echo "Invalid Choice"
		   esac
                fi
	   fi
 		
  done
  
}

#To Drop Table -----------# 8
function dropTable {
    read -p "Enter Database Name : " dbName;
    if [[ -d ./$DBMS/$dbName ]];
	then 
       cd ./$DBMS/$dbName
       read -p "Enter Table Name : " tableName;
	   if [[ -f $tableName ]];
	   then 
	       rm $tableName .$tableName 
           if [[ $? == 0 ]]
           then
               echo "Table Dropped Successfully"
           else
               echo "Error Dropping Table $tableName"
           fi
	   else
           echo "Table Not found";      
	   fi
       cd ../..
	else
           echo "Database Not found";
	fi
}


# Delete Records  from Table --------- # 9
function deleteTable
{

  read -p "Enter Database Name : " dbName;
  if ! [[ -d ./$DBMS/$dbName ]];then
     echo "Database Not found";
  else
    cd ./$DBMS/$dbName
    read -p "Enter Table Name : " tableName;
    if ! [[ -f $tableName ]];then
          echo "Table $tableName doesn't exist"
    else
      read -p "Enter condition Column name : " cf
      cf=$(awk -F ":" '{ if(NR==1) {for(i=1;i<=NF;i++){if($i=="'$cf'") print i}}}' $tableName)
      if [[ $cf == "" ]]
      then
        echo "Not Found"
      else
        echo -e "Enter Condition Value: \c"
        read val
        res=$(awk -F ":" '{if ($'$cf'=="'$val'" && NR!=1) print $'$cf'}' $tableName)
        if [[ $res == "" ]]
        then
         echo "Value Not Found"
         
        else
         
         NR=$(awk -F ":" '{if ($'$cf'=="'$val'" && NR!=1) print $0}' $tableName)
        
         for it in $NR;
         do
          
         sed -i "/$it/d" $tableName 
         echo "Row Deleted Successfully"
         done
         
      fi
    fi
  fi
  cd ../..
  fi
}


#function show menu
show_menu() {	
	echo "D.B.M.S==SHELL SCRIPT"
	echo "======== Menu For DB ============="
  echo "| 1. Create DB                   |"
	echo "| 2. List DBs                    |"
  echo "| 3. Connect DB                  |"
	echo "| 4. Drop DB                     |"
  echo "======== Menu For Table =========="
	echo "| 5. create table                |"
	echo "| 6. list tables                 |"
	echo "| 7. Insert table                |"
	echo "| 8. Select table                |"
	echo "| 9. Drop table                  |"
	echo "| 10. Delete table               |"
	echo "| 11. Exit                       |"
}

#function read
read_option(){
	local choice
	read -p "Enter A Choice From [ 1 - 11 ] " choice
	case $choice in
		1)createDB;;
		2)ls $DBMS;;
		3)connectDB;;
		4)dropDB;;
		5)createTable;;
		6)displayTable;;
		7) insertTable ;;
		8)selectR;;
		9) dropTable ;;
    10) deleteTable;;
		11) exit 0;;
		*) echo "Invalid Option";;
	esac
}

while true
do
 
	show_menu
	read_option
done


