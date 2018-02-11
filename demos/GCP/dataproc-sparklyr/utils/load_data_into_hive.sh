# This script can be used to set up example tables in the Spark cluster.
# It contains code snippets from the Sparklyr website: https://spark.rstudio.com/examples/cloudera-aws/

# Make download directory
mkdir /tmp/flights

# Download flight data by year
for i in {2006..2008}
  do
    echo "$(date) $i Download"
    fnam=$i.csv.bz2
    wget -O /tmp/flights/$fnam http://stat-computing.org/dataexpo/2009/$fnam
    echo "$(date) $i Unzip"
    #bunzip2 /tmp/flights/$fnam
  done

# Download airline carrier data
wget -O /tmp/airlines.csv http://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS
# Download airports data
wget -O /tmp/airports.csv https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat

hive -f load_tables.sql
