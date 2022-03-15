import boto3
from crhelper import CfnResource
import logging
import json

logger = logging.getLogger(__name__)
# Initialise the helper, all inputs are optional, this example shows the defaults
helper = CfnResource(json_logging=False, log_level='DEBUG', boto_level='CRITICAL')

@helper.create
def create(event, context):
    logger.info(f"Creating resource {event}")    
    return get_latest_ami(event['ResourceProperties']['Name'])

@helper.update
def update(event, context):
    logger.info(f"Updating resource {event}")
    return get_latest_ami(event['ResourceProperties']['Name'])

@helper.delete
def delete(event, context):
    logger.info(f"Deleting resource {event}")

def get_latest_ami(name):
    client = boto3.client('ec2')

    filters = []
    filters.append({'Name': 'name', 'Values': [name]})
    response = client.describe_images(Filters=filters)

    if not response['Images']:
        return None

    response['Images'].sort(key=lambda r: r['CreationDate'])
    return response['Images'][-1]['ImageId']

def handler(event, context):
    helper(event, context)
