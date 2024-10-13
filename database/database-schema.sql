-- Enable PostGIS Extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create projects table
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    project_code VARCHAR(3) UNIQUE NOT NULL,
    project_name VARCHAR NOT NULL,
    project_description VARCHAR,
    project_location GEOGRAPHY(POINT), -- Using PostGIS geography type for lat/long
    beneficiaries_ages VARCHAR,
    budget FLOAT,
    actual_money_spent FLOAT
);

-- Index for fast searching by project_code
CREATE INDEX idx_project_code ON projects (project_code);

-- Index for fast searching by project_location using PostGIS
CREATE INDEX idx_project_location ON projects USING GIST (project_location);

-- Create checklist_area table
CREATE TABLE checklist_area (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    description VARCHAR
);

-- Create teams table
CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    code VARCHAR(6) UNIQUE NOT NULL,
    name VARCHAR NOT NULL,
    description VARCHAR
);

-- Index for fast searching by team name
CREATE INDEX idx_team_name ON teams (name);

-- Create roles table
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    team_id INT REFERENCES teams(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    description VARCHAR
);

-- Index for fast searching by role name
CREATE INDEX idx_role_name ON roles (name);

-- Index foreign key team_id for fast JOIN operations
CREATE INDEX idx_roles_team_id ON roles (team_id);

-- Create camp_people table
CREATE TABLE camp_people (
    id SERIAL PRIMARY KEY,
    role_id INT REFERENCES roles(id) ON DELETE CASCADE,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    surname VARCHAR NOT NULL,
    international_phone_number VARCHAR,
    kh_phone_number VARCHAR,
    email VARCHAR,
    gender VARCHAR(1) CHECK (gender IN ('M', 'F')),
    age INT,
    nationality VARCHAR,
    passport VARCHAR,
    photo_path VARCHAR
);

-- Index for fast searching by name and surname
CREATE INDEX idx_camp_people_name ON camp_people (name, surname);

-- Index for fast searching by email
CREATE INDEX idx_camp_people_email ON camp_people (email);

-- Index foreign key role_id and project_id for fast JOIN operations
CREATE INDEX idx_camp_people_role_id ON camp_people (role_id);
CREATE INDEX idx_camp_people_project_id ON camp_people (project_id);

-- Create camp_people_extra_data table
CREATE TABLE camp_people_extra_data (
    id SERIAL PRIMARY KEY,
    camp_people_id INT REFERENCES camp_people(id) ON DELETE CASCADE,
    arrival_flight_number VARCHAR,
    arrival_date_time TIMESTAMPTZ,
    departure_flight_number VARCHAR,
    departure_date_time TIMESTAMPTZ,
    flight_tickets BOOLEAN,
    travel_insurance BOOLEAN,
    vaccination_card BOOLEAN,
    passport_fotocopy VARCHAR,
    cambodia_evisa BOOLEAN,
    passport_photo VARCHAR,
    certificate_sexual_offences BOOLEAN,
    proof_of_payment BOOLEAN,
    programme_rules BOOLEAN,
    volunteer_contract BOOLEAN
);

-- Create checklist_tasks table
CREATE TABLE checklist_tasks (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    short_description VARCHAR,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    team_id INT REFERENCES teams(id) ON DELETE CASCADE,
    area_id INT REFERENCES checklist_area(id) ON DELETE CASCADE,
    priority INT,
    done BOOLEAN DEFAULT FALSE,
    due_date TIMESTAMPTZ
);

-- Index for fast searching by task name
CREATE INDEX idx_checklist_tasks_name ON checklist_tasks (name);

-- Index foreign key project_id, team_id, area_id for fast JOIN operations
CREATE INDEX idx_checklist_tasks_project_id ON checklist_tasks (project_id);
CREATE INDEX idx_checklist_tasks_team_id ON checklist_tasks (team_id);
CREATE INDEX idx_checklist_tasks_area_id ON checklist_tasks (area_id);

-- Index for fast searching by due date
CREATE INDEX idx_checklist_tasks_due_date ON checklist_tasks (due_date);

-- Create pse_material_used table
CREATE TABLE pse_material_used (
    id SERIAL PRIMARY KEY,
    code VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    pse_responsable_id INT REFERENCES camp_people(id),
    camp_responsable_id INT REFERENCES camp_people(id),
    current_holder_id INT REFERENCES camp_people(id),
    image_path VARCHAR
);

-- Create children table
CREATE TABLE children (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    surname VARCHAR NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(1) CHECK (gender IN ('M', 'F')),
    project_id INT REFERENCES projects(id) ON DELETE CASCADE
);

-- Index foreign key project_id for fast JOIN operations
CREATE INDEX idx_children_project_id ON children (project_id);

-- Create vehicules_type table
CREATE TABLE vehicules_type (
    id SERIAL PRIMARY KEY,
    type VARCHAR NOT NULL
);

-- Index for fast searching by vehicle type
CREATE INDEX idx_vehicules_type ON vehicules_type (type);

-- Create available_vehicules table
CREATE TABLE available_vehicules (
    id SERIAL PRIMARY KEY,
    code VARCHAR UNIQUE NOT NULL,
    type_id INT REFERENCES vehicules_type(id) ON DELETE CASCADE,
    available_seats INT NOT NULL,
    image_path VARCHAR
);

-- Index for fast searching by vehicle code
CREATE INDEX idx_vehicule_code ON available_vehicules (code);

-- Index foreign key type_id for fast JOIN operations
CREATE INDEX idx_available_vehicules_type_id ON available_vehicules (type_id);

