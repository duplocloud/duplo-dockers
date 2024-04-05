import json
import os
import pandas as pd
import boto3
import sys
import shutil

class S3BillingFile:
    def __init__(self, bucket, filname):
        self.bucket_name = bucket
        self.s3_object_key = filname
        self.local_file_name = '/tmp/data/' + os.path.basename(filname)


class AwsBillingReports:

    def __init__(self):
        self.outFolder="/tmp"
        self.tempOutFolder = self.outFolder + "/reports_temp/"
        self.billingCsvFolder = self.outFolder + "/reports_combined/"
        self.destS3Bucket = "duplo-billing-reports"

    def createCsv(self, jsonfile):
        with open(jsonfile) as f:
            data = json.load(f)

        host = data["Host"]
        customer = data["CustomerName"]
        customerId = data["CustomerId"]
        awsAccountId = data["AwsAccountId"]
        monthlyData = data['data']['Monthly']
        monthlyBill = []
        servicesBill = []
        tenantsBill = []
        tenantsServiceBill = []
        for startDate in monthlyData:
            billingData = monthlyData[startDate]
            tenants = monthlyData[startDate]['Tenants']
            services = monthlyData[startDate]['Services']
            monthlyBill.append({
                'Customer': customer,
                'Host': host,
                'CustomerId': customerId,
                'AwsAccountId': awsAccountId,
                'StartDate': startDate,
                'Total': billingData['T'],
                'Weekly': json.dumps(billingData['W']),
                'Service': None,
                'Tenant': None,
                'Usage': billingData['Usage'],
                'Tax': billingData['Tax'],
                'Support': billingData['Support'],
                'Other': billingData['Other'],
            })
            self._processTenants(tenantsServiceBill, tenantsBill, startDate, tenants, customer, host, customerId,
                                 awsAccountId)
            self._processServices(servicesBill, startDate, services, customer, host, customerId, awsAccountId)

        # out/Clearstep/monthly.csv
        monthlyDf = pd.DataFrame(monthlyBill)
        monthlyDf = monthlyDf.filter(
            ['StartDate', 'Customer', 'Host', 'CustomerId', 'AwsAccountId', 'Total', 'Weekly', 'Usage', 'Tax',
             'Support', 'Other'])
        self._saveCsv(monthlyDf, "monthly.csv")

        # out/Clearstep/service.csv
        servicesBillDf = pd.DataFrame(servicesBill)
        servicesBillDf = servicesBillDf.filter(
            ['StartDate', 'Customer', 'Host', 'CustomerId', 'AwsAccountId', 'Total', 'Weekly', 'Service'])
        self._saveCsv(servicesBillDf, "service.csv")

        # out/Clearstep/tenant.csv
        tenantsBillDf = pd.DataFrame(tenantsBill)
        tenantsBillDf = tenantsBillDf.filter(
            ['StartDate', 'Customer', 'Host', 'CustomerId', 'AwsAccountId', 'Total', 'Weekly', 'Tenant'])
        self._saveCsv(tenantsBillDf, "tenant.csv")

        #  out/Clearstep/tenant-service.csv
        tenantsServiceBillDf = pd.DataFrame(tenantsServiceBill)
        tenantsServiceBillDf = tenantsServiceBillDf.filter(
            ['StartDate', 'Customer', 'Host', 'CustomerId', 'AwsAccountId', 'Total', 'Weekly', 'Service', 'Tenant'])
        self._saveCsv(tenantsServiceBillDf, "tenantService.csv")

        # out/Clearstep/billing-all.csv
        allBill = monthlyBill + tenantsBill + servicesBill + tenantsServiceBill
        allDf = pd.DataFrame(allBill)
        self._saveCsv(allDf, "billingAll.csv")

    def _saveCsv(self, df, csvName):
        tempfile = self.tempOutFolder + csvName
        combinedfile = self.billingCsvFolder +  csvName
        exists = os.path.exists(combinedfile)
        if (not exists):
            df.to_csv(combinedfile, index=False, header=True)
            print(combinedfile)
        else:
            df.to_csv(tempfile, index=False, header=False)
            with open(tempfile, 'r') as source_file, open(combinedfile, 'a') as destination_file:
                content = source_file.read()
                destination_file.write(content)

    def _processTenants(self, tenantsServiceBill, billing, startDate, tenants, customer,
                        host, customerId, awsAccountId):
        for tenant in tenants:
            billingData = tenants[tenant]
            services = tenants[tenant]['Services']
            billing.append({
                'Customer': customer,
                'Host': host,
                'CustomerId': customerId,
                'AwsAccountId': awsAccountId,
                'StartDate': startDate,
                'Total': billingData['T'],
                'Weekly': json.dumps(billingData['W']),
                'Service': None,
                'Tenant': tenant,
                'Usage': None,
                'Tax': None,
                'Support': None,
                'Other': None,
            })
            self._processServices(tenantsServiceBill, startDate, services, customer,
                                  host, customerId, awsAccountId, tenant)

    def _processServices(self, bill, startDate, services, customer, host, customerId, awsAccountId, tenant=None):
        for service in services:
            data = services[service]
            bill.append({'Customer': customer,
                         'Host': host,
                         'CustomerId': customerId,
                         'AwsAccountId': awsAccountId,
                         'StartDate': startDate,
                         'Total': data['T'],
                         'Weekly': json.dumps(data['W']),
                         'Service': service,
                         'Tenant': tenant,
                         'Usage': None,
                         'Tax': None,
                         'Support': None,
                         'Other': None,
                         })

    def upload_csv_files(self, uploadS3Folder):
        s3 = boto3.client('s3')
        for csv in os.listdir(self.billingCsvFolder):
            if csv.endswith(".csv"):
                print(csv)
                with open(self.billingCsvFolder + csv, "rb") as f:
                    s3.upload_fileobj(f, self.destS3Bucket, uploadS3Folder+"/"+csv)

    def create_etl_from_s3_buckets(self, uploadS3Folder):
        print("tempOutFolder ", self.tempOutFolder)
        print("billingCsvFolder", self.tempOutFolder)
        print("data", '/tmp/data/')
        self._recreateFolder(self.tempOutFolder)
        self._recreateFolder(self.billingCsvFolder)
        self._recreateFolder('/tmp/data/')
        s3FilePreFix = "data/billing-data-12months/last-12-months/"
        #s3FilePreFix = "data/billing/last-12months/"
        s3BucketPrefix = "duplo-analytics-"

        s3 = boto3.client('s3')
        response = s3.list_buckets()
        buckets = [bucket['Name'] for bucket in response['Buckets'] if bucket['Name'].startswith(s3BucketPrefix)]

        billing_data_files = []
        for bucket in buckets:
            paginator = s3.get_paginator('list_objects_v2')
            for page in paginator.paginate(Bucket=bucket):
                for obj in page.get('Contents', []):
                    filname = obj['Key']
                    if s3FilePreFix in filname:
                        billing_data_files.append(S3BillingFile(bucket, filname))
        for s3BillingFile in billing_data_files:
            self._processS3BillingFile(s3BillingFile)

        # upload
        self.upload_csv_files(uploadS3Folder)

    def _processS3BillingFile(self, s3BillingFile):
        print("_processS3BillingFile " + s3BillingFile.bucket_name
              + " " + s3BillingFile.s3_object_key + " "
              + s3BillingFile.local_file_name)
        s3 = boto3.client('s3')
        s3.download_file(s3BillingFile.bucket_name, s3BillingFile.s3_object_key, s3BillingFile.local_file_name)
        self.createCsv(s3BillingFile.local_file_name)


    def _recreateFolder(self, folder_path):
        try:
            print("Folder delete " + folder_path)
            shutil.rmtree(folder_path)
            print("Folder deleted successfully " + folder_path)
        except Exception as e:
            print(f"Error delete occurred: {e} " + folder_path)
        os.makedirs(folder_path, exist_ok=True)



def handler(event, context):
    awsBillingReports = AwsBillingReports()
    awsBillingReports.create_etl_from_s3_buckets("billingReports")
    return 'Hello from AWS Lambda using Python' + sys.version + '!'


handler(None, None)
