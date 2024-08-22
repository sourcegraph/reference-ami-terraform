#!/bin/bash

variables_file_path="./terraform.tfvars"
variable_name_string="tf_last_deployed"
todays_date=$(date +'%Y-%m-%d')

sed -i '' -e "s/.*$variable_name_string.*/$variable_name_string = \"$todays_date\"/" $variables_file_path
