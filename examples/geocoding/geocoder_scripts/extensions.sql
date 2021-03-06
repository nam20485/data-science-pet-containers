CREATE EXTENSION postgis_tiger_geocoder CASCADE;
GRANT USAGE ON SCHEMA tiger TO PUBLIC;
GRANT USAGE ON SCHEMA tiger_data TO PUBLIC;
GRANT SELECT, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA tiger TO PUBLIC;
GRANT SELECT, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA tiger_data TO PUBLIC;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA tiger TO PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA tiger_data GRANT SELECT, REFERENCES ON TABLES TO PUBLIC;
