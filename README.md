# Film-Production Prototype
Film Production Backend in Python and Database Design 

# Sql Folder

Inside the Sql Folder is two files, the first being the file in which the python program calls to create the database and the other one has some select statements that extracts some data from the database

# The Python File 

The Python file contains basically three sections 

**1 The Projects section:**  
the projects section contains the three main functions which create, open and delete a project, the first two return a sqlalchemy connection in which all later functions use

**2. the main add and delete functions section**

being a prototype I only exhibited the add to shotlist function as all other similar functions would probably use the same mechanism to add a row into it, and probably later would use an algorithm that uses different class objects for different tables to create a function that adds to the table based on the class attribute that stores all the column names.

the delete function however works on all tables, as the argument **kwargs allows the user to choose the column name as a keyword argument, for example if a user wishes to delete all shots where shot_angle is a high angle they would call the function like this 

```
   delete_row("shotlist", connect, shot_angle= "high angle" )
```

and then the function would separate the kwarg into two values and generate the query like this 
```
    column, value = next(iter(kwargs.items()))
        if type(value) is str:
            sqlquery = f"Delete FROM {table_name} WHERE {column} = '{value}'"
        elif type(value) is int:
            sqlquery = f"DELETE FROM {table_name} WHERE {column} = {value}"
        else: raise TypeError("Incorrect Data Type")

```
Side Note: since most of this database is relational I had to add triggers to the database design that automatically deletes all child rows when a parent row is deleted
for example if we wanted to delete a location saved in our database, the location being a parent row used in multiple relations throughout the database, the following trigger would set all fields in which this location was mentioned to NULL: 
```
    CREATE TRIGGER delete_location
    BEFORE DELETE ON locations
    FOR EACH ROW 
    BEGIN
        UPDATE shotlist
        SET location_id = NULL WHERE location_id = OLD.location_id;
        UPDATE scenes
        SET location_id = NULL WHERE location_id = OLD.location_id;
        UPDATE shooting_schedule
        SET _location = NULL WHERE _location = OLD.location_id;
    END;
 
```
and in other cases, for example, many to many tables, child rows will simply be deleted.

and finally, we execute the query and the row is dropped.
  

**3. The budget calculator:**

this basically takes a shot, and calculates the sum of wages of all the crew assigned to it, the prices of all equipment used in it, and the rent of the location it was shot in, and the sum of all them, and if there is no budget data for a specific shot in a shotlist attributes will automatically be set to zero. 

After storing the data in a shot_budget class, the shot is then stored in a list of <shot_budget> items, and then the list appends a wider list of lists named listofshots.

Finally we iterate through the lists inside listofshots to fill a Dataframe named Budget which is then returned to the user.

```
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
```


