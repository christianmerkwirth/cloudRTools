library('bigrquery')

# Use your project ID here
project <- "river-vigil-178615" # put your project ID here

# Create a data frame to store results by year
year_results <- data.frame(matrix(nrow = 0, ncol = 0))

sql <- paste("SELECT MAX(max) as HIGH, state, year ",
             "FROM ",
             "  ( ",
             "    SELECT max, ",
             "      stn as istn,",
             "      wban as iwban, year",
             "    FROM [bigquery-public-data.noaa_gsod.gsod*]",
             "  ) a ",
             "JOIN [bigquery-public-data.noaa_gsod.stations] b ",
             "ON a.istn = b.usaf ",
             "  AND a.iwban = b.wban ",
             "WHERE state in (",
             "  'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', ",
             "  'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', ",
             "  'MN', 'MO', 'MS', 'MT', 'NC', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', ",
             "  'NY', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', ",
             "  'VA', 'VT', 'WA', 'WI', 'WV', 'WY')",
             "  AND max < 1000 ",
             "  AND country = 'US' ",
             "GROUP BY state, year ",
             "ORDER BY year desc, state asc",
             sep = "")
res <- query_exec(sql, project = project, useLegacySql = FALSE)

# Store result for this table query in year_results
if (nrow(year_results) == 0) {
  year_results <- res
} else {
  year_results <- rbind(year_results, res)
}

# Create mapping of state name to rainbow color
colIndex <- c(1:50)
abbrevs <- c('AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
             'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME',
             'MI', 'MN', 'MO', 'MS', 'MT', 'NC', 'ND', 'NE', 'NH', 'NJ', 'NM',
             'NV', 'NY', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX',
             'UT', 'VA', 'VT', 'WA', 'WI', 'WV', 'WY')
names(colIndex) <- abbrevs

# Plot data using color defined by state
plot(year_results$year, year_results$HIGH, xlab="YEAR", ylab="Temp",
     col=rainbow(50)[colIndex[year_results$state]],
     ylim=c(60, 140), xlim=c(1980, 2015))
