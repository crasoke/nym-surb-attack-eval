#!/bin/sh
docker-compose rm -f
rm -rf ./data/nyx_volume ./data/bin_volume ./results1 ./results2
docker-compose build
docker-compose up -d
docker wait attacker5
docker-compose stop

#refining results of experiment 1
mkdir results1
tshark -r ./data/nyx_volume/gateway1.pcap -qz io,stat,1 > results1/raw_data
sed -n -E 's/^\|\s+([0-9]+) <>\s+[0-9]+ \|\s+([0-9]+) \|\s+([0-9]+) \|$/\1,\2,\3/p' results1/raw_data > results1/result.csv
python3 graphs.py results1/result.csv "Gateway Traffic" results1/result.png

#refining results of experiment 2
mkdir results2
docker logs gateway1 2>&1 | grep "Pushed received packet to DestinationAddressBytes:" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/T/ /' | awk '{cmd="date -d \"" $1 " " substr($2,1,8) "\" +%s"; cmd | getline utime; close(cmd); print utime "," $NF}' > results2/raw_data.csv

STRART_UNIX_TIME=$(cat data/nyx_volume/time)

awk -F, -v target="$STRART_UNIX_TIME" '$1 >= target {print $0}' results2/raw_data.csv > results2/filtered.csv

gawk -F, '
# Step 1: Collect all unique addresses and counts
{
  addresses[$2];  # Store each unique address
  count[$1 "," $2]++;  # Count occurrences of each address at each Unix timestamp
  timestamps[$1];  # Store unique timestamps
}

# Step 2: After reading the entire file, print the results
END {
  # Print the header
  printf "UnixTime";
  for (addr in addresses) { printf "," addr }
  printf "\n";

  # Sort the timestamps in ascending order
  n = asorti(timestamps, sorted_times)

  # For each unique timestamp, print counts for each address
  for (i = 1; i <= n; i++) {
    time = sorted_times[i];
    printf time;
    for (addr in addresses) {
      key = time "," addr;
      if (key in count) {
        printf "," count[key];
      } else {
        printf ",0";  # If an address does not appear at a given timestamp, output 0
      }
    }
    printf "\n";
  }
}' results2/filtered.csv > results2/result.csv

cp data/nyx_volume/victim_address results2/

python3 graphs2.py results2/result.csv "Gateway Received Messages" results2/result.png $(cat results2/victim_address | cut -d '.' -f 1)
