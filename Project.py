
import mysql.connector
from mysql.connector import errorcode
import mysql
import pandas as pd
from sqlalchemy import exc, create_engine
import sqlalchemy

#mysql url elements
host = "localhost"
username = "root"
password = "earth616"
port = "3306"

#mysql url 
mysql_url = "mysql+pymysql://"+ username + ':' + password + '@' + host + ':' + port + '/' 

#The Three Main Functions ACCESSING, CREATING AND DELETING A PROJECT

def open_project(current_project):
        try:
            current_project = current_project.strip().replace(" ", "_").capitalize()
            return create_engine(mysql_url + current_project).connect()
        except exc.OperationalError:
             print("database does not exist")

def create_project(project_name: str):
    project_name = project_name.strip().replace(" ", "_").capitalize()
    #trying to connect to the mysql server
    connection = mysql.connector.connect(user=username, password= password, host= host)
    cursor = connection.cursor()
   #creating the database
    try:
        cursor.execute(f"CREATE DATABASE {project_name}")
        cursor.execute(f"USE {project_name}")
        connection.commit()

    #accessin the create database sql file
        with open("SQL//create_python_database.sql", "r") as file:
            sqlfile = file.read()
            file.close()

        #splitting it into multiple sql queries
        queries = [query.strip() for query in sqlfile.split("\n\n")]

        #executing all the queries in the file
        for query in queries:
            cursor.execute(query)
            connection.commit()

        cursor.close()
        connection.close()
        #function returns a sqlalchemy connection for future functions to use 
        return create_engine(mysql_url + project_name)
    
    except mysql.connector.errors.DatabaseError:
        print("Database Already Exists")
   

def delete_project(project):
    try:
        project = project.strip().lower().replace(" ", "_").capitalize()
        connection = mysql.connector.connect(host=host, user=username, password=password)

        cursor = connection.cursor()
        #delete it
        cursor.execute(f"DROP DATABASE {project}") 
        #commit changes
        connection.commit()
        connection.close() 
    except mysql.connector.DatabaseError:
        print("Database does not exist")


#performing some python operations and interacting with the database, I will demonstrate them on the shotlist table

#adding elements to a table, here I will only add the method to add data to a shotlist as a prototype for the feature
def add_shot(shotsize : str, shotangle : str, movement : str, description : str, conn : sqlalchemy.Connection):
    if type(shotsize) is not str or type(shotangle) is not str or type(description) is not str or type(movement) is not str:
        raise TypeError("Attributes must be of type string")
    else:
        data = [{
            "shot_size" : shotsize, 
            "shot_angle" : shotangle, 
            "movement" : movement, 
            "details" : description
        }]

        df = pd.DataFrame(data)
        df.to_sql(name="shotlist", if_exists="append", con=conn, index=False)

#extracting a table
def read_table(table_name : str, conn : sqlalchemy.Connection, *arg : list[str]):
    if not arg:
        sqlquery = pd.read_sql_query(f"SELECT * FROM {table_name}", conn)
    else: 
        columns = ', '.join(arg)
        sqlquery = pd.read_sql_query(f"SELECT {columns} FROM {table_name}", con=conn)
    
    df = pd.DataFrame(sqlquery)
    return df
        
#deleting element from a table based on the id, in this example the shotlist
def delete_row(table_name: str, conn: sqlalchemy.Connection, **kwargs):
    if len(kwargs) == 1:
        column, value = next(iter(kwargs.items()))
        if type(value) is str:
            sqlquery = f"Delete FROM {table_name} WHERE {column} = '{value}'"
        elif type(value) is int:
            sqlquery = f"DELETE FROM {table_name} WHERE {column} = {value}"
        else: raise TypeError("Incorrect Data Type")
        try:
            conn.execute(sqlalchemy.text(sqlquery))
            conn.commit()
        except exc.OperationalError:
            print("Error: The column  you have entered does not exist")
        except exc.ProgrammingError:
            print("Error: The Table you have entered does not exist")
    else:
        raise TypeError("too many arguments passed, please enter only one column name")

class shot_budget:
    def __init__(self, id: int, conn: sqlalchemy.Connection) -> None:
        self.id = id
        try:
            #crew wages
            df = pd.read_sql_query(f"SELECT SUM(payment) AS total_crew_payment FROM crewshot INNER JOIN crew ON crew.crew_id = crewshot.crew_id WHERE shot_id = {self.id}", con=conn)
            #assigning it to the crew_budget attribute
            self.crew_wages = df["total_crew_payment"].iloc[0]

            #location rent
            df2 = pd.read_sql_query(f"SELECT price FROM shotlist INNER JOIN locations ON locations.location_id = shotlist.location_id WHERE shot_id = {self.id} ", con=conn)
            #assigning it to the crew_budget attribute
            self.location_rent = df2["price"].iloc[0]

            df3 = pd.read_sql_query(f"SELECT SUM(_price) AS total_eq_price FROM shoteq INNER JOIN equipment ON equipment.equipment_id = shoteq.equipment_id WHERE shot_id = {self.id}", con=conn)
            #assigning it to the crew_budget attribute
            self.equipment_prices = df3["total_eq_price"].iloc[0]
            #total budget

            self.total_shot_budget = self.crew_wages + self.location_rent + self.equipment_prices
        except IndexError:
            print(f"Shot {self.id} has no budget data, so all attributes would be set to zero")
            self.crew_wages = 0
            self.equipment_prices = 0
            self.location_rent = 0
            self.total_shot_budget = 0

def calculatebudget(conn : sqlalchemy.Connection):
    #budget report in python, and how much each shot will take, costs our calculated per hour
    budget = pd.DataFrame(columns=["shot_id", "total cost of crew", "total cost of equipment", "cost of location rent", "total cost"])

    df = pd.read_sql("SELECT shot_id FROM shotlist", con=conn)

    shotids = df["shot_id"].to_list()
    listofshots = list()

    for shotid in shotids:
        shot = shot_budget(id=shotid, conn=conn)
        listofshot = [shot.id, shot.crew_wages, shot.equipment_prices, shot.location_rent, shot.total_shot_budget]
        listofshots.append(listofshot)
    
    for i in range (len(listofshots)):
        budget.loc[len(budget)] = listofshots[i]
        

    return budget


