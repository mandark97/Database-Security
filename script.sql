CREATE TABLE users
(
    id         NUMBER GENERATED AS IDENTITY
        CONSTRAINT user_pk
            PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name  VARCHAR2(50) NOT NULL,
    team_id    NUMBER
)
/

CREATE TABLE teams
(
    id          NUMBER GENERATED AS IDENTITY
        CONSTRAINT team_pk
            PRIMARY KEY,
    name        VARCHAR2(50) NOT NULL,
    teamlead_id NUMBER
        CONSTRAINT team_user_id_fk
            REFERENCES users
)
/

ALTER TABLE users
    ADD CONSTRAINT users_teams_id_fk
        FOREIGN KEY (team_id) REFERENCES teams
/

CREATE UNIQUE INDEX teams_teamlead_id_uindex
    ON teams (teamlead_id)
/

CREATE OR REPLACE TRIGGER add_team_trigger
    AFTER INSERT
    ON teams
    FOR EACH ROW
BEGIN
    UPDATE users
    SET team_id = :new.id
    WHERE id = :new.teamlead_id;
END;
/

CREATE TABLE projects
(
    id                 NUMBER GENERATED AS IDENTITY
        CONSTRAINT projects_pk
            PRIMARY KEY,
    name               VARCHAR2(50) NOT NULL,
    project_manager_id NUMBER       NOT NULL
        CONSTRAINT projects_users_id_fk
            REFERENCES users
)
/

CREATE OR REPLACE TRIGGER add_project_trigger
    AFTER INSERT
    ON projects
    FOR EACH ROW
BEGIN
    INSERT INTO project_users (project_id, user_id) VALUES (:new.id, :new.project_manager_id);
END;
/

CREATE TABLE project_users
(
    project_id NUMBER NOT NULL
        CONSTRAINT project_users_projects__fk
            REFERENCES projects
                ON DELETE CASCADE,
    user_id    NUMBER NOT NULL
        CONSTRAINT project_users_users__fk
            REFERENCES users
                ON DELETE CASCADE
)
/

CREATE UNIQUE INDEX project_users_project_id_user_id_uindex
    ON project_users (project_id, user_id)
/

ALTER TABLE project_users
    ADD CONSTRAINT project_users_pk
        PRIMARY KEY (project_id, user_id)
/

CREATE TABLE activities
(
    id         NUMBER NOT NULL
        CONSTRAINT activities_pk
            PRIMARY KEY,
    date_in    DATE   NOT NULL,
    date_out   DATE,
    project_id NUMBER NOT NULL,
    user_id    NUMBER NOT NULL,
    CONSTRAINT activities_project_users_project_id_user_id_fk
        FOREIGN KEY (project_id, user_id) REFERENCES project_users
            ON DELETE CASCADE
)
/

CREATE INDEX activities_user_id_project_id_index
    ON activities (user_id, project_id)
/

CREATE TABLE user_details
(
    id           NUMBER GENERATED AS IDENTITY
        CONSTRAINT user_details_pk
            PRIMARY KEY,
    holiday_days NUMBER DEFAULT 21 NOT NULL,
    bonus_days   NUMBER DEFAULT 0  NOT NULL,
    user_id      NUMBER
        CONSTRAINT user_details_users_id_fk
            REFERENCES users
)
/

CREATE UNIQUE INDEX user_details_user_id_uindex
    ON user_details (user_id)
/

CREATE TABLE day_offs
(
    id          NUMBER GENERATED AS IDENTITY
        CONSTRAINT day_offs_pk
            PRIMARY KEY,
    date_in     DATE                           NOT NULL,
    date_out    DATE                           NOT NULL,
    description VARCHAR2(100),
    type        VARCHAR2(20) DEFAULT 'holiday' NOT NULL
        CHECK (type IN ('holiday', 'medical', 'other')),
    status      VARCHAR2(20) DEFAULT 'pending' NOT NULL
        CHECK (status IN ('pending', 'approved', 'declined')),
    user_id     NUMBER                         NOT NULL
        CONSTRAINT day_offs_users_id_fk
            REFERENCES users
                ON DELETE CASCADE
)
/

CREATE INDEX day_offs_status_index
    ON day_offs (status)
/

CREATE OR REPLACE VIEW current_user AS
SELECT "id", "first_name", "last_name", "team_id"
FROM users
WHERE upper(first_name || '_' || last_name) = USER
/

CREATE OR REPLACE PROCEDURE add_to_team(user_id IN INT) IS
    team_id     INT;
    is_teamlead INT;
BEGIN
    BEGIN
        SELECT 1
        INTO is_teamlead
        FROM teams
        WHERE teamlead_id = user_id;
    EXCEPTION
        WHEN no_data_found THEN
            is_teamlead := 0;
    END;

    IF is_teamlead = 1 THEN
        raise_application_error(-20001, 'User is teamlead');
    END IF;

    BEGIN
        SELECT id
        INTO team_id
        FROM teams
        WHERE teamlead_id = (SELECT id FROM current_user);
    EXCEPTION
        WHEN no_data_found THEN
            team_id := NULL;
    END;

    IF team_id IS NULL THEN
        raise_application_error(-20002, 'current user not a teamlead');
    ELSE
        dbms_output.PUT_LINE(team_id);
        UPDATE users
        SET team_id = team_id
        WHERE id = user_id;
        COMMIT;
    END IF;
END;
/

CREATE OR REPLACE FUNCTION get_current_user RETURN users%ROWTYPE AS
    v_current_user users%ROWTYPE;
BEGIN
    SELECT * INTO v_current_user FROM current_user;

    RETURN v_current_user;
END;
/


