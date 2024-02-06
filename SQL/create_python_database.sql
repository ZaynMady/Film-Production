
CREATE TABLE locations (
    location_id INT NOT NULL UNIQUE AUTO_INCREMENT, 
    price FLOAT (8, 2), 
    _address VARCHAR(800), 
    _owner VARCHAR (255),
    PRIMARY KEY(location_id)
);

CREATE TABLE scenes
(
    scene_id INT NOT NULL AUTO_INCREMENT, 
    setting VARCHAR (20), 
    location_id INT,
    PRIMARY KEY (scene_id), 
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

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

CREATE TABLE crew
(
    crew_id INT NOT NULL UNIQUE AUTO_INCREMENT,
    _name VARCHAR(255),
    _role VARCHAR (255), 
    payment FLOAT (8 , 2),
    PRIMARY KEY(crew_id)
);

CREATE TABLE equipment
(
    equipment_id INT NOT NULL UNIQUE AUTO_INCREMENT,
    _name VARCHAR(255), 
    _type VARCHAR(255),
    _price FLOAT (8, 2),
    _owner VARCHAR (255)
);

CREATE TABLE shooting_schedule 
(
    shot INT, 
    _location INT,
    _date DATE, 
    starttime TIME, 
    endtime TIME,
    FOREIGN KEY (shot) REFERENCES shotlist(shot_id),
    FOREIGN KEY (_location) REFERENCES locations(location_id)
);

CREATE TABLE shoteq
(
    shot_id INT, 
    equipment_id INT, 
    FOREIGN KEY (shot_id) REFERENCES shotlist (shot_id),
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
);

CREATE TABLE crewshot
(
    shot_id INT, 
    crew_id INT,
    cost FLOAT (8, 2),
    FOREIGN KEY (shot_id) REFERENCES shotlist(shot_id),
    FOREIGN KEY (crew_id) REFERENCES crew(crew_id)
);

CREATE TRIGGER delete_location_rows
BEFORE DELETE ON locations
FOR EACH ROW 
BEGIN
    DELETE FROM shotlist WHERE location_id = OLD.location_id;
    DELETE FROM scenes WHERE location_id = OLD.location_id;
    DELETE FROM shooting_schedule WHERE _location = OLD.location_id;
END;

CREATE TRIGGER delete_crew_rows
BEFORE DELETE ON crew
FOR EACH ROW 
BEGIN
    DELETE FROM crewshot WHERE crew_id = OLD.crew_id;
END;

CREATE TRIGGER delete_equipment_rows
BEFORE DELETE ON equipment
FOR EACH ROW 
BEGIN
    DELETE FROM shoteq WHERE equipment_id = OLD.equipment_id;
END;

CREATE TRIGGER delete_shot_rows
BEFORE DELETE ON shotlist
FOR EACH ROW
BEGIN
    DELETE FROM crewshot WHERE shot_id = OLD.shot_id;
    DELETE FROM shoteq WHERE shot_id = OLD.shot_Id;
    DELETE FROM shooting_schedule WHERE shot = OLD.shot_id;
END;