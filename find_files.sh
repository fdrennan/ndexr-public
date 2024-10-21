#!/bin/bash

# Directory to start with
if [ -d "~/ndexr" ]; then
  base_dir=~/ndexr/srv
else
  base_dir=~/manager/srv
fi


# Go into the base directory
cd $base_dir || { echo "Base directory not found!"; exit 1; }

# Function to process the services directory
process_services_dir() {
  local services_dir=$1

  # Loop through each project folder in the services directory
  project_folders=$(ls -d ${services_dir}/*/)
  for project_folder in $project_folders; do

    # Get Dockerfile in each project folder
    dockerfile="${project_folder}Dockerfile"

    # Print full path of Dockerfile
    if [ -f "$dockerfile" ]; then
      echo "$dockerfile"
    fi

    # Check for nginx service and get sites-enabled files
    nginx_dir="${project_folder}config/sites-enabled"
    if [ -d "$nginx_dir" ]; then
      sites_enabled_files=$(ls "$nginx_dir")
      if [ -n "$sites_enabled_files" ]; then
        for file in $sites_enabled_files; do
          echo "${nginx_dir}/${file}"
        done
      fi
    fi

    # Check for nginx.conf file
    nginx_conf="${project_folder}config/nginx.conf"
    if [ -f "$nginx_conf" ]; then
      echo "$nginx_conf"
    fi

    # Check for conf.d directory and list files
    conf_d_dir="${project_folder}config/conf.d"
    if [ -d "$conf_d_dir" ]; then
      conf_d_files=$(ls "$conf_d_dir")
      if [ -n "$conf_d_files" ]; then
        for file in $conf_d_files; do
          echo "${conf_d_dir}/${file}"
        done
      fi
    fi
  done
}

# Get the folder names in the base directory
folders=$(ls -d */)

# Loop through each folder to get .yml files
for folder in $folders; do

  # Go into each subfolder
  subfolder_path="${base_dir}/${folder}"
  cd $subfolder_path || { echo "Subfolder not found!"; continue; }

  # Get all .yml files in the subfolder
  yml_files=$(ls *.yml 2>/dev/null)

  # Print full paths of .yml files
  if [ -n "$yml_files" ]; then
    for yml_file in $yml_files; do
      echo "${subfolder_path}${yml_file}"
    done
  fi

  # Check for service subdirectory and process
  service_dir="${subfolder_path}/service"
  if [ -d "$service_dir" ]; then
    # Loop through each service subfolder
    service_folders=$(ls -d ${service_dir}/*/)
    for service_folder in $service_folders; do

      # Get Dockerfile in each service subfolder
      dockerfile="${service_folder}Dockerfile"

      # Print full path of Dockerfile
      if [ -f "$dockerfile" ]; then
        echo "$dockerfile"
      fi

      # Check for nginx service and get sites-enabled files
      nginx_dir="${service_folder}config/sites-enabled"
      if [ -d "$nginx_dir" ]; then
        sites_enabled_files=$(ls "$nginx_dir")
        if [ -n "$sites_enabled_files" ]; then
          echo "Sites-enabled files in ${nginx_dir}:"
          for file in $sites_enabled_files; do
            echo "${nginx_dir}/${file}"
          done
        fi
      fi

      # Check for nginx.conf file
      nginx_conf="${service_folder}config/nginx.conf"
      if [ -f "$nginx_conf" ]; then
        echo "$nginx_conf"
      fi

      # Check for conf.d directory and list files
      conf_d_dir="${service_folder}config/conf.d"
      if [ -d "$conf_d_dir" ]; then
        conf_d_files=$(ls "$conf_d_dir")
        if [ -n "$conf_d_files" ]; then
          for file in $conf_d_files; do
            echo "${conf_d_dir}/${file}"
          done
        fi
      fi
    done
  fi

  # Return to the base directory
  cd $base_dir || { echo "Failed to return to base directory!"; exit 1; }
done

# Loop through each dynamically determined folder
for folder in $folders; do

  subfolder_path="${base_dir}/${folder}services"
  if [ -d "$subfolder_path" ]; then
    process_services_dir "$subfolder_path"
  fi
done

# Search for HTML files in any project with 'services/nginx/html/errors' path
find_errors_html_files() {
  # Find all directories matching 'services/nginx/html/errors' under the base directory
  error_dirs=$(find "$base_dir" -type d -path "*/services/nginx/html/errors")
  for error_dir in $error_dirs; do
    html_files=$(ls "$error_dir"/*.html 2>/dev/null)
    if [ -n "$html_files" ]; then
      for html_file in $html_files; do
        echo "$html_file"
      done
    fi
  done
}

# Call the function to find and list HTML files
find_errors_html_files
