DROP TABLE Used_as;
DROP TABLE Specializes_in;
DROP TABLE Recieved_award;
DROP TABLE Awards;
DROP TABLE Projects;
DROP TABLE Owned_by;
DROP TABLE Mortgage;
DROP TABLE Financed_by;
DROP TABLE Built_by;
DROP TABLE Designed_by;
DROP TABLE Lenders;
DROP TABLE Contractors;
DROP TABLE Designers;
DROP TABLE Developers;
DROP TABLE Companies;
DROP TABLE Property_types;
DROP TABLE Buildings;

CREATE TABLE Buildings (
  building_id SERIAL primary key,
  name varchar(64),
  size_sqf_0000 numeric not null,
  property_class varchar(2),
  status varchar(20) not null,
  street_num integer not null,
  street_name varchar(64) not null,
  city varchar(32) not null,
  state char(2) not null,
  zip integer not null,
  UNIQUE (street_num, street_name, zip),
  CONSTRAINT status_contraint CHECK (status in ('completed', 'under construction', 'planned')),
  CONSTRAINT class_constraint CHECK (property_class in ('AA', 'A', 'B', 'C')),
  CONSTRAINT zip_constraint CHECK (zip >= 00501 AND zip <= 99950)
);

CREATE TABLE Property_types (
  name varchar(64) primary key,
  CONSTRAINT type_name_contraint CHECK (name in ('Office', 'Industrial', 'Retail', 'Residential', 'Hospitality'))
);

CREATE TABLE Companies (
  fed_id char(10) primary key,
  name varchar(64) not null,
  num_of_employees integer,
  revenue_$mm numeric,
  email varchar(64),
  phone_number char(12) UNIQUE
);

CREATE TABLE Developers (
  fed_id char(10) primary key,
  regional_focus varchar(12),
  CONSTRAINT regional_focus_constraint CHECK (regional_focus in ('National', 'New England', 'Mid-Atlantic', 'Midwest', 'S.Atlantic', 'S.Central', 'West')),
  FOREIGN KEY (fed_id) REFERENCES Companies(fed_id) ON DELETE CASCADE
);

CREATE TABLE Designers (
  fed_id char(10) primary key,
  projects_completed integer,
  type varchar(20) not null,
  CONSTRAINT designer_type_constraint CHECK (type in ('Architect', 'Architect-Engineer', 'Engineer')),
  FOREIGN KEY (fed_id) REFERENCES Companies (fed_id) ON DELETE CASCADE
);

CREATE TABLE Contractors (
  fed_id char(10) primary key,
  sqft_completed_5yrs numeric,
  sqft_under_construction numeric,
  FOREIGN KEY (fed_id) REFERENCES Companies(fed_id) ON DELETE CASCADE
);

CREATE TABLE Lenders (
  fed_id char(10) primary key,
  min_loan_size_$mm numeric,
  max_loan_size_$mm numeric,
  min_rate numeric,
  max_rate numeric,
  max_ltc numeric,
  FOREIGN KEY (fed_id) REFERENCES Companies (fed_id) ON DELETE CASCADE
);

CREATE TABLE Designed_by (
  b_id integer,
  fed_id char(10),
  PRIMARY KEY (b_id, fed_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id),
  FOREIGN KEY (fed_id) REFERENCES Designers (fed_id)
);

CREATE TABLE Built_by (
  b_id integer,
  fed_id char(10),
  PRIMARY KEY (b_id, fed_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id),
  FOREIGN KEY (fed_id) REFERENCES Contractors (fed_id)
);

CREATE TABLE Financed_by (
  b_id integer,
  fed_id char(10),
  PRIMARY KEY (b_id, fed_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id),
  FOREIGN KEY (fed_id) REFERENCES Lenders (fed_id)
);

CREATE TABLE Mortgage (
  b_id integer,
  mortgage_id integer,
  amount_$mm numeric,
  rate numeric,
  agreement_date date not null,
  PRIMARY KEY (b_id, mortgage_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id) ON DELETE CASCADE
);

CREATE TABLE Owned_by (
  b_id integer,
  fed_id char(10),
  since date,
  PRIMARY KEY (b_id, fed_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id),
  FOREIGN KEY (fed_id) REFERENCES Companies (fed_id)
);

