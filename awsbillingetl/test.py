from app import AwsBillingReports


def main():
    awsBillingReports = AwsBillingReports()
    awsBillingReports._listS3Billingfiles()
    return 'test Python!'

if __name__ == "__main__":
    main(None, None)
