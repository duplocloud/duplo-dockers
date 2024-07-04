import requests
import os
from dotenv import load_dotenv
import json
import datetime
import json
import os
import pandas as pd
import boto3
import sys
import shutil
from io import StringIO
from datetime import datetime, timedelta


class CustomerBillingS3Sync:
    def __init__(self, index, name, id, cloudPlatforms):
        self.index = index
        self.name = name
        self.id_str = f"{str(id)} "
        self.customer_id = id
        self.cloudPlatforms = cloudPlatforms
        self.bucket = "duplo-analytics-" + id
        self.s3_files = []
        self.awsAccountIds = []
        self.awsAccountIdCompeted = []
        self.envNames = []
        self.customerName = ""
        self.customerUrls = []
        self.NoSuchBucket = ""

    def completedEnv(self):
        if len(self.awsAccountIds) > 0:
            s3files = ", ".join(map(str, self.s3_files))
            count = len(self.awsAccountIds)
            foundCount = 0
            for awsAccountId in self.awsAccountIds:
                if awsAccountId in s3files:
                    foundCount = foundCount - 1
                    self.awsAccountIdCompeted.append(awsAccountId)
            return (count == foundCount)

    def get_is_completed(self):
        self.awsAccountIdCompeted = []
        completed = self.completedEnv()
        print(
            f"completed:{completed}, a:{len(self.awsAccountIdCompeted)} == {len(self.awsAccountIds)}, s3:{len(self.s3_files)} env:{len(self.envNames)} b:{self.NoSuchBucket}")
        if len(self.NoSuchBucket) > 0:
            is_completed = "no bucket"
        elif len(self.awsAccountIdCompeted) > 0 and len(self.awsAccountIdCompeted) == len(self.awsAccountIds):
            is_completed = "completed"
        elif len(self.awsAccountIdCompeted) == 0 and len(self.NoSuchBucket) > 0:
            is_completed = "no_bucket"
        elif len(self.awsAccountIdCompeted) > 0:
            is_completed = "paritially_completed"
        elif len(self.awsAccountIdCompeted) == 0:
            is_completed = "pending"
        else:
            is_completed = "unknown"
        self.is_completed = is_completed
        print(self.is_completed)
        return self.is_completed

    def pending_to_dict(self):
        self.get_is_completed()
        self.envs_zipped = list(zip(self.envNames, self.awsAccountIds))
        self.completed_env = [(a, b) for a, b in zip(self.envNames, self.awsAccountIds) if
                              a in self.awsAccountIdCompeted]

    def to_dict(self):
        self.is_completed = self.get_is_completed()
        print(self.is_completed)
        has_s3_files = "NO_S3_UPLOADS" if len(self.s3_files) == 0 else "HAS_S3_UPLOADS"
        completed_ids = "NO_COMPLETED_ENV" if len(self.awsAccountIdCompeted) == 0 else ", ".join(
            map(str, self.awsAccountIdCompeted))
        env_names = "NO_ENVS" if len(self.envNames) == 0 else ", ".join(map(str, self.envNames))
        awsAccountIds = "NO_AWS_AC_IDS" if len(self.awsAccountIds) == 0 else ", ".join(map(str, self.awsAccountIds))
        s3_files = "NO_S3_UPLOADS" if len(self.s3_files) == 0 else ", ".join(map(str, self.s3_files))
        customerUrls = "NO_URLS" if len(self.customerUrls) == 0 else ", ".join(map(str, self.customerUrls))
        env_count = "0" if len(self.envNames) == 0 else len(self.envNames)
        return {
            'CustomerNo': self.index,
            'Name': self.name,
            'CustomerName': self.name,
            'Completed': self.is_completed,
            'CustomerId': f"{str(self.id_str)} .",
            'HasUploads': has_s3_files,
            'CompletedAwsAccountIds': completed_ids,
            'AllAwsAccountIds': awsAccountIds,
            'Bucket': self.bucket,
            'EnvNames': env_names,
            's3_files': s3_files,
            'cloud_platforms': self.cloudPlatforms,
            'urls': customerUrls,
            'env_count': env_count
        }

    def to_dict_array(self):
        self.is_completed = self.get_is_completed()
        print(self.is_completed)
        has_s3_files = "NO_S3_UPLOADS" if len(self.s3_files) == 0 else "HAS_S3_UPLOADS"
        completed_ids = "NO_COMPLETED_ENV" if len(self.awsAccountIdCompeted) == 0 else ", ".join(
            map(str, self.awsAccountIdCompeted))
        env_names = "NO_ENVS" if len(self.envNames) == 0 else ", ".join(map(str, self.envNames))
        awsAccountIds = "NO_AWS_AC_IDS" if len(self.awsAccountIds) == 0 else ", ".join(map(str, self.awsAccountIds))
        s3_files = "NO_S3_UPLOADS" if len(self.s3_files) == 0 else ", ".join(map(str, self.s3_files))
        customerUrls = "NO_URLS" if len(self.customerUrls) == 0 else ", ".join(map(str, self.customerUrls))
        env_count = "0" if len(self.envNames) == 0 else len(self.envNames)
        if len(self.envNames) > 1:
            arr = []
            for index, awsAccountId in enumerate(self.awsAccountIds):
                s3_file_name = "NO_S3_UPLOADS"
                has_s3_files = "NO_S3_UPLOADS"
                for s3_file_name_found in self.s3_files:
                    if awsAccountId in s3_file_name_found:
                        s3_file_name = s3_file_name_found
                        has_s3_files = s3_file_name_found
                env_completed = "pending"
                env_name = self.envNames[index]
                url = self.customerUrls[index]
                if "gov" in url:
                    continue
                if awsAccountId in self.awsAccountIdCompeted:
                    env_completed = "completed"
                    has_s3_files = f"{str(awsAccountId)} ."
                anv_dict = {
                    'CustomerNo': self.index,
                    'CustomerName': self.name,
                    'Name': env_name,
                    'Completed': env_completed,
                    'CustomerId': f"{str(self.id_str)} .",
                    'HasUploads': has_s3_files,
                    'CompletedAwsAccountIds': awsAccountId,
                    'AllAwsAccountIds': awsAccountId,
                    'Bucket': self.bucket,
                    'EnvNames': env_name,
                    's3_files': s3_file_name,
                    'cloud_platforms': self.cloudPlatforms,
                    'urls': url,
                    'env_count': 1
                }
                arr.append(anv_dict)
            return arr
        else:
            return {
                'CustomerNo': self.index,
                'Name': self.name,
                'CustomerName': self.name,
                'Completed': self.is_completed,
                'CustomerId': f"{str(self.id_str)} .",
                'HasUploads': has_s3_files,
                'CompletedAwsAccountIds': completed_ids,
                'AllAwsAccountIds': awsAccountIds,
                'Bucket': self.bucket,
                'EnvNames': env_names,
                's3_files': s3_files,
                'cloud_platforms': self.cloudPlatforms,
                'urls': customerUrls,
                'env_count': env_count
            }