CREATE TABLE Projects (
  b_id integer,
  designer_id char(10),
  contractor_id char(10),
  lender_id char(10),
  developer_id char(10),
  completion_date date not null,
  PRIMARY KEY (b_id, designer_id, lender_id, contractor_id, developer_id),
  FOREIGN KEY (b_id) REFERENCES Buildings (building_id) ON DELETE CASCADE,
  FOREIGN KEY (designer_id) REFERENCES Designers (fed_id) ON DELETE CASCADE,
  FOREIGN KEY (contractor_id) REFERENCES Contractors (fed_id) ON DELETE CASCADE,
  FOREIGN KEY (lender_id) REFERENCES Lenders (fed_id) ON DELETE CASCADE,
  FOREIGN KEY (developer_id) REFERENCES Developers (fed_id) ON DELETE CASCADE
);

CREATE TABLE Awards (
  name varchar(64),
  organization varchar(64),
  PRIMARY KEY (name, organization)
);

CREATE TABLE Recieved_award (
  b_id integer,
  designer_id char(10),
  contractor_id char(10),
  lender_id char(10),
  developer_id char(10),
  award_name varchar(64),
  award_org varchar(64),
  award_year integer,
  PRIMARY KEY (b_id, designer_id, lender_id, contractor_id, developer_id, award_name, award_org, award_year),
  FOREIGN KEY (b_id, designer_id, lender_id, contractor_id, developer_id) REFERENCES Projects (b_id, designer_id, lender_id, contractor_id, developer_id) ON DELETE CASCADE,
  FOREIGN KEY (award_name, award_org) REFERENCES Awards (name, organization) ON DELETE CASCADE
);

