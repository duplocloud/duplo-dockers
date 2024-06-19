import datetime
import json
import os
import pandas as pd
import boto3
import sys
import shutil
from io import StringIO
from datetime import datetime, timedelta

class AnalyticsS3File:
    def __init__(self, index, bucket_name, file_name, file_size, file_date, data_folder):
        self.index = index
        self.bucket_name = bucket_name
        self.file_name = os.path.basename(file_name)
        self.s3_object_key = file_name
        self.file_size = file_size
        self.last_modified = file_date.strftime('%Y-%m-%d %H:%M:%S')
        self.file_date = file_date
        self.local_file_name = data_folder + str(index) + "-" + os.path.basename(file_name)
        print(self.index, self.local_file_name, "size", file_size, "file_date", file_date, "bucket", bucket_name, "s3-file", self.s3_object_key)

class DuploAwsAnalyticsEtl:

    def __init__(self):
        # event
        self.event="userlist"
        self.s3_dest_sub_folder = "segment"

        # src s3
        self.s3_src_file_prefix = "data/" + self.event + "/" + self.s3_dest_sub_folder
        self.s3_src_bucket_prefix = "duplo-analytics-"
        # dest s3
        self.dest_s3_bucket = "duplo-" + self.event + "-reports"
        self.s3_dest_file_prefix = "data/" + self.s3_dest_sub_folder
        self.s3_dest_reports_folder = "reports/"

        self.file_count = self.file_max_count = 10000000
        self.file_count = 0
        self.out_folder = "/tmp/" + self.event
        self.temp_out_folder = self.out_folder + "/reports_temp/"
        self.analytics_event_csv_folder = self.out_folder + "/reports_combined/"
        self.data_folder = self.out_folder + "/data/"
        self.start = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.s3_client = boto3.client('s3')
        self.analytics_event_report_files = []
        self.empty_buckets = []


    def etl_on_customer_analytics_event_s3_buckets(self ):

        self.cleanup_events_cutoff_date = datetime.now() - timedelta(days=3)

        # log
        self._log(self.file_count, "temp_out_folder ", self.temp_out_folder)
        self._log(self.file_count, "analytics_event_csv_folder", self.temp_out_folder)
        self._log(self.file_count, "data_folder", self.data_folder)

        # recreate_local_folder
        self.recreate_local_folder(self.temp_out_folder)
        self.recreate_local_folder(self.analytics_event_csv_folder)
        self.recreate_local_folder(self.data_folder)

        # list_buckets
        try:
            print(f"start self._do_etls()")
            self._do_etls()
            print(f"done self._do_etls()")
        except Exception as e:
            print(f"Error self._do_etls(): {str(e)}")

        # save empty buckets
        try:
            print(f"start  self._save_analytics_event_report_csv()")
            self._save_analytics_event_report_csv()
            print(f"done  self._save_analytics_event_report_csv()")
        except Exception as e:
            print(f"Error  self._save_analytics_event_report_csv(): {str(e)}")

        # save processed files
        try:
            print(f"start  self._save_empty_buckets_csv()")
            self._save_empty_buckets_csv()
            print( f"done  self._save_empty_buckets_csv()")
        except Exception as e:
            print(f"Error  self._save_empty_buckets_csv(): {str(e)}")

        # Upload csvs
        try:
            print("start upload_s3_folder")
            self._upload_csv_files()
            print(f"done  self.upload_csv_files()")
        except Exception as e:
            print(f"Error self.upload_csv_files(): {str(e)}")



    def _do_etls(self):
        response = self.s3_client.list_buckets()
        buckets = [bucket['Name'] for bucket in response['Buckets'] if
                   bucket['Name'].startswith(self.s3_src_bucket_prefix)]
        for bucket in buckets:
            paginator = self.s3_client.get_paginator('list_objects_v2')
            for page in paginator.paginate(Bucket=bucket):
                self._log(self.file_count, "bucket", bucket)
                if len(page.get('Contents', [])) == 0:
                    self.empty_buckets.append(bucket)
                for obj in page.get('Contents', []):
                    file_name = obj['Key']
                    file_size = obj['Size']
                    file_date = obj['LastModified']
                    if self.s3_src_file_prefix in file_name and "json" in file_name:
                        print("found s3 event file_name ", file_name)
                        self.file_count += 1
                        s3_analytics_event_file = AnalyticsS3File(self.file_count, bucket, file_name, file_size,
                                                                  file_date, self.data_folder)
                        self._process_s3_analytics_event_file(s3_analytics_event_file)
                        self.analytics_event_report_files.append(s3_analytics_event_file)

    def _process_s3_analytics_event_file(self, s3_analytics_event_file):
        dest_s3_object_key = "data/" + self.s3_dest_sub_folder + "/" + s3_analytics_event_file.file_name
        src_s3_object_key = s3_analytics_event_file.bucket_name + "/" + s3_analytics_event_file.s3_object_key
        self._log(s3_analytics_event_file.index,
                  "_process_s3_analytics_event_file "
                  + " src: " + src_s3_object_key
                  + " dest: " + dest_s3_object_key)
        try:
            copy_source = {
                'Bucket': s3_analytics_event_file.bucket_name,
                'Key': s3_analytics_event_file.s3_object_key
            }
            self.s3_client.copy_object(CopySource=src_s3_object_key, Bucket=self.dest_s3_bucket, Key=dest_s3_object_key)
            print(f"File copied successfully from {s3_analytics_event_file.bucket_name}/{s3_analytics_event_file.s3_object_key} to {self.dest_s3_bucket}/{dest_s3_object_key}")
        except Exception as e:
            print(f"Error copying file: {str(e)}")

    def _save_empty_buckets_csv(self):
        empty_buckets_file = self.analytics_event_csv_folder + "aws_events_analytics_empty_buckets.csv"
        empty_buckets_json = json.dumps([{
            "bucket": bucket
        } for bucket in self.empty_buckets])
        sum_df = pd.read_json(StringIO(empty_buckets_json))
        sum_df.to_csv(empty_buckets_file, index=False, header=True)

    def _save_analytics_event_report_csv(self):
        analytics_event_report_file = self.analytics_event_csv_folder + "aws_events_analytics_report_files.csv"
        if len( self.analytics_event_report_files) > 0 :
            analytics_event_report_json = json.dumps([{
                "file_index": s3_file.index,
                "file_size": self.convert_size(s3_file.file_size),
                "bucket_name": s3_file.bucket_name,
                "s3_object_key": s3_file.s3_object_key,
                "last_modified": s3_file.last_modified
            } for s3_file in self.analytics_event_report_files])
            sum_df = pd.read_json(StringIO(analytics_event_report_json))
            sum_df.to_csv(analytics_event_report_file, index=False, header=True)

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

    def _upload_csv_files(self):
        for csv_file in os.listdir(self.analytics_event_csv_folder):
            if csv_file.endswith(".csv"):
                file_path = self.analytics_event_csv_folder + csv_file
                file_stats = os.stat(file_path)
                file_size = f"{round(file_stats.st_size / 1024)} kB"
                self._log(self.file_count, "csv", file_path, "fileSize", file_size)
                with open(file_path, "rb") as f:
                    self.s3_client.upload_fileobj(f, self.dest_s3_bucket, self.s3_dest_reports_folder + csv_file)

    def convert_size(self, bytes):
        kb = bytes / 1024
        mb = kb / 1024
        if mb >= 1:
            return f"{mb:.2f} MB"
        elif kb >= 1:
            return f"{kb:.2f} KB"
        else:
            return f"{bytes} bytes"

    def _log(self, message, *args, **kwargs):
        # timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        # print(f"{timestamp} - {message}", *args, **kwargs)
        print(f"{message}", *args, **kwargs)

def handler(event, context):
    aws_analytics_event_reports = DuploAwsAnalyticsEtl()
    aws_analytics_event_reports.etl_on_customer_analytics_event_s3_buckets()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return f"total reports: {str(aws_analytics_event_reports.file_count)}, start: {aws_analytics_event_reports.start}, end: {timestamp}, v:{sys.version} !"


#handler(None, None)
