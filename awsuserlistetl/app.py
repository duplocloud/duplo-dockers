import datetime
import json
import os
import pandas as pd
import boto3
import sys
import shutil

class S3UserlistFile:
    def __init__(self, index, bucket_name, file_name, file_size, file_date, data_folder):
        self.index = index
        self.bucket_name = bucket_name
        self.s3_object_key = file_name
        self.file_size = file_size
        self.file_date = file_date
        self.local_file_name = data_folder + str(index) + "-" + os.path.basename(file_name)
        print(self.index, self.local_file_name, "size", file_size, "file_date", file_date, "bucket", bucket_name, "s3-file", self.s3_object_key)

class AwsUserlistReports:

    def __init__(self):
        self.file_count = self.file_max_count = 10000000
        self.file_count = 0
        self.out_folder = "/tmp/userlist"
        self.temp_out_folder = self.out_folder + "/reports_temp/"
        self.userlist_csv_folder = self.out_folder + "/reports_combined/"
        self.data_folder = self.out_folder + "/data/"
        self.dest_s3_bucket = "duplo-userlist-reports"
        self.start = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.s3_client = boto3.client('s3')
        self.userlist_report_files = []
        self.empty_buckets = []

    def etl_on_customer_userlist_s3_buckets(self, upload_s3_folder):
        self._log(self.file_count, "temp_out_folder ", self.temp_out_folder)
        self._log(self.file_count, "userlist_csv_folder", self.temp_out_folder)
        self._log(self.file_count, "data_folder", self.data_folder)
        self.recreate_local_folder(self.temp_out_folder)
        self.recreate_local_folder(self.userlist_csv_folder)
        self.recreate_local_folder(self.data_folder)

        #s3_file_prefix = "data/userlist-data-12months/last-12-months/"
        s3_file_prefix = "data/userlist/all/"
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
                        self.file_count += 1
                        s3_userlist_file = S3UserlistFile(self.file_count, bucket, file_name, file_size, file_date, self.data_folder)
                        self._process_s3_userlist_file(s3_userlist_file)
                        self.userlist_report_files.append(s3_userlist_file)

        # save empty buckets
        self._save_empty_buckets_csv()
        # save processed files
        self._save_userlist_report_csv()
        # Upload csvs
        self.upload_csv_files(upload_s3_folder)

    def _process_s3_userlist_file(self, s3_userlist_file):
        self.file_count += 1
        self.file_count = s3_userlist_file.file_index
        dest_s3_object_key = upload_s3_folder + "/" + s3_userlist_file.file_name
        self._log(self.file_count,
                  "_process_s3_userlist_file " + s3_userlist_file.bucket_name
                  + " src: " + s3_userlist_file.s3_object_key
                  + " dest: " + dest_s3_object_key)
        copy_source = {
            'Bucket': s3_userlist_file.bucket_name,
            'Key': s3_userlist_file.s3_object_key
        }
        s3.meta.client.copy(copy_source, self.dest_s3_bucket, dest_s3_object_key)
        s3.Object(s3_userlist_file.bucket_name, s3_userlist_file.s3_object_key).delete()

    def upload_csv_files(self, upload_s3_folder):
        for csv_file in os.listdir(self.userlist_csv_folder):
            if csv_file.endswith(".csv"):
                file_path = self.userlist_csv_folder + csv_file
                file_stats = os.stat(file_path)
                file_size = f"{round(file_stats.st_size / 1024)} kB"
                self._log(self.file_count, "csv", file_path, "fileSize", file_size)
                with open(file_path, "rb") as f:
                    self.s3_client.upload_fileobj(f, self.dest_s3_bucket, upload_s3_folder + "/" + csv_file)

    def _save_empty_buckets_csv(self):
        empty_buckets_file = self.userlist_csv_folder + "empty_buckets.csv"
        empty_buckets_json = json.dumps([{
            "bucket": bucket
        } for bucket in self.empty_buckets])
        sum_df = pd.read_json(empty_buckets_json)
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
    def _save_userlist_report_csv(self):
        userlist_report_file = self.userlist_csv_folder + "userlist_report_files.csv"
        userlist_report_json = json.dumps([{
            "file_index": s3_file.file_index,
            "file_size": self.convert_size(s3_file.file_size),
            "bucket_name": s3_file.bucket_name,
            "s3_object_key": s3_file.s3_object_key,
            "file_date": s3_file.file_date
        } for s3_file in self.userlist_report_files])
        sum_df = pd.read_json(userlist_report_json)
        sum_df.to_csv(userlist_report_file, index=False, header=True)



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
        # timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        # print(f"{timestamp} - {message}", *args, **kwargs)
        print(f"{message}", *args, **kwargs)

def handler(event, context):
    aws_userlist_reports = AwsUserlistReports()
    aws_userlist_reports.etl_on_customer_userlist_s3_buckets("aws")
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return f"total reports: {str(aws_userlist_reports.file_count)}, start: {aws_userlist_reports.start}, end: {timestamp}, v:{sys.version} !"


#handler(None, None)