class Cust:
    def __init__(self):
        dotenv_path = '.env'
        load_dotenv(dotenv_path)
        self.bearer_token = os.getenv('BEARER_TOKEN')
        self.out_folder = "./data/"
        self.start = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.s3_client = boto3.client('s3')
        self.customerBillingS3SyncList = []
        self.custdatajson = self.getCustomers()
        self.parseCustomers()
        # self.customersToJson()

    def parseCustomers(self):
        counter = 0
        for customer in self.custdatajson:
            counter = counter + 1
            cloudPlatforms = ", ".join(map(str, customer.get('cloudPlatforms', [])))
            customer_billing_s3_sync = CustomerBillingS3Sync(counter, customer['name'], customer['id'], cloudPlatforms)
            self.getCutomerEnv(customer_billing_s3_sync)
            self.customerBillingS3SyncList.append(customer_billing_s3_sync)
            # print(json.dumps(customer_billing_s3_sync.to_dict()))

        print(len(self.customerBillingS3SyncList))

    # def customersToJson(self):
    #     json_objects = []
    #
    #     for customer_billing_s3_sync in self.customerBillingS3SyncList:
    #         json_objects.append(customer_billing_s3_sync.to_dict())
    #
    #     json_str = json.dumps(json_objects, indent=2)
    #     print(json_str)

    def checkS3Files(self):
        for customer_billing_s3_sync in self.customerBillingS3SyncList:
            self.checkHasS3Data(customer_billing_s3_sync)

    def getCustomers(self):
        url = 'https://devopsmgr.prod-apps.duplocloud.net/api/v1/customers'
        bearer_token = os.getenv('BEARER_TOKEN')
        headers = {
            'Authorization': f'Bearer {bearer_token}',
            'Content-Type': 'application/json'  # Assuming JSON content in response
        }
        try:
            response = requests.get(url, headers=headers)
            if response.status_code == 200:
                data = response.json()
                # print(data)
                return data
            else:
                print(f"Request failed with status code {response.status_code}: {response.text}")
        except requests.exceptions.RequestException as e:
            print(f"Request failed: {e}")
        return {}

    def getCutomerEnv(self, customer_billing_s3_sync):
        url = 'https://devopsmgr.prod-apps.duplocloud.net/api/v1/duploEnvironments/customer/' + customer_billing_s3_sync.customer_id
        bearer_token = os.getenv('BEARER_TOKEN')
        headers = {
            'Authorization': f'Bearer {bearer_token}',
            'Content-Type': 'application/json'  # Assuming JSON content in response
        }
        try:
            response = requests.get(url, headers=headers)
            if response.status_code == 200:
                data = response.json()
                for customer in data:
                    customer_billing_s3_sync.awsAccountIds.append(customer['cloudAccountId'] or "")
                    customer_billing_s3_sync.envNames.append(customer['name'] or "")
                    customer_billing_s3_sync.customerName = customer['company'] or ""
                    customer_billing_s3_sync.customerUrls.append(customer['portalUrl'] or "")
                return data
            else:
                print(f"Request failed with status code {response.status_code}: {response.text}")
        except requests.exceptions.RequestException as e:
            print(f"Request failed: {e}")
        return {}

    def checkHasS3Data(self, customer_billing_s3_sync):
        s3_client = boto3.client('s3')
        customer_and_bucket = customer_billing_s3_sync.name + " " + customer_billing_s3_sync.bucket
        bucket_name = customer_billing_s3_sync.bucket
        print(bucket_name)
        s3_file_prefix = "data/billing/aws"
        try:
            s3_files = []
            response = s3_client.list_objects_v2(Bucket=bucket_name)
            if 'Contents' in response:
                for obj in response['Contents']:
                    file_name = obj['Key']
                    if s3_file_prefix in file_name and "json" in file_name:
                        s3_files.append(os.path.basename(file_name))

                customer_billing_s3_sync.s3_files = s3_files
                print(f"found files: {customer_and_bucket} {json.dumps(customer_billing_s3_sync.s3_files)}")
            else:
                print(f"No objects found in bucket: {customer_and_bucket}")
        except Exception as e:
            print(f"Error listing objects in bucket {customer_and_bucket}: {e}")
            if "NoSuchBucket" in f"{e}":
                customer_billing_s3_sync.NoSuchBucket = "NoSuchBucket"

    def _save_completed(self, df, suffix):
        analytics_billling_file = self.out_folder + "billing_completed_" + suffix + ".csv"
        filtered_df = df[df['Completed'] == "completed"]
        selected_columns = ['CustomerName', 'Completed', 'Name', 'CustomerId', 'AllAwsAccountIds']
        final_df = filtered_df[selected_columns]
        final_df.to_csv(analytics_billling_file, index=False, header=True)

    def _save_paritially_completed(self, df, suffix):
        analytics_billling_file = self.out_folder + "billing_paritially_completed_" + suffix + ".csv"
        filtered_df = df[df['Completed'] == "paritially_completed"]
        selected_columns = ['CustomerName', 'Completed', 'Name', 'CustomerId', 'AllAwsAccountIds']
        final_df = filtered_df[selected_columns]
        final_df.to_csv(analytics_billling_file, index=False, header=True)

    def _save_pending(self, df, suffix):
        analytics_billling_file = self.out_folder + "billing_pending_" + suffix + ".csv"
        filtered_df = df[df['Completed'] == "pending"]
        selected_columns = ['CustomerName', 'Completed', 'Name', 'CustomerId', 'AllAwsAccountIds']
        final_df = filtered_df[selected_columns]
        final_df.to_csv(analytics_billling_file, index=False, header=True)

    def _save_report_csv(self):
        for customer_billing_s3_sync in self.customerBillingS3SyncList:
            self.checkHasS3Data(customer_billing_s3_sync)
        analytics_billling_file = self.out_folder + "billing_customers.csv"
        if len(self.customerBillingS3SyncList) > 0:
            analytics_bulling_json = json.dumps([s3_file.to_dict() for s3_file in self.customerBillingS3SyncList])
            sum_df = pd.read_json(StringIO(analytics_bulling_json))
            sum_df = sum_df.sort_values(by='Name')
            sum_df.to_csv(analytics_billling_file, index=False, header=True)
            self._save_pending(sum_df, "customers")
            self._save_paritially_completed(sum_df, "customers")
            self._save_completed(sum_df, "customers")
            self._save_report_env_csv()

    def _save_report_env_csv(self):
        analytics_bulling_json = []
        for s3_file in self.customerBillingS3SyncList:
            dict_representation = s3_file.to_dict_array()
            if isinstance(dict_representation, list):
                analytics_bulling_json.extend(dict_representation)
            else:
                analytics_bulling_json.append(dict_representation)
        analytics_billling_file = self.out_folder + "billing_customers_envs.csv"
        sum_df = pd.read_json(StringIO(json.dumps(analytics_bulling_json)))
        sum_df = sum_df.sort_values(by='Name')
        sum_df.to_csv(analytics_billling_file, index=False, header=True)
        self._save_pending(sum_df, "customer_envs")
        self._save_paritially_completed(sum_df, "customer_envs")
        self._save_completed(sum_df, "customer_envs")


def handler(event, context):
    cust = Cust()
    cust.checkS3Files()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    # cust.customersToJson()
    cust._save_report_csv()
    return f"total reports: {len(cust.customerBillingS3SyncList)}, start: {cust.start}, end: {timestamp}, v:{sys.version} !"


handler(None, None)