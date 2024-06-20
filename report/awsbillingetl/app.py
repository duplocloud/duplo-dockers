import datetime
import json
import os
import pandas as pd
import boto3
import sys
import shutil
from io import StringIO
from datetime import datetime, time, timedelta
import pytz

class S3BillingFile:
    def __init__(self, index, bucket_name, file_name, file_size, file_date, data_folder):
        self.file_index = index
        self.bucket_name = bucket_name
        self.s3_object_key = file_name
        self.file_size = file_size
        self.last_modified = file_date.strftime('%Y-%m-%d %H:%M:%S')
        self.file_date = file_date
        self.local_file_name = data_folder + str(index) + "-" + os.path.basename(file_name)
        print(self.file_index, self.local_file_name, "size", file_size, "bucket", bucket_name, "s3-file", self.s3_object_key)



class AwsBillingReports:

    def __init__(self):
        self.file_count = self.file_max_count = 10000000
        self.file_count = 0
        self.out_folder = "/tmp"
        self.temp_out_folder = self.out_folder + "/reports_temp/"
        self.billing_csv_folder = self.out_folder + "/reports_combined/"
        self.data_folder = self.out_folder + "/data/"
        self.dest_s3_bucket = "duplo-billing-reports"
        self.start = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.s3_client = boto3.client('s3')
        self.billing_report_files = []
        self.empty_buckets = []
        self.cleanup_events_cutoff_date = datetime.now() - timedelta(days=10)
        self.cleanup_events_cutoff_date = self.cleanup_events_cutoff_date.replace(tzinfo=pytz.utc)

    def _create_csvs(self, json_file):
        with open(json_file) as f:
            data = json.load(f)
        host = data["Host"]
        customer = data["CustomerName"]
        customer_id = data["CustomerId"]
        aws_account_id = data["AwsAccountId"]
        monthly_data = data['data']['Monthly']
        monthly_bill = []
        services_bill = []
        tenants_bill = []
        tenants_service_bill = []
        for start_date in monthly_data:
            billing_data = monthly_data[start_date]
            tenants = monthly_data[start_date]['Tenants']
            services = monthly_data[start_date]['Services']
            monthly_bill.append({
                'Customer': customer,
                'Host': host,
                'CustomerId': customer_id,
                'AwsAccountId': aws_account_id,
                'StartDate': start_date,
                'Total': billing_data['T'],
                'Weekly': json.dumps(billing_data['W']),
                'Service': None,
                'Tenant': None,
                'Usage': billing_data['Usage'],
                'Tax': billing_data['Tax'],
                'Support': billing_data['Support'],
                'Other': billing_data['Other'],
            })
            self._process_tenants(tenants_service_bill, tenants_bill, start_date, tenants, customer, host, customer_id,
                                  aws_account_id)
            self._process_services(services_bill, start_date, services, customer, host, customer_id, aws_account_id)

        # Output monthly.csv
        monthly_df = pd.DataFrame(monthly_bill)
        monthly_df = monthly_df.filter(
            ['StartDate', 'Customer', 'Host', 'CustomerId', 'AwsAccountId', 'Total', 'Weekly', 'Usage', 'Tax',
             'Support', 'Other'])
        self._save_csv(monthly_df, "monthly.csv")

        # Output service.csv
        services_bill_df = pd.DataFrame(services_bill)
        services_bill_df = services_bill_df.filter(
            ['StartDate', 'Customer', 'Host', 'CustomerId', 'AwsAccountId', 'Total', 'Weekly', 'Service'])
        self._save_csv(services_bill_df, "service.csv")

        # Output tenant.csv
        tenants_bill_df = pd.DataFrame(tenants_bill)
        tenants_bill_df = tenants_bill_df.filter(
            ['StartDate', 'Customer', 'Host', 'CustomerId', 'AwsAccountId', 'Total', 'Weekly', 'Tenant'])
        self._save_csv(tenants_bill_df, "tenant.csv")

        # Output tenant-service.csv
        tenants_service_bill_df = pd.DataFrame(tenants_service_bill)
        tenants_service_bill_df = tenants_service_bill_df.filter(
            ['StartDate', 'Customer', 'Host', 'CustomerId', 'AwsAccountId', 'Total', 'Weekly', 'Service', 'Tenant'])
        self._save_csv(tenants_service_bill_df, "tenantService.csv")

        # Output billing-all.csv
        all_bill = monthly_bill + tenants_bill + services_bill + tenants_service_bill
        all_df = pd.DataFrame(all_bill)
        self._save_csv(all_df, "billingAll.csv")

    def _save_csv(self, df, csv_name):
        temp_file = self.temp_out_folder + csv_name
        combined_file = self.billing_csv_folder + csv_name
        exists = os.path.exists(combined_file)
        if not exists:
            df.to_csv(combined_file, index=False, header=True)
            self._log(self.file_count, "combinedfile", combined_file)
        else:
            df.to_csv(temp_file, index=False, header=False)
            with open(temp_file, 'r') as source_file, open(combined_file, 'a') as destination_file:
                content = source_file.read()
                destination_file.write(content)

    def _process_tenants(self, tenants_service_bill, billing, start_date, tenants, customer,
                         host, customer_id, aws_account_id):
        for tenant in tenants:
            billing_data = tenants[tenant]
            services = tenants[tenant]['Services']
            billing.append({
                'Customer': customer,
                'Host': host,
                'CustomerId': customer_id,
                'AwsAccountId': aws_account_id,
                'StartDate': start_date,
                'Total': billing_data['T'],
                'Weekly': json.dumps(billing_data['W']),
                'Service': None,
                'Tenant': tenant,
                'Usage': None,
                'Tax': None,
                'Support': None,
                'Other': None,
            })
            self._process_services(tenants_service_bill, start_date, services, customer,
                                   host, customer_id, aws_account_id, tenant)

    def _process_services(self, bill, start_date, services, customer, host, customer_id, aws_account_id, tenant=None):
        for service in services:
            data = services[service]
            bill.append({'Customer': customer,
                         'Host': host,
                         'CustomerId': customer_id,
                         'AwsAccountId': aws_account_id,
                         'StartDate': start_date,
                         'Total': data['T'],
                         'Weekly': json.dumps(data['W']),
                         'Service': service,
                         'Tenant': tenant,
                         'Usage': None,
                         'Tax': None,
                         'Support': None,
                         'Other': None,
                         })

    def upload_csv_files(self, upload_s3_folder):
        for csv_file in os.listdir(self.billing_csv_folder):
            if csv_file.endswith(".csv"):
                file_path = self.billing_csv_folder + csv_file
                file_stats = os.stat(file_path)
                file_size = f"{round(file_stats.st_size / 1024)} kB"
                self._log(self.file_count, "csv", file_path, "fileSize", file_size)
                with open(file_path, "rb") as f:
                    self.s3_client.upload_fileobj(f, self.dest_s3_bucket, upload_s3_folder + "/" + csv_file)


    def etl_on_customer_billing_s3_buckets(self, upload_s3_folder):
        self._log(self.file_count, "temp_out_folder ", self.temp_out_folder)
        self._log(self.file_count, "billing_csv_folder", self.temp_out_folder)
        self._log(self.file_count, "data_folder", self.data_folder)
        self.recreate_local_folder(self.temp_out_folder)
        self.recreate_local_folder(self.billing_csv_folder)
        self.recreate_local_folder(self.data_folder)

        #s3_file_prefix = "data/billing-data-12months/last-12-months/"
        s3_file_prefix = "data/billing/aws/"
        s3_bucket_prefix = "duplo-analytics-"

        response = self.s3_client.list_buckets()
        buckets = [bucket['Name'] for bucket in response['Buckets'] if bucket['Name'].startswith(s3_bucket_prefix)]


        for bucket in buckets:
            paginator = self.s3_client.get_paginator('list_objects_v2')
            for page in paginator.paginate(Bucket=bucket):
                self._log(self.file_count,"bucket", bucket)
                if len(page.get('Contents', []))== 0:
                    self.empty_buckets.append(bucket)
                for obj in page.get('Contents', []):
                    file_name = obj['Key']
                    file_size = obj['Size']
                    file_date = obj['LastModified']
                    if s3_file_prefix in file_name and "json" in file_name:
                        if file_date < self.cleanup_events_cutoff_date and "json" in file_name:
                            print("found delete file_name ", file_name)
                            try:
                                #self.s3_client.delete_object(Bucket=self.dest_s3_bucket, Key=file_name)
                                print(f"Successfully deleted old file {self.dest_s3_bucket}/{file_name} file_date: {file_date.strftime('%Y-%m-%d %H:%M:%S')}")
                            except Exception as e:
                                print(f"Successfully deleted old file {self.dest_s3_bucket}/{file_name} file_date: {file_date.strftime('%Y-%m-%d %H:%M:%S')}"
                                      f" file: {file_name} {str(e)}")
                        else:
                            self.file_count += 1
                            s3_billing_file = S3BillingFile(self.file_count, bucket, file_name, file_size, file_date,
                                                            self.data_folder)
                            self._process_s3_billing_file(s3_billing_file)
                            self.billing_report_files.append(s3_billing_file)

        # save empty buckets
        self._save_empty_buckets_csv()
        # save processed files
        self._save_billing_report_csv()
        # Upload csvs
        self.upload_csv_files(upload_s3_folder)

    def _save_empty_buckets_csv(self):
        empty_buckets_file = self.billing_csv_folder + "empty_buckets.csv"
        empty_buckets_json = json.dumps([{
            "bucket": bucket
        } for bucket in self.empty_buckets])
        sum_df = pd.read_json(StringIO(empty_buckets_json))
        sum_df.to_csv(empty_buckets_file, index=False, header=True)

    def convert_size(self, bytes):
        kb = bytes / 1024
        mb = kb / 1024
        if mb >= 1:
            return f"{mb:.2f} MB"
        elif kb >= 1:
            return f"{kb:.2f} KB"
        else:
            return f"{bytes} bytes"
    def _save_billing_report_csv(self):
        billing_report_file = self.billing_csv_folder + "billing_report_files.csv"
        billing_report_json = json.dumps([{
            "file_index": s3_file.file_index,
            "last_modified": s3_file.last_modified,
            "file_size": self.convert_size(s3_file.file_size),
            "bucket_name": s3_file.bucket_name,
            "s3_object_key": s3_file.s3_object_key
        } for s3_file in self.billing_report_files])
        sum_df = pd.read_json(StringIO(billing_report_json))
        sum_df.to_csv(billing_report_file, index=False, header=True)

    def _process_s3_billing_file(self, s3_billing_file):
        self.file_count += 1
        self.file_count = s3_billing_file.file_index
        self._log(self.file_count, "_process_s3_billing_file " + s3_billing_file.bucket_name
              + " " + s3_billing_file.s3_object_key + " "
              + s3_billing_file.local_file_name)
        self.s3_client.download_file(s3_billing_file.bucket_name, s3_billing_file.s3_object_key, s3_billing_file.local_file_name)
        self._create_csvs(s3_billing_file.local_file_name)
        self.delete_local_file(s3_billing_file.local_file_name)

    def recreate_local_folder(self, folder_path):
        try:
            self._log(self.file_count, "Folder delete " + folder_path)
            shutil.rmtree(folder_path)
            self._log(self.file_count, "Folder deleted successfully " + folder_path)
        except Exception as e:
            self._log(self.file_count, f"Error Folder delete occurred: {e} " + folder_path)
        os.makedirs(folder_path, exist_ok=True)

    def delete_local_file(self, file_path):
        try:
            self._log(self.file_count, "File delete " + file_path)
            os.remove(file_path)
            self._log(self.file_count, "File deleted successfully " + file_path)
        except FileNotFoundError:
            self._log(self.file_count, f"The file {file_path} does not exist.")
        except OSError as error:
            self._log(self.file_count, f"Error: {error}")
        except Exception as e:
            self._log(self.file_count, f"Error delete occurred: {e} " + file_path)

    def _log(self, message, *args, **kwargs):
        # timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        # print(f"{timestamp} - {message}", *args, **kwargs)
        print(f"{message}", *args, **kwargs)

def handler(event, context):
    aws_billing_reports = AwsBillingReports()
    aws_billing_reports.etl_on_customer_billing_s3_buckets("aws")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return f"total reports: {str(aws_billing_reports.file_count)}, start: {aws_billing_reports.start}, end: {timestamp}, v:{sys.version} !"


#handler(None, None)
