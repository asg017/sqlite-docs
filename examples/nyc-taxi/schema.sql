
create table nyc_yellow_taxi_trips(
  --! Yellow Taxi trips made in New York City.  Each row is a specific trip, with a set start and
  --! end time. This table is specifically for yellow taxi cab rides, NOT green or FHV trips.
  --!
  --! This data is publishecad by the NYC Taxi & Limousine Commission.
  --!
  --! @source https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf

  --- A code indicating the TPEP provider that provided the record.
  --- @value 1, Creative Mobile Technologies, LLC
  --- @value 2, VeriFone Inc.
  --- @example 1
  vendor_id int,

  --- Datetime when the meter was engaged. In YYYY-MM-DD HH:MM:SS format.
  --- @example "2023-01-01 00:32:10"
  pickup_datetime datetime,

  --- @example "2023-01-01 00:40:36"
  dropoff_datetime datetime,

  --- The number of passengers in the vehicle, as reported by the driver.
  --- @example 1
  passenger_count int,

  --- The elapsed trip distance in miles reported by the taximeter.
  --- @example 0.97
  trip_distance float,

  --- TLC Taxi Zone in which the taximeter was engaged
  --- @example 161
  pickup_location_id int,

  --- TLC Taxi Zone in which the taximeter was disengaged
  --- @example 141
  dropoff_location_id int,

  --- A numeric code signifying how the passenger paid for the trip.
  --- 1: Credit card
  --- 2: Cash
  --- 3: No charge
  --- 4: Dispute
  --- 5: Unknown
  --- 6: Voided trip
  --- @example 4
  payment_type int,

  --- The time-and-distance fare calculated by the meter
  --- @example 9.3
  fare_amount float,

  --- Miscellaneous extras and surcharges. Currently, this only includes the
  --- $0.50 and $1 rush hour and overnight charges.
  --- @example 1.0
  extra_amount float,

  --- $0.50 MTA tax that is automatically triggered based on the metered rate
  -- in use.
  --- @example 0.5
  mta_tax float,

  --- This field is automatically populated for credit card tips.
  --- Cash tips are not included.
  --- @example 4.0
  tip_amount float,


  --- Total amount of all tolls paid in trip.
  --- @example 3.0
  tolls_amount float,

  --- The total amount charged to passengers. Does not include cash tips
  --- @example 16.9
  total_amount float
);
