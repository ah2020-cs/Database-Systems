DROP TABLE Used_as;
DROP TABLE Specializes_in;
DROP TABLE Recieved_award;
DROP TABLE Awards;
DROP TABLE Projects;
DROP TABLE Owned_by;
DROP TABLE Mortgage;
DROP TABLE Financed_by cascade;
DROP TABLE Built_by;
DROP TABLE Designed_by cascade;
DROP TABLE Lenders;
DROP TABLE Contractors cascade;
DROP TABLE Designers cascade;
DROP TABLE Developers;
DROP TABLE Companies;
DROP TABLE Property_types cascade;
DROP TABLE Buildings cascade;


CREATE TABLE Buildings (
  building_id SERIAL primary key,
  name varchar(64),
  size numeric,
  property_class varchar(2),
  noi numeric,
  status varchar(20),
  street_num integer not null,
  street_name varchar(64) not null,
  city varchar(32) not null,
  state varchar(32) not null,
  zip integer not null,
  UNIQUE (street_num, street_name, zip),
  CONSTRAINT status_constraint CHECK (status in ('completed', 'under_construction', 'planned')),
  CONSTRAINT class_constraint CHECK (property_class in ('AA', 'A', 'B', 'C')),
  CONSTRAINT zip_constraint CHECK (zip >= 00501 AND zip <= 99950)
);

CREATE TABLE Property_types (
  name varchar(64) primary key,
  CONSTRAINT type_name_constraint CHECK (name in ('Office', 'Industrial', 'Retail', 'Multi-family', 'Mixed-use'))
);

CREATE TABLE Companies (
  fed_id integer primary key,
  num_of_employees integer,
  name varchar(64) not null,
  revenue integer
);

CREATE TABLE Developers (
  fed_id integer primary key,
  regional_focus varchar(12),
  CONSTRAINT regional_focus_constraint CHECK (regional_focus in ('New England', 'Mid-Atlantic', 'Midwest', 'S.Atlantic', 'S.Central', 'West')),
  FOREIGN KEY (fed_id) REFERENCES Companies(fed_id)
);

CREATE TABLE Designers (
  fed_id integer primary key,
  projects_completed integer,
  type varchar(20)
  CONSTRAINT designer_type_constraint CHECK (type in ('Architect', 'Architect-Engineer', 'Electrical-Engineer', 'Structural-Engineer')),
  FOREIGN KEY (fed_id) REFERENCES Companies (fed_id)
);

CREATE TABLE Contractors (
  fed_id integer primary key,
  sqft_completed_last_five_year numeric,
  sqft_under_construction numeric,
  FOREIGN KEY (fed_id) REFERENCES Companies(fed_id)
);

CREATE TABLE Lenders (
  fed_id integer primary key,
  min_loan_size integer,
  max_loan_size integer,
  interest_rate numeric,
  max_ltv numeric,
  max_ltc numeric,
  FOREIGN KEY (fed_id) REFERENCES Companies (fed_id)
);

CREATE TABLE Designed_by (
  b_id integer,
  fed_id integer,
  PRIMARY KEY (b_id, fed_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id),
  FOREIGN KEY (fed_id) REFERENCES Designers (fed_id)
);

CREATE TABLE Built_by (
  b_id integer,
  fed_id integer,
  PRIMARY KEY (b_id, fed_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id),
  FOREIGN KEY (fed_id) REFERENCES Contractors (fed_id)
);

CREATE TABLE Financed_by (
  b_id integer,
  fed_id integer,
  PRIMARY KEY (b_id, fed_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id),
  FOREIGN KEY (fed_id) REFERENCES Lenders (fed_id)
);

CREATE TABLE Mortgage (
  b_id integer,
  mortgage_id integer,
  amount numeric,
  rate numeric,
  agreement_date date,
  PRIMARY KEY (b_id, mortgage_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id) ON DELETE CASCADE
);

CREATE TABLE Owned_by (
  b_id integer,
  fed_id integer,
  since date,
  PRIMARY KEY (b_id, fed_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id),
  FOREIGN KEY (fed_id) REFERENCES Companies (fed_id)
);

CREATE TABLE Projects (
  b_id integer,
  designer_id integer,
  contractor_id integer,
  lender_id integer,
  developer_id integer,
  completion_date date,
  PRIMARY KEY (b_id, designer_id, lender_id, contractor_id, developer_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id),
  FOREIGN KEY (designer_id) REFERENCES Designers (fed_id),
  FOREIGN KEY (contractor_id) REFERENCES Contractors (fed_id),
  FOREIGN KEY (lender_id) REFERENCES Lenders (fed_id),
  FOREIGN KEY (developer_id) REFERENCES Developers (fed_id)
);

CREATE TABLE Awards (
  name varchar(64),
  organization varchar(64),
  PRIMARY KEY (name, organization)
);

CREATE TABLE Recieved_award (
  b_id integer,
  designer_id integer,
  contractor_id integer,
  lender_id integer,
  developer_id integer,
  award_name varchar(64),
  award_org varchar(64),
  award_year integer,
  PRIMARY KEY (b_id, designer_id, lender_id, contractor_id, developer_id, award_name, award_org, award_year),
  FOREIGN KEY (b_id, designer_id, lender_id, contractor_id, developer_id) REFERENCES Projects (b_id, designer_id, lender_id, contractor_id, developer_id),
  FOREIGN KEY (award_name, award_org) REFERENCES Awards (name, organization)
);

CREATE TABLE Specializes_in (
  fed_id integer,
  type_name varchar(64),
  PRIMARY KEY (fed_id, type_name),
  FOREIGN KEY (fed_id) REFERENCES Companies (fed_id),
  FOREIGN KEY (type_name) REFERENCES Property_types (name)
);

CREATE TABLE Used_as (
  b_id integer,
  type_name varchar(64),
  PRIMARY KEY (b_id, type_name),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id),
  FOREIGN KEY (type_name) REFERENCES Property_types (name)
);
