-- CREATE REQUIRED TABLES
DROP TABLE IF EXISTS `test.dim_user`;
DROP TABLE IF EXISTS `test.stg_user`;

CREATE TABLE `test.dim_user`
(
    user_sk      STRING DEFAULT GENERATE_UUID() PRIMARY KEY NOT ENFORCED,
    user_bk      STRING,
    name         STRING, -- SCD1 attribute
    country      STRING, -- SCD2 attribute
    city         STRING, -- SCD2 attribute
    _valid_from  TIMESTAMP,
    _valid_to    TIMESTAMP
);

CREATE TABLE `test.stg_user`
(
    user_bk      STRING PRIMARY KEY NOT ENFORCED,
    name         STRING,
    country      STRING,
    city         STRING
);


-- INSERT INITIAL VALUES
INSERT INTO `test.dim_user`(user_bk, name, country, city, _valid_from, _valid_to)
VALUES
    ('788d58fb', 'Myles', 'Canada', 'Torronto', '1000-01-01', '9999-12-31 23:59:59'),
    ('23bef18a', 'Neo', 'Ukraine', 'Ternopil', '1000-01-01', '9999-12-31 23:59:59'),
    ('6a94d22b', 'Kim', 'Poland', 'Warsaw', '1000-01-01', '9999-12-31 23:59:59'),
    ('8e7e4f9a', 'Ovan', 'France', 'Paris', '1000-01-01', '2023-05-05 23:59:59'),
    ('8e7e4f9a', 'Ovan', 'France', 'Leon', '2023-05-06', '9999-12-31 23:59:59');

-- INSERT NEW PORTION OF DATA
INSERT INTO `test.stg_user`(user_bk, name, country, city)
VALUES
('5da53bcd', 'Vasyl', 'USA', 'Los-Angeles'),
('8e7e4f9a', 'Ovaness', 'France', 'Nice'),
('23bef18a', 'Leopold', 'Ukraine', 'Ternopil'),
('6a94d22b', 'Kim', 'Poland', 'Warsaw'),
('788d58fb', 'Melisa', 'USA', 'New York');


-- TASK: Prepare SQL statements to correctly add new portion of data into the dim_user table
-- Explanations: We expect dim_user to have a valid historical records according to the specified in the table declaration attribute's SCD types





update `test.dim_user` d
set name = s.name
from `test.stg_user` s
where d.user_bk = s.user_bk
  and d._valid_to = timestamp '9999-12-31 23:59:59'
  and d.name != s.name;

update `test.dim_user` d
set _valid_to = current_timestamp()
from `test.stg_user` s
where d.user_bk = s.user_bk
  and d._valid_to = timestamp '9999-12-31 23:59:59'
  and (d.country != s.country or d.city != s.city);

insert into `test.dim_user`(user_bk, name, country, city, _valid_from, _valid_to)
select s.user_bk, s.name, s.country, s.city, current_timestamp(), timestamp '9999-12-31 23:59:59'
from `test.stg_user` s
join `test.dim_user` d on s.user_bk = d.user_bk
where d._valid_to = current_timestamp()
  and (d.country != s.country or d.city != s.city);

insert into `test.dim_user`(user_bk, name, country, city, _valid_from, _valid_to)
select s.user_bk, s.name, s.country, s.city, current_timestamp(), timestamp '9999-12-31 23:59:59'
from `test.stg_user` s
where not exists (
    select 1 from `test.dim_user` d where d.user_bk = s.user_bk
);
