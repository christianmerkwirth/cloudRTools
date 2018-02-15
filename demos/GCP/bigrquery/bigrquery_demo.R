library(bigrquery)

project <- "river-vigil-178615" # put your project ID here

# Example query - select copies of files with content containing "TODO"
sql <- "SELECT SUM(copies)
 FROM [bigquery-public-data:github_repos.sample_contents]
WHERE NOT binary AND content LIKE '%TODO%'"

# Execute the query and store the result
todo_copies <- query_exec(sql, project = project, useLegacySql = FALSE)


# Execute the query and store the result
sql <- "SELECT year, month, day, weight_pounds FROM [publicdata:samples.natality] LIMIT 5"
natality <- query_exec(sql, project = project)


# Standard SQL query string for count of copies by language name.
sql <- 'CREATE TEMPORARY FUNCTION maxBytesLanguage(languages ARRAY<STRUCT<name STRING, bytes INT64>>)

RETURNS STRING LANGUAGE js AS """
var out = ""
var maxBytes = 0
for (var i=0; i < languages.length; i++) {
var lang = languages[i]
if (lang.bytes > maxBytes) {
maxBytes = lang.bytes
out = lang.name
}
}
return out
""";

SELECT SUM(copies) as copies, language_name
FROM (
SELECT
sc.copies as copies,
maxBytesLanguage(l.language) as language_name
FROM [bigquery-public-data.github_repos.sample_contents] as sc
JOIN [bigquery-public-data.github_repos.languages] as l
ON sc.sample_repo_name = l.repo_name
WHERE NOT binary
)
WHERE language_name in ("Awk","C", "C++", "C#", "Go", "Haskell", "Java",
"JavaScript", "Objective-C", "PHP", "Python", "R",
"Ruby", "Shell", "Swift", "Yacc")
GROUP BY language_name
ORDER BY language_name asc'


# Standard SQL query string for total count of copies by language name.
total_copy_counts <- query_exec(sql, project = project, useLegacySql = FALSE)

# Query string for count of file copies by language name where file contains TODO.
sql <- 'CREATE TEMPORARY FUNCTION maxBytesLanguage(languages ARRAY<STRUCT<name STRING, bytes INT64>>)

RETURNS STRING LANGUAGE js AS """
var out = ""
var maxBytes = 0
for (var i=0; i < languages.length; i++) {
var lang = languages[i]
if (lang.bytes > maxBytes) {
maxBytes = lang.bytes
out = lang.name
}
}
return out
""";

SELECT SUM(copies) as copies, language_name
FROM (
SELECT
sc.copies as copies,
maxBytesLanguage(l.language) as language_name
FROM [bigquery-public-data.github_repos.sample_contents] as sc
JOIN [bigquery-public-data.github_repos.languages] as l
ON sc.sample_repo_name = l.repo_name
WHERE NOT binary AND content LIKE "%TODO%"
)
WHERE language_name in ("Awk","C", "C++", "C#", "Go", "Haskell", "Java",
"JavaScript", "Objective-C", "PHP", "Python", "R",
"Ruby", "Shell", "Swift", "Yacc")
GROUP BY language_name
ORDER BY language_name asc'


# Standard SQL query string for total count of copies by language name.
total_copy_counts <- query_exec(sql, project = project, useLegacySql = FALSE)

# Store total copy counts for files by language
todo_copy_counts <- query_exec(sql, project = project, useLegacySql = FALSE)

# Calculate the % copies with TODO comments relative to mean from earlier.
lang_ratios <- c((100 * todo_copy_counts$copies / total_copy_counts$copies) - mean_todo)

# Manually clean up the Objective-C label
total_copy_counts$l_language_name[9] <-"Obj-C"

# Sort
data <- data.frame(lang_ratios, total_copy_counts$l_language_name)
data <- data[order(data[1], decreasing=FALSE),]

# Plot the results
barplot(data$lang_ratios,
        names.arg = data$total_copy_counts.l_language_name,
        ylab="% having TODO", las=2, ylim=c(-2,0.5) )
