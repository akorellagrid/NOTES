import os

import boto3

autoscaling = boto3.client("autoscaling")
sns = boto3.client("sns")

ASG_NAMES = [name for name in os.environ["ASG_NAMES"].split(",") if name]
ALERT_TOPIC_ARN = os.environ["ALERT_TOPIC_ARN"]


def handler(event, context):
    stopped = []
    for name in ASG_NAMES:
        autoscaling.update_auto_scaling_group(
            AutoScalingGroupName=name,
            MinSize=0,
            DesiredCapacity=0,
        )
        stopped.append(name)

    sns.publish(
        TopicArn=ALERT_TOPIC_ARN,
        Subject="Stop-trigger budget hit: ASGs scaled to 0",
        Message=(
            "Actual spend crossed the configured stop-trigger budget threshold.\n\n"
            f"Scaled to 0 instances: {', '.join(stopped)}\n\n"
            "RDS and the NAT instance are still running and still billing - "
            "this only stops the app-tier EC2 instances and the traffic they'd "
            "otherwise serve. Reset desired_capacity via Terraform "
            "(environments/primary/variables.tf) to bring the app back up."
        ),
    )

    return {"stopped_asgs": stopped}
