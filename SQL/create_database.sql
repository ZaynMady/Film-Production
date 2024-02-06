-- Active: 1706867141244@@localhost@3306@movie

--creating the new database
CREATE DATABASE film;

--using the new database
USE film;

--shotlist
CREATE TABLE Shotlist(
    shot_id INT NOT NULL UNIQUE AUTO_INCREMENT, 
    shot_size VARCHAR (255), 
    shot_angle VARCHAR(255), 
    movement VARCHAR (255), 
    details VARCHAR (3000),
    location_id INT,
    scene_id INT,
    FOREIGN KEY (location_id) REFERENCES locations(location_Id),
    FOREIGN KEY (scene_id) REFERENCES scenes(scene_id),
    PRIMARY KEY(shot_id)
);

--locations table--
CREATE TABLE locations (
    location_id INT NOT NULL UNIQUE AUTO_INCREMENT, 
    price FLOAT (8, 2), 
    _address VARCHAR(800), 
    _owner VARCHAR (255),
    PRIMARY KEY(location_id)
);
--list of scenes
CREATE TABLE scenes
(
    scene_id INT NOT NULL, 
    setting VARCHAR (20), 
    location_id INT,
    PRIMARY KEY (scene_id), 
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);
--list of crew
CREATE TABLE crew
(
    crew_id INT NOT NULL UNIQUE,
    _name VARCHAR(255),
    _role VARCHAR (255), 
    payment FLOAT (8 , 2),
    PRIMARY KEY(crew_id)
);
=
--list of equipment
CREATE TABLE equipment
(
    equipment_id INT NOT NULL UNIQUE,
    _name VARCHAR(255), 
    _type VARCHAR(255),
    _price FLOAT (8, 2),
    _owner VARCHAR (255)
);
--the shooting schedule
CREATE TABLE shooting_schedule 
(
    shot INT, 
    _location INT,
    _date DATE, 
    starttime TIME, 
    endtime TIME
);
--table of equipment used in a shot MANY TO MANY RELATIONSHIP
CREATE TABLE shoteq
(
    shot_id INT, 
    equipment_id INT, 
    FOREIGN KEY (shot_id) REFERENCES shotlist (shot_id),
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
);
--table of crew who works on a specific shot
CREATE TABLE crewshot
(
    shot_id INT, 
    crew_id INT,
    cost FLOAT (8, 2),
    FOREIGN KEY (shot_id) REFERENCES shotlist(shot_id),
    FOREIGN KEY (crew_id) REFERENCES crew(crew_id)
);

--creating a trigger that deletes all child rows whenever a parent row is deleted

--in the shotlist
DROP TRIGGER delete_shot_rows;

CREATE TRIGGER delete_shot_rows
BEFORE DELETE ON shotlist
FOR EACH ROW
BEGIN
    DELETE FROM crewshot WHERE shot_id = OLD.shot_id;
    DELETE FROM shoteq WHERE shot_id = OLD.shot_Id;
    DELETE FROM shooting_schedule WHERE shot = OLD.shot_id;
END;


 
 