INSERT INTO users (first_name, last_name)
VALUES ('emp1', 'last_name1');
INSERT INTO users (first_name, last_name)
VALUES ('emp2', 'last_name2');
INSERT INTO users (first_name, last_name)
VALUES ('emp3', 'last_name3');
INSERT INTO users (first_name, last_name)
VALUES ('emp4', 'last_name4');
INSERT INTO users (first_name, last_name)
VALUES ('emp5', 'last_name5');
INSERT INTO users (first_name, last_name)
VALUES ('matei', 'admin');

INSERT INTO teams (name, teamlead_id)
VALUES ('team1', 1);
INSERT INTO teams (name, teamlead_id)
VALUES ('team2', 2);
INSERT INTO teams(name, teamlead_id)
VALUES ('adminteam', 7);
INSERT INTO teams(name, teamlead_id)
VALUES ('team3', 4);


UPDATE users
SET team_id = 1
WHERE users.id IN (1, 3, 4);

UPDATE users
SET team_id = 2
WHERE users.id IN (2, 5);

CREATE OR REPLACE PROCEDURE add_to_project(user_id IN INT, project_id IN INT) IS
BEGIN
    BEGIN
        SELECT 1
        FROM projects
        WHERE project_id = project_id
          AND project_manager_id = (SELECT id FROM current_user);
    EXCEPTION
        WHEN no_data_found THEN
            raise_application_error(-20003, 'cant add to user to project');
    END;

    INSERT INTO project_users (project_id, user_id) VALUES (project_id, user_id);
END;

CREATE OR REPLACE TRIGGER add_project_trigger
    AFTER INSERT
    ON projects
    FOR EACH ROW
BEGIN
    INSERT INTO project_users (project_id, user_id) VALUES (:new.id, :new.project_manager_id);
END;


INSERT INTO projects (name, project_manager_id)
VALUES ('project1', 1);

INSERT INTO day_offs(date_in, date_out, type)
VALUES (to_date('10/01/2020', 'dd/mm/yyyy'), to_date('11/01/2020', 'dd/mm/yyyy'), 'holiday');
