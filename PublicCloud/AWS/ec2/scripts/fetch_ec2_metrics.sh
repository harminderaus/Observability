
#### `scripts/
#### `scripts/fetch_ec2_metrics.sh`

```bash
#!/bin/bash

# Function to get CloudWatch metrics for a given EC2 instance
get_metrics_for_ec2() {
  local instance_id=$1
  local namespace=$2
  local metric_name=$3
  local dimension_name=$4
  local dimension_value=$5

  echo "Fetching metric: $metric_name for EC2 Instance: $instance_id"

  aws cloudwatch get-metric-data --metric-data-queries "[
    {
      \"Id\": \"metric1\",
      \"MetricStat\": {
        \"Metric\": {
          \"Namespace\": \"$namespace\",
          \"MetricName\": \"$metric_name\",
          \"Dimensions\": [
            {
              \"Name\": \"$dimension_name\",
              \"Value\": \"$dimension_value\"
            }
          ]
        },
        \"Period\": 300,
        \"Stat\": \"Average\"
      },
      \"ReturnData\": true
    }
  ]" --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) --output text
}

# Function to load metrics configuration from JSON file
load_metrics_config() {
  local config_file=$1
  namespace=$(jq -r '.Namespace' $config_file)
  metrics=$(jq -c '.Metrics[]' $config_file)
}

# Retrieve EC2 instances
ec2_instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output json)

# Loop through each EC2 instance
for instance in $(echo "${ec2_instances}" | jq -r '.[][]'); do
  echo "Fetching metrics for EC2 Instance: $instance"

  # Load EC2 metrics from JSON
  load_metrics_config "configs/ec2-metrics.json"
  for metric in $metrics; do
    metric_name=$(echo $metric | jq -r '.MetricName')
    dimension_name=$(echo $metric | jq -r '.Dimensions')
    get_metrics_for_ec2 $instance $namespace $metric_name $dimension_name $instance
  done

  # Load custom memory metrics from JSON (if CloudWatch Agent is enabled)
  load_metrics_config "configs/ec2-memory-metrics.json"
  for metric in $metrics; do
    metric_name=$(echo $metric | jq -r '.MetricName')
    dimension_name=$(echo $metric | jq -r '.Dimensions')
    get_metrics_for_ec2 $instance $namespace $metric_name $dimension_name $instance
  done
done
`

```bash
#!/bin/bash

# Function to get CloudWatch metrics for a given EC2 instance
get_metrics_for_ec2() {
  local instance_id=$1
  local namespace=$2
  local metric_name=$3
  local dimension_name=$4
  local dimension_value=$5

  echo "Fetching metric: $metric_name for EC2 Instance: $instance_id"

  aws cloudwatch get-metric-data --metric-data-queries "[
    {
      \"Id\": \"metric1\",
      \"MetricStat\": {
        \"Metric\": {
          \"Namespace\": \"$namespace\",
          \"MetricName\": \"$metric_name\",
          \"Dimensions\": [
            {
              \"Name\": \"$dimension_name\",
              \"Value\": \"$dimension_value\"
            }
          ]
        },
        \"Period\": 300,
        \"Stat\": \"Average\"
      },
      \"ReturnData\": true
    }
  ]" --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) --output text
}

# Function to load metrics configuration from JSON file
load_metrics_config() {
  local config_file=$1
  namespace=$(jq -r '.Namespace' $config_file)
  metrics=$(jq -c '.Metrics[]' $config_file)
}

# Retrieve EC2 instances
ec2_instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output json)

# Loop through each EC2 instance
for instance in $(echo "${ec2_instances}" | jq -r '.[][]'); do
  echo "Fetching metrics for EC2 Instance: $instance"

  # Load EC2 metrics from JSON
  load_metrics_config "configs/ec2-metrics.json"
  for metric in $metrics; do
    metric_name=$(echo $metric | jq -r '.MetricName')
    dimension_name=$(echo $metric | jq -r '.Dimensions')
    get_metrics_for_ec2 $instance $namespace $metric_name $dimension_name $instance
  done

  # Load custom memory metrics from JSON (if CloudWatch Agent is enabled)
  load_metrics_config "configs/ec2-memory-metrics.json"
  for metric in $metrics; do
    metric_name=$(echo $metric | jq -r '.MetricName')
    dimension_name=$(echo $metric | jq -r '.Dimensions')
    get_metrics_for_ec2 $instance $namespace $metric_name $dimension_name $instance
  done
done
