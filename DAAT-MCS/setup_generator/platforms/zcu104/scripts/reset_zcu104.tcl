# Connect to target
connect
after 2000
# Disable Security gates to view PMU MB target
targets -set -nocase -filter {name =~ "*PSU*"}
after 2000
rst
after 2000
con
