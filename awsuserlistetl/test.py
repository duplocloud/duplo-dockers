from app import AwsBillingReports


def main():
    awsBillingReports = AwsBillingReports()
    awsBillingReports.etl_on_customer_billing_s3_buckets("billing-reports")
    return 'test Python!'

if __name__ == "__main__":
    main(None, None)