-- Create transport_locations table
CREATE TABLE transport_locations (
    id SERIAL PRIMARY KEY,
    code VARCHAR UNIQUE NOT NULL,
    name VARCHAR NOT NULL,
    location GEOGRAPHY(POINT), -- Using PostGIS geography type for lat/long
    description VARCHAR
);

-- Index for fast searching by location code
CREATE INDEX idx_transport_location_code ON transport_locations (code);

-- Index for fast searching by location name
CREATE INDEX idx_transport_location_name ON transport_locations (name);

-- Index for spatial queries using PostGIS
CREATE INDEX idx_transport_location_geog ON transport_locations USING GIST (location);

-- Create transportations table
CREATE TABLE transportations (
    id SERIAL PRIMARY KEY,
    vehicule_id INT REFERENCES available_vehicules(id) ON DELETE CASCADE,
    pax INT NOT NULL,
    origin_id INT REFERENCES transport_locations(id) ON DELETE CASCADE,
    destination_id INT REFERENCES transport_locations(id) ON DELETE CASCADE,
    departure_date_time TIMESTAMPTZ NOT NULL,
    scheduled_arrival_date_time TIMESTAMPTZ NOT NULL
);

-- Index foreign key vehicule_id, origin_id, destination_id for fast JOIN operations
CREATE INDEX idx_transportations_vehicule_id ON transportations (vehicule_id);
CREATE INDEX idx_transportations_origin_id ON transportations (origin_id);
CREATE INDEX idx_transportations_destination_id ON transportations (destination_id);

-- Index for fast searching by departure and arrival dates
CREATE INDEX idx_transport_departure_date ON transportations (departure_date_time);
CREATE INDEX idx_transport_arrival_date ON transportations (scheduled_arrival_date_time);

-- Create markets table
CREATE TABLE markets (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    opening_hours VARCHAR,
    phone VARCHAR,
    website VARCHAR,
    address VARCHAR,
    location GEOGRAPHY(POINT), -- Using PostGIS geography type for lat/long
    google_maps_link VARCHAR,
    comments VARCHAR
);

-- Index for fast searching by market name
CREATE INDEX idx_market_name ON markets (name);

-- Index for spatial queries using PostGIS
CREATE INDEX idx_market_location_geog ON markets USING GIST (location);

-- Create pse_odoo_products table
CREATE TABLE pse_odoo_products (
    id SERIAL PRIMARY KEY,
    code VARCHAR UNIQUE NOT NULL,
    product_name VARCHAR NOT NULL,
    description VARCHAR
);

-- Index for fast searching by product code
CREATE INDEX idx_odoo_product_code ON pse_odoo_products (code);

-- Create camp_product_types table
CREATE TABLE camp_product_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    description VARCHAR
);

-- Create product_storage_types table
CREATE TABLE product_storage_types (
    id SERIAL PRIMARY KEY,
    type VARCHAR NOT NULL
);

-- Create unit_format table
CREATE TABLE unit_format (
    id SERIAL PRIMARY KEY,
    format VARCHAR NOT NULL
);

-- Create camp_products table
CREATE TABLE camp_products (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR NOT NULL,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    odoo_product_id INT REFERENCES pse_odoo_products(id),
    quantity INT,
    unit_format INT REFERENCES unit_format(id),
    storage_type INT REFERENCES product_storage_types(id),
    storage_id INT,
    comments VARCHAR
);

-- Index foreign key project_id, odoo_product_id for fast JOIN operations
CREATE INDEX idx_camp_products_project_id ON camp_products (project_id);
CREATE INDEX idx_camp_products_odoo_product_id ON camp_products (odoo_product_id);

-- Create purchase_group table
CREATE TABLE purchase_group (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL
);

-- Create purchase_drop_off_locations table
CREATE TABLE purchase_drop_off_locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    location VARCHAR NOT NULL
);

-- Create purchases table
CREATE TABLE purchases (
    id SERIAL PRIMARY KEY,
    camp_product_id INT REFERENCES camp_products(id) ON DELETE CASCADE,
    quantity_requested INT NOT NULL,
    unit_format INT REFERENCES unit_format(id),
    quantity_received INT,
    drop_off_date_time_requested TIMESTAMPTZ,
    actual_drop_off_date_time TIMESTAMPTZ,
    drop_off_location_id INT REFERENCES purchase_drop_off_locations(id)
);

-- Index foreign key camp_product_id, drop_off_location_id for fast JOIN operations
CREATE INDEX idx_purchases_camp_product_id ON purchases (camp_product_id);
CREATE INDEX idx_purchases_drop_off_location_id ON purchases (drop_off_location_id);

-- Index for fast searching by drop-off date and time
CREATE INDEX idx_purchases_drop_off_dates ON purchases (drop_off_date_time_requested, actual_drop_off_date_time);

-- Create request_types table
CREATE TABLE request_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL
);

-- Create requests table
CREATE TABLE requests (
    id SERIAL PRIMARY KEY,
    priority INT,
    requested_by INT REFERENCES camp_people(id),
    date_time_requested TIMESTAMPTZ NOT NULL,
    status VARCHAR,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    request_type INT REFERENCES request_types(id)
);

-- Index foreign key requested_by, project_id, request_type for fast JOIN operations
CREATE INDEX idx_requests_requested_by ON requests (requested_by);
CREATE INDEX idx_requests_project_id ON requests (project_id);
CREATE INDEX idx_requests_request_type ON requests (request_type);

-- Index for fast searching by date_time_requested
CREATE INDEX idx_requests_date_time_requested ON requests (date_time_requested);