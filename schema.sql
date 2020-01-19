CREATE TABLE users
(
    id         INT GENERATED AS IDENTITY
        CONSTRAINT user_pk
            PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name  VARCHAR2(50) NOT NULL,
    team_id    INT
)
/
CREATE TABLE user_details
(
    id           INT
        CONSTRAINT user_details_pk
            PRIMARY KEY,
    holiday_days INT DEFAULT 21 NOT NULL,
    bonus_days   INT DEFAULT 0  NOT NULL,
    user_id      INT
        CONSTRAINT user_details_users_id_fk
            REFERENCES users
                ON DELETE CASCADE
)
/

CREATE UNIQUE INDEX user_details_user_id_uindex
    ON user_details (user_id)
/


CREATE TABLE teams
(
    id          INT GENERATED AS IDENTITY
        CONSTRAINT team_pk
            PRIMARY KEY,
    name        VARCHAR2(50) NOT NULL,
    teamlead_id INT
        CONSTRAINT team_user_id_fk
            REFERENCES users (id)
)
/
CREATE UNIQUE INDEX teams_teamlead_id_uindex
    ON teams (teamlead_id)
/


CREATE TABLE day_offs
(
    id          INT
        CONSTRAINT day_offs_pk
            PRIMARY KEY,
    date_in     DATE                           NOT NULL,
    date_out    DATE                           NOT NULL,
    description VARCHAR2(100),
    type        VARCHAR2(20) DEFAULT 'holiday' NOT NULL
        CHECK (type IN ('holiday', 'medical', 'other')),
    status      VARCHAR2(20) DEFAULT 'pending' NOT NULL
        CHECK (status IN ('pending', 'approved', 'declined')),
    user_id     INT                            NOT NULL
        CONSTRAINT day_offs_users_id_fk
            REFERENCES users (id)
                ON DELETE CASCADE
)
/
CREATE INDEX day_offs_status_index
    ON day_offs (status)
/
CREATE INDEX day_offs_type_index
    ON day_offs (type)
/
CREATE INDEX day_offs_user_id_index
    ON day_offs (user_id)
/


CREATE TABLE projects
(
    id                 INT GENERATED AS IDENTITY
        CONSTRAINT projects_pk
            PRIMARY KEY,
    name               VARCHAR2(50) NOT NULL,
    project_manager_id INT          NOT NULL
        CONSTRAINT projects_users_id_fk
            REFERENCES users
)
/

CREATE TABLE project_users
(
    project_id INT
        CONSTRAINT project_users_projects__fk
            REFERENCES projects
                ON DELETE CASCADE,
    user_id    INT
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
    id         INT
        CONSTRAINT activities_pk
            PRIMARY KEY,
    date_in    DATE NOT NULL,
    date_out   DATE,
    project_id INT  NOT NULL,
    user_id    INT  NOT NULL,
    CONSTRAINT activities_project_users_project_id_user_id_fk
        FOREIGN KEY (project_id, user_id) REFERENCES project_users
            ON DELETE CASCADE
)
/
CREATE INDEX activities_user_id_project_id_index
    ON activities (user_id, project_id)
/
