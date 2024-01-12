#!/bin/bash

source ./scripts/log_utils.sh

fetch_raw_json() {
    local unifi_ip="$1"
    local endpoint="$2"
    local filename="$3"
    local token="$4"

    log_debug "API Endpoint: https://$unifi_ip/$endpoint"
    local raw=$(curl -s -S "https://$unifi_ip/$endpoint" \
        -H "authority: $unifi_ip" \
        -H 'accept: application/json, text/plain, */*' \
        -H 'accept-language: en-US,en' \
        -H "cookie: TOKEN=$token" \
        --compressed \
        --insecure)

    echo "$raw" | jq > json/raw/$filename.json
    log_debug "Raw JSON saved to json/raw/$filename.json"
    
    echo "$raw"
}

# Function to sort JSON data
alphabetize_raw_json() {
    local json_data=$1

    echo "$json_data" | jq '

    # Define a recursive sorting function named "recursive_sort"
    def recursive_sort: 
        if type == "object" then 
            to_entries | 
            sort_by(.key) | 
            map({ ( .key ): (.value | recursive_sort) }) | 
            add 
        elif type == "array" then 
            map(recursive_sort) 
        else 
            . 
        end; 

    recursive_sort'
}

# Function to read and output JSON data
read_json() {
    local file_name="$1"
    local -n keys=$2

    log_debug_object_count "$file_name"
    
    # Helper function to create a dynamic jq filter from the KEYS array
    create_jq_filter() {
        # Defining a jq function 'parse' using heredoc for readability.
        # This function checks if a given field exists at the top level,
        # handles array types by joining their elements with commas, 
        # or returns the field value directly.
        local jq_parse_function=$(cat <<'EOF'
def parse(field): 
  if (has(field)) then 
    if (.[field] | type) == "array" then 
      if (.[field] | length) == 0 then 
        "" 
      else 
        if field == "port_table" then
          .[field] | tojson
        elif field == "x_ssh_keys" then
          .[field] | tojson
        elif field == "schedule_with_duration" then
          .[field] | tojson
        elif field == "auth_servers" then
          .[field] | map([.ip, .port | tostring] | join(":")) | join(",")
        else
          .[field] | join(",") 
        end
      end 
    else 
      .[field] 
    end 
  else 
    "" 
  end;
EOF
        )

        # Start building the main jq filter command. This command will
        # apply the parse function to each field listed in the KEYS array.
        local jq_main_filter='.[] | ['

        # Iterate over the KEYS array, appending each key to the jq filter.
        for key in "${keys[@]}"; do
            jq_main_filter+="parse(\"$key\"), "
        done

        # Trim the trailing comma and space from the filter string, then
        # close the filter with a bracket and join the results with a custom delimiter.
        jq_main_filter=${jq_main_filter%, }
        jq_main_filter+="] | join(\"◊\")"

        # Combine the parse function and the main filter to form the complete jq filter.
        echo "$jq_parse_function $jq_main_filter"
    }

    # Generate the dynamic jq filter by calling the helper function.
    local dynamic_filter=$(create_jq_filter)

    # Execute the jq command with the dynamically generated filter
    # to process the JSON file.
    jq -r "$dynamic_filter" "$file_name"
}