CREATE TABLE Specializes_in (
  fed_id char(10),
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

INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('37 Sixth', 1343.8, 'A', 'under construction', 37, '6th Avenue', 'Brooklyn', 'NY', 11217);
INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('11 Hoyt', 770.0, 'AA', 'completed', 11, 'Hoyt Street', 'Brooklyn', 'NY', 11201);
INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('The Villeage', 100.385, 'B', 'completed', 2700, 'International Boulevard', 'Oakland', 'CA', 94601);
INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('Two-Tower Riverwalk', 587.235, 'AA', 'under construction', 60, 'N. 23rd Street', 'Philadelphia', 'PA', 19103);
INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('Optima Lakeview', 1237.906, 'A', 'under construction', 3460, 'N. Broadway', 'Chicago', 'IL', 60657);
INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('Front & York', 1105.983, 'AA', 'under construction', 85, 'Jay Street', 'Brooklyn', 'NY', 11201);
INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('The Wheeler', 843.830, 'AA', 'completed', 181, 'Livingston Street', 'Brooklyn', 'NY', 11201);
INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('200 Park', 1012.203, 'AA', 'under construction', 200, 'Park Avenue', 'San Jose', 'CA', 95113);
INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('Brooklyn Point', 1200.0, 'AA', 'under construction', 138, 'Willoughby Street', 'Brooklyn', 'NY', 11201);
INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('Harborside 8', 975.0, 'AA', 'planned', 8, 'Harborside Pl', 'Jersey City', 'NJ', 07302);
INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('Kearny Point', 20000.0, 'C', 'completed', 78, 'John Miller Way', 'Kearny', 'NJ', 07032);
INSERT INTO Buildings (name, size_sqf_0000, property_class, status, street_num, street_name, city, state, zip)
        VALUES ('Google Campus', 1300.0, 'AA', 'completed', 550, 'Washington Street', 'New York', 'NY', 10014);

INSERT INTO Property_types (name) VALUES ('Office');
INSERT INTO Property_types (name) VALUES ('Industrial');
INSERT INTO Property_types (name) VALUES ('Retail');
INSERT INTO Property_types (name) VALUES ('Residential');
INSERT INTO Property_types (name) VALUES ('Hospitality');

-- lenders
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('56-8387759','RCN Capital', 1150, 575, 'info@rcn.com', '657-112-0652');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('91-3348665','Commonwealth Capital', 920, 1230, 'info@cwc.com', '842-714-2993');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('39-2676428','MoFin Lending', 575, 985, 'info@mofin.com', '206-318-9112');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('51-8737916','Alpha Funding Partners', 856, 1550, 'info@afp.com', '719-232-1711');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('96-2388549','Stormfield Capital, LLC', 1350, 1750, 'info@stormfield.com', '768-469-9318');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('65-7476552','Temple View Capital', 750, 895, 'info@temple.com', '554-900-4787');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('57-3995817','Stratton Equities', 1200, 1075, 'info@stratton.com', '469-170-5967');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('12-4599763','Conventus', 900, 1025, 'info@coventus.com', '655-586-6070');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('69-5243685','American Heritage Lending', 825, null, 'info@ahl.com', '798-698-6680');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('23-5835487','Avatar Financial Group', 1300, null, 'info@avatar.com', '764-152-2270');

-- Developers
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('49-9385983','Lowe', 750, null, 'info@lowe.com', '211-996-3512');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('87-2819796','AvalonBay', 360, 2190, 'info@avalonbay.com', '281-938-0763');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('54-4667274','Greystar Real Estate Partners', 175, null, 'info@grep.com', '235-102-8667');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('71-1617154','Hines', 800, 1920, 'info@hines.com', '546-297-4299');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('21-5229186','Trammel Crow Company', 150, 800, 'info@tcc.com', '442-154-2395');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('57-4264131','Related Group', 75, 600, 'info@related.com', '399-298-4162');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('23-1248563','The JBG Companies', 85, 250, 'info@jbg.com', '605-201-1834');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('41-9565933','Simon Property Group', 725, 700, 'info@spg.com', '694-669-1546');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('82-3386566','General Growth Properties', 1100, 325, 'info@ggp.com', '850-113-9113');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('92-5692377','ProLogis', 985, 1325, 'info@prologis.com', '574-307-3065');

--Designers
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('18-8198189','DLR Group', 1200, 262, 'info@dlr.com', '930-515-0841'); --AE
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('35-9785183','Gensler', 6000, 1200, 'info@gensler.com', '411-398-3086'); --A
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('46-9349727','Marvel Architects', null, null, 'info@marvel.com', '546-343-7567'); --A
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('55-6857644','Bechtel', 55000, null, 'info@bechtel.com', '954-213-1388'); --EC
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('55-2871999','EXP', null, null, 'info@exp.com', '550-418-0428'); --EA
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('17-9755178','HKS', 1400, null, 'info@hks.com', '497-510-8471'); --A
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('83-1495598','SOM', null, null, 'info@som.com', '335-312-1827'); --A
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('43-8325515','HDR', 10000, null, 'info@hdr.com', '397-713-0488'); --A
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('82-7658385','GEI Consultants', null, null, 'info@gei.com', '516-118-0970'); --E
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('79-4316115','LJA Engineering', null, null, 'info@lja.com', '907-247-1778'); --E

--Contractors
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('88-7379745','KBR Inc.', 28000, 5639, 'info@kbr.com', '365-404-2866'); --EC
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('61-3865212','JACOBS', 52000, 14980, 'info@jacobs.com', '471-439-2028'); --EAC
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('99-6367854','AECOM', 87000, 1320, 'info@aecom.com', '994-427-5620'); --EAC
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('41-3277417','Gilbane Building Company', 2773, null, 'info@gbc.com', '270-093-4128'); --C
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('49-4989516','Structure Tone', 3300, null, 'info@structone.com', '467-701-4072'); --C
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('43-8377145','Omnibuild', 2100, null, 'info@omni.com', '805-959-4438'); --C
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('71-3679383','Turner Construction', 10000, 11770, 'info@turner.com', '980-151-7245'); --C
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('86-9382144','Suffolk Construction', 2010, null, 'info@suffolk.com', '782-529-8266'); --C
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('81-9979386','Hunter Roberts Construction Group', 1872, null, 'info@HRCG.com', '934-111-2271'); --C
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('93-1759336','Flintlock Construction', null, null, 'info@flint.com', '477-514-7655'); --C

--Owners
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('53-1126448','Alexandria Real Estate Equities', 439, 1531, 'info@aree.com', '414-260-3876');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('67-7886486','Boston Properties Inc.', 760, 2960, 'info@bp.com', '822-468-8823');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('66-8922699','Corporate Office Properties Trust', 394, 641, 'info@copt.com', '963-655-7471');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('73-1133252','Equity Commonwealth', 253, 723, 'info@ec.com', '638-535-2691');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('71-9358856','NextPoint LLC', 35, null, 'info@nextpoint.com', '797-720-1571');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('52-7266218','MAA LLC', 12, null, 'info@maa.com', '946-691-3703');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('24-8996669','UMH Properties, Inc.', 172, 491, 'info@umh.com', '290-239-5786');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('11-2347411','Taubman Group', 78, 157, 'info@taubman.com', '895-609-3288');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('94-7421776','Getty Realty Corp.', 125, 265, 'info@getty.com', '433-662-4768');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('85-8149968','Realty Income Corp.', 105, 315, 'info@realtyincome.com', '595-498-0626');
INSERT INTO Companies (fed_id, name, num_of_employees, revenue_$mm, email, phone_number) VALUES ('58-8578517','Kite LLC', null, null, 'info@kite.com', '703-216-0162');

INSERT INTO Developers (fed_id, regional_focus) VALUES ('49-9385983','West');
INSERT INTO Developers (fed_id, regional_focus) VALUES ('87-2819796','National');
INSERT INTO Developers (fed_id, regional_focus) VALUES ('54-4667274','Mid-Atlantic');
INSERT INTO Developers (fed_id, regional_focus) VALUES ('71-1617154','S.Central');
INSERT INTO Developers (fed_id, regional_focus) VALUES ('21-5229186','Midwest');
INSERT INTO Developers (fed_id, regional_focus) VALUES ('57-4264131','Mid-Atlantic');
INSERT INTO Developers (fed_id, regional_focus) VALUES ('23-1248563','S.Atlantic');
INSERT INTO Developers (fed_id, regional_focus) VALUES ('41-9565933','Mid-Atlantic');
INSERT INTO Developers (fed_id, regional_focus) VALUES ('82-3386566','S.Central');
INSERT INTO Developers (fed_id, regional_focus) VALUES ('92-5692377','National');

INSERT INTO Designers (fed_id, projects_completed, type) VALUES ('18-8198189', 125, 'Architect-Engineer'); --AE
INSERT INTO Designers (fed_id, projects_completed, type) VALUES ('35-9785183', 136, 'Architect'); --A
INSERT INTO Designers (fed_id, projects_completed, type) VALUES ('46-9349727', 90, 'Architect'); --A
INSERT INTO Designers (fed_id, projects_completed, type) VALUES ('55-6857644', 172, 'Engineer'); --EC
INSERT INTO Designers (fed_id, projects_completed, type) VALUES ('55-2871999', 75, 'Architect-Engineer'); --EA
INSERT INTO Designers (fed_id, projects_completed, type) VALUES ('17-9755178', 157, 'Architect'); --A
INSERT INTO Designers (fed_id, projects_completed, type) VALUES ('83-1495598', 92, 'Architect'); --A
INSERT INTO Designers (fed_id, projects_completed, type) VALUES ('43-8325515', 37, 'Architect'); --A
INSERT INTO Designers (fed_id, projects_completed, type) VALUES ('82-7658385', 185, 'Engineer'); --E
INSERT INTO Designers (fed_id, projects_completed, type) VALUES ('79-4316115', 34, 'Engineer'); --E

INSERT INTO Contractors (fed_id, sqft_completed_5yrs, sqft_under_construction) VALUES ('88-7379745', 20, 1.2); --EC
INSERT INTO Contractors (fed_id, sqft_completed_5yrs, sqft_under_construction) VALUES ('61-3865212', 15.7, .8); --EAC
INSERT INTO Contractors (fed_id, sqft_completed_5yrs, sqft_under_construction) VALUES ('99-6367854', 12.7, 2.1); --EAC
INSERT INTO Contractors (fed_id, sqft_completed_5yrs, sqft_under_construction) VALUES ('41-3277417', 16.1, .35); --C
INSERT INTO Contractors (fed_id, sqft_completed_5yrs, sqft_under_construction) VALUES ('49-4989516', 15.3, .82); --C
INSERT INTO Contractors (fed_id, sqft_completed_5yrs, sqft_under_construction) VALUES ('43-8377145', 8.25, 1.1); --C
INSERT INTO Contractors (fed_id, sqft_completed_5yrs, sqft_under_construction) VALUES ('71-3679383', 9.17, .75); --C
INSERT INTO Contractors (fed_id, sqft_completed_5yrs, sqft_under_construction) VALUES ('86-9382144', 11.25, 1.5); --C
INSERT INTO Contractors (fed_id, sqft_completed_5yrs, sqft_under_construction) VALUES ('81-9979386', 17.65, .65); --C
INSERT INTO Contractors (fed_id, sqft_completed_5yrs, sqft_under_construction) VALUES ('93-1759336', 4.25, .46); --C

INSERT INTO Lenders (fed_id, min_loan_size_$mm, max_loan_size_$mm, min_rate, max_rate, max_ltc) VALUES ('56-8387759', 5.5, 30.0, 4.00, 9.00, 75.0);
INSERT INTO Lenders (fed_id, min_loan_size_$mm, max_loan_size_$mm, min_rate, max_rate, max_ltc) VALUES ('91-3348665', 10.0, 75.0, 5.00, 15.00, 80.0);
INSERT INTO Lenders (fed_id, min_loan_size_$mm, max_loan_size_$mm, min_rate, max_rate, max_ltc) VALUES ('39-2676428', 10.0, 85.0, 3.25, 9.00, 75.0);
INSERT INTO Lenders (fed_id, min_loan_size_$mm, max_loan_size_$mm, min_rate, max_rate, max_ltc) VALUES ('51-8737916', 10.0, 50.0, 4.99, 12.00, 90.0);
INSERT INTO Lenders (fed_id, min_loan_size_$mm, max_loan_size_$mm, min_rate, max_rate, max_ltc) VALUES ('96-2388549', 2.5, 50.0, 6.99, 10.99, 90.0);
INSERT INTO Lenders (fed_id, min_loan_size_$mm, max_loan_size_$mm, min_rate, max_rate, max_ltc) VALUES ('65-7476552', 7.5, 20.0, 3.50, 8.25, 90.0);
INSERT INTO Lenders (fed_id, min_loan_size_$mm, max_loan_size_$mm, min_rate, max_rate, max_ltc) VALUES ('57-3995817', 1.0, 50.0, 3.00, 12.00, 90.0);
INSERT INTO Lenders (fed_id, min_loan_size_$mm, max_loan_size_$mm, min_rate, max_rate, max_ltc) VALUES ('12-4599763', 5.0, 65.0, 3.99, 9.99, 70.0);
INSERT INTO Lenders (fed_id, min_loan_size_$mm, max_loan_size_$mm, min_rate, max_rate, max_ltc) VALUES ('69-5243685', 10.0, 50.0, 4.00, 12.00, 85.0);
INSERT INTO Lenders (fed_id, min_loan_size_$mm, max_loan_size_$mm, min_rate, max_rate, max_ltc) VALUES ('23-5835487', 25.0, 35.0, 3.75, 11.25, 70.0);

INSERT INTO Designed_by (b_id, fed_id) VALUES (1, '18-8198189');
INSERT INTO Designed_by (b_id, fed_id) VALUES (2, '35-9785183');
INSERT INTO Designed_by (b_id, fed_id) VALUES (2, '55-6857644');
INSERT INTO Designed_by (b_id, fed_id) VALUES (3, '46-9349727');
INSERT INTO Designed_by (b_id, fed_id) VALUES (3, '18-8198189');
INSERT INTO Designed_by (b_id, fed_id) VALUES (4, '55-2871999');
INSERT INTO Designed_by (b_id, fed_id) VALUES (5, '83-1495598');
INSERT INTO Designed_by (b_id, fed_id) VALUES (5, '79-4316115');
INSERT INTO Designed_by (b_id, fed_id) VALUES (5, '82-7658385');
INSERT INTO Designed_by (b_id, fed_id) VALUES (6, '18-8198189');
INSERT INTO Designed_by (b_id, fed_id) VALUES (7, '55-2871999');
INSERT INTO Designed_by (b_id, fed_id) VALUES (8, '17-9755178');
INSERT INTO Designed_by (b_id, fed_id) VALUES (8, '55-2871999');
INSERT INTO Designed_by (b_id, fed_id) VALUES (9, '55-2871999');
INSERT INTO Designed_by (b_id, fed_id) VALUES (10, '18-8198189');
INSERT INTO Designed_by (b_id, fed_id) VALUES (10, '82-7658385');
INSERT INTO Designed_by (b_id, fed_id) VALUES (11, '18-8198189');
INSERT INTO Designed_by (b_id, fed_id) VALUES (12, '35-9785183');
INSERT INTO Designed_by (b_id, fed_id) VALUES (12, '55-6857644');

INSERT INTO Built_by (b_id, fed_id) VALUES (1, '88-7379745');
INSERT INTO Built_by (b_id, fed_id) VALUES (2, '61-3865212');
INSERT INTO Built_by (b_id, fed_id) VALUES (3, '99-6367854');
INSERT INTO Built_by (b_id, fed_id) VALUES (4, '86-9382144');
INSERT INTO Built_by (b_id, fed_id) VALUES (5, '93-1759336');
INSERT INTO Built_by (b_id, fed_id) VALUES (6, '88-7379745');
INSERT INTO Built_by (b_id, fed_id) VALUES (7, '86-9382144');
INSERT INTO Built_by (b_id, fed_id) VALUES (8, '81-9979386');
INSERT INTO Built_by (b_id, fed_id) VALUES (9, '41-3277417');
INSERT INTO Built_by (b_id, fed_id) VALUES (10, '93-1759336');
INSERT INTO Built_by (b_id, fed_id) VALUES (11, '88-7379745');
INSERT INTO Built_by (b_id, fed_id) VALUES (12, '61-3865212');

INSERT INTO Financed_by (b_id, fed_id) VALUES (1, '56-8387759');
INSERT INTO Financed_by (b_id, fed_id) VALUES (1, '91-3348665');
INSERT INTO Financed_by (b_id, fed_id) VALUES (2, '39-2676428');
INSERT INTO Financed_by (b_id, fed_id) VALUES (3, '12-4599763');
INSERT INTO Financed_by (b_id, fed_id) VALUES (4, '12-4599763');
INSERT INTO Financed_by (b_id, fed_id) VALUES (4, '96-2388549');
INSERT INTO Financed_by (b_id, fed_id) VALUES (5, '51-8737916');
INSERT INTO Financed_by (b_id, fed_id) VALUES (6, '23-5835487');
INSERT INTO Financed_by (b_id, fed_id) VALUES (6, '65-7476552');
INSERT INTO Financed_by (b_id, fed_id) VALUES (7, '56-8387759');
INSERT INTO Financed_by (b_id, fed_id) VALUES (8, '12-4599763');
INSERT INTO Financed_by (b_id, fed_id) VALUES (9, '96-2388549');
INSERT INTO Financed_by (b_id, fed_id) VALUES (9, '12-4599763');
INSERT INTO Financed_by (b_id, fed_id) VALUES (10, '91-3348665');
INSERT INTO Financed_by (b_id, fed_id) VALUES (11, '56-8387759');
INSERT INTO Financed_by (b_id, fed_id) VALUES (11, '91-3348665');
INSERT INTO Financed_by (b_id, fed_id) VALUES (12, '39-2676428');

INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (1, 148, 30.0, 5.25, '2018-10-15');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (1, 838, 25.0, 5.00, '2018-10-15');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (2, 659, 75.0, 6.00, '2012-08-12');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (3, 352, 55.25, 4.25, '2013-05-15');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (4, 182, 55.0, 4.25, '2017-04-20');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (4, 153, 50.0, 4.25, '2017-04-20');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (5, 859, 45.0, 5.25, '2016-02-14');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (6, 595, 35.0, 5.25, '2013-03-24');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (6, 161, 20.0, 4.00, '2013-03-24');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (7, 222, 30.0, 6.75, '2012-06-12');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (8, 858, 53.0, 6.75, '2015-07-26');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (9, 496, 45.5, 7.25, '2018-11-20');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (9, 893, 60.5, 8.15, '2018-11-20');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (10, 388, 75.75, 5.75, '2020-08-20');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (11, 148, 30.0, 4.25, '2010-10-15');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (11, 838, 25.0, 5.00, '2010-10-15');
INSERT INTO Mortgage (b_id, mortgage_id, amount_$mm, rate, agreement_date) VALUES (12, 659, 75.0, 6.00, '2011-09-06');

INSERT INTO Owned_by (b_id, fed_id, since) VALUES (1, '87-2819796', '2014-07-30');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (2, '24-8996669', '2018-01-23');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (3, '67-7886486', '2013-05-28');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (4, '52-7266218', '2015-08-18');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (4, '71-9358856', '2016-03-08');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (5, '11-2347411', '2014-04-23');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (6, '66-8922699', '2012-10-07');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (7, '58-8578517', '2012-01-05');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (8, '73-1133252', '2014-11-11');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (9, '94-7421776', '2017-09-14');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (10, '85-8149968', '2019-08-24');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (11, '92-5692377', '2013-08-30');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (12, '53-1126448', '2019-12-10');
INSERT INTO Owned_by (b_id, fed_id, since) VALUES (12, '66-8922699', '2017-11-27');

INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (1,'18-8198189','88-7379745','56-8387759','87-2819796', '2020-12-31');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (1,'18-8198189','88-7379745','91-3348665','87-2819796', '2020-12-31');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (2,'35-9785183','61-3865212','39-2676428','57-4264131', '2015-11-11');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (2,'55-6857644','61-3865212','39-2676428','57-4264131', '2015-11-11');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (3,'46-9349727','99-6367854','12-4599763','49-9385983', '2016-03-24');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (3,'18-8198189','99-6367854','12-4599763','49-9385983', '2016-03-24');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (4,'55-2871999','86-9382144','12-4599763','41-9565933', '2021-02-15');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (4,'55-2871999','86-9382144','96-2388549','41-9565933', '2021-02-15');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (5,'83-1495598','93-1759336','51-8737916','21-5229186', '2021-06-30');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (5,'79-4316115','93-1759336','51-8737916','21-5229186', '2021-06-30');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (5,'82-7658385','93-1759336','51-8737916','21-5229186', '2021-06-30');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (6,'18-8198189','88-7379745','23-5835487','87-2819796', '2020-12-15');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (6,'18-8198189','88-7379745','65-7476552','87-2819796', '2020-12-15');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (7,'55-2871999','86-9382144','56-8387759','54-4667274', '2018-07-12');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (8,'17-9755178','81-9979386','12-4599763','92-5692377', '2021-04-18');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (8,'55-2871999','81-9979386','12-4599763','71-1617154', '2021-04-18');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (9,'55-2871999','41-3277417','96-2388549','23-1248563', '2022-07-30');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (9,'55-2871999','41-3277417','12-4599763','23-1248563', '2022-07-30');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (10,'18-8198189','93-1759336','91-3348665','41-9565933', '2025-12-25');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (10,'82-7658385','93-1759336','91-3348665','41-9565933', '2025-12-25');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (11,'18-8198189','88-7379745','56-8387759','92-5692377', '2013-08-30');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (11,'18-8198189','88-7379745','91-3348665','92-5692377', '2013-08-30');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (12,'35-9785183','61-3865212','39-2676428','54-4667274', '2014-10-25');
INSERT INTO Projects (b_id, designer_id, contractor_id, lender_id, developer_id, completion_date) VALUES (12,'55-6857644','61-3865212','39-2676428','54-4667274', '2014-10-25');

INSERT INTO Awards (name, organization) VALUES ('Project of the Year', 'NAIOP');
INSERT INTO Awards (name, organization) VALUES ('Community Impact Award', 'ULI');
INSERT INTO Awards (name, organization) VALUES ('Best residential Project', 'ICSC');
INSERT INTO Awards (name, organization) VALUES ('Best Office Project', 'ICSC');
INSERT INTO Awards (name, organization) VALUES ('Best Mixed-use Project', 'ICSC');
INSERT INTO Awards (name, organization) VALUES ('Best Industrial Project', 'ICSC');
INSERT INTO Awards (name, organization) VALUES ('Most Innovative Design', 'ULI');
INSERT INTO Awards (name, organization) VALUES ('Excellence in Construction and Engineering', 'Colliers');
INSERT INTO Awards (name, organization) VALUES ('Excellence in Architecture and Desgin', 'Colliers');
INSERT INTO Awards (name, organization) VALUES ('LEED Platinum', 'U.S Green Building Council');

INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (2,'35-9785183','61-3865212','39-2676428','57-4264131','Best residential Project','ICSC',2016);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (2,'55-6857644','61-3865212','39-2676428','57-4264131','Best residential Project','ICSC',2016);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (2,'35-9785183','61-3865212','39-2676428','57-4264131','Excellence in Architecture and Desgin','Colliers',2016);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (2,'55-6857644','61-3865212','39-2676428','57-4264131','Excellence in Architecture and Desgin','Colliers',2016);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (3,'46-9349727','99-6367854','12-4599763','49-9385983','Community Impact Award','ULI',2017);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (3,'18-8198189','99-6367854','12-4599763','49-9385983','Community Impact Award','ULI',2017);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (7,'55-2871999','86-9382144','56-8387759','54-4667274','Best Mixed-use Project','ICSC',2019);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (7,'55-2871999','86-9382144','56-8387759','54-4667274','Project of the Year','NAIOP',2019);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (7,'55-2871999','86-9382144','56-8387759','54-4667274','Most Innovative Design','ULI',2019);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (11,'18-8198189','88-7379745','56-8387759','92-5692377','Best Industrial Project','ICSC',2014);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (11,'18-8198189','88-7379745','91-3348665','92-5692377','Best Industrial Project','ICSC',2014);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (12,'35-9785183','61-3865212','39-2676428','54-4667274','Best Office Project','ICSC',2015);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (12,'55-6857644','61-3865212','39-2676428','54-4667274','Best Office Project','ICSC',2015);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (12,'35-9785183','61-3865212','39-2676428','54-4667274','Excellence in Construction and Engineering','Colliers',2015);
INSERT INTO Recieved_award (b_id, designer_id, contractor_id, lender_id, developer_id, award_name, award_org, award_year) VALUES (12,'55-6857644','61-3865212','39-2676428','54-4667274','Excellence in Construction and Engineering','Colliers',2015);

INSERT INTO Specializes_in (fed_id, type_name) VALUES ('49-9385983', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('49-9385983', 'Hospitality');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('87-2819796', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('87-2819796', 'Office');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('87-2819796', 'Retail');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('87-2819796', 'Hospitality');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('54-4667274', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('54-4667274', 'Hospitality');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('54-4667274', 'Office');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('54-4667274', 'Retail');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('71-1617154', 'Office');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('57-4264131', 'Office');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('57-4264131', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('23-1248563', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('23-1248563', 'Retail');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('41-9565933', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('41-9565933', 'Hospitality');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('41-9565933', 'Office');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('82-3386566', 'Office');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('92-5692377', 'Industrial');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('18-8198189', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('35-9785183', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('35-9785183', 'Office');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('46-9349727', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('55-2871999', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('55-2871999', 'Retail');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('55-2871999', 'Office');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('17-9755178', 'Office');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('83-1495598', 'Office');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('83-1495598', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('83-1495598', 'Retail');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('43-8325515', 'Residential');
INSERT INTO Specializes_in (fed_id, type_name) VALUES ('43-8325515', 'Hospitality');


INSERT INTO Used_as (b_id, type_name) VALUES (1, 'Residential');
INSERT INTO Used_as (b_id, type_name) VALUES (1, 'Retail');
INSERT INTO Used_as (b_id, type_name) VALUES (1, 'Hospitality');
INSERT INTO Used_as (b_id, type_name) VALUES (2, 'Residential');
INSERT INTO Used_as (b_id, type_name) VALUES (3, 'Residential');
INSERT INTO Used_as (b_id, type_name) VALUES (4, 'Retail');
INSERT INTO Used_as (b_id, type_name) VALUES (5, 'Office');
INSERT INTO Used_as (b_id, type_name) VALUES (5, 'Retail');
INSERT INTO Used_as (b_id, type_name) VALUES (6, 'Office');
INSERT INTO Used_as (b_id, type_name) VALUES (7, 'Residential');
INSERT INTO Used_as (b_id, type_name) VALUES (7, 'Office');
INSERT INTO Used_as (b_id, type_name) VALUES (7, 'Retail');
INSERT INTO Used_as (b_id, type_name) VALUES (8, 'Office');
INSERT INTO Used_as (b_id, type_name) VALUES (9, 'Retail');
INSERT INTO Used_as (b_id, type_name) VALUES (10, 'Hospitality');
INSERT INTO Used_as (b_id, type_name) VALUES (11, 'Industrial');
INSERT INTO Used_as (b_id, type_name) VALUES (12, 'Office');
