CREATE EXTERNAL TABLE IF NOT EXISTS flights
(
  year int,
  month int,
  dayofmonth int,
  dayofweek int,
  deptime int,
  crsdeptime int,
  arrtime int,
  crsarrtime int,
  uniquecarrier string,
  flightnum int,
  tailnum string,
  actualelapsedtime int,
  crselapsedtime int,
  airtime string,
  arrdelay int,
  depdelay int,
  origin string,
  dest string,
  distance int,
  taxiin string,
  taxiout string,
  cancelled int,
  cancellationcode string,
  diverted int,
  carrierdelay string,
  weatherdelay string,
  nasdelay string,
  securitydelay string,
  lateaircraftdelay string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
TBLPROPERTIES("skip.header.line.count"="1");

LOAD DATA INPATH 'file:/tmp/flights/2006.csv' INTO TABLE flights;
LOAD DATA INPATH 'file:/tmp/flights/2007.csv' INTO TABLE flights;
LOAD DATA INPATH 'file:/tmp/flights/2008.csv' INTO TABLE flights;

CREATE EXTERNAL TABLE IF NOT EXISTS airlines
(
  Code string,
  Description string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES
(
  "separatorChar" = '\,',
  "quoteChar"     = '\"'
)
STORED AS TEXTFILE
tblproperties("skip.header.line.count"="1");

LOAD DATA INPATH 'file:/tmp/airlines.csv' INTO TABLE airlines;


CREATE EXTERNAL TABLE IF NOT EXISTS airports
(
id string,
name string,
city string,
country string,
faa string,
icao string,
lat double,
lon double,
alt int,
tz_offset double,
dst string,
tz_name string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES
(
"separatorChar" = '\,',
"quoteChar"     = '\"'
)
STORED AS TEXTFILE;

LOAD DATA INPATH 'file:/tmp/airports.csv' INTO TABLE airports;
