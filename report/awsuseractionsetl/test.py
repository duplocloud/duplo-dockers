from app import AwsUseractionsReports


def main():
    awsBillingReports = AwsUseractionsReports()
    awsBillingReports.etl_on_customer_billing_s3_buckets("billing-reports")
    return 'test Python!'

if __name__ == "__main__":
    main(None, None)
