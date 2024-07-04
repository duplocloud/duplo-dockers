import json
import os
import pandas as pd
from datetime import datetime

pd.set_option('display.max_colwidth', None)
class AwsBillingReportsFromCsv:

    def __init__(self):
        pass

    def convertDatetoiso(self, date_str):
        month_replacements = {
            "Jan": "01", "Feb": "02", "Mar": "03", "Apr": "04", "May": "05", "Jun": "06",
            "Jul": "07", "Aug": "08", "Sept": "09", "Sep": "09", "Oct": "10", "Nov": "11", "Dec": "12"
        }

        # Split the date string and correct the month abbreviation if necessary
        monthstr, year = date_str.split()
        month = month_replacements.get(monthstr)

        # Reassemble the corrected date string "YYYY-MM-DDTHH:MM:SS"
        corrected_date_str = f"{year}-{month}-01T00:00:00"
        return corrected_date_str
    def processCsv(self, customer, jsonfile, outfolder):
        outCustfolder = outfolder + "/" + customer
        os.makedirs(outCustfolder, exist_ok=True)
        os.makedirs(outCustfolder + "/json", exist_ok=True)
        df = pd.read_csv(jsonfile)
        df.rename(columns={df.columns[0]: "Service"}, inplace=True)
        df.rename(columns={df.columns[1]: "Empty"}, inplace=True)
        df.columns = df.columns
        df.drop(columns=['Empty'], inplace=True)

        monthly= {}
        services={}
        for index, row in df.iterrows():
            print(index, df.columns[0], row[0],  df.columns[1],  row[1])
            for col in range(1, len(df.columns) - 1):
                month =  self.convertDatetoiso(df.columns[col])
                if index < 4:
                        if month not in monthly:
                            monthly[month] = {"StartDate": month, "Customer": customer}
                        monthly[month][row[0]] = row[col]
                else:
                        if row[col] > 0:
                            services[month+"-"+row[0]] = {"StartDate": month, "Customer": customer, "Service": row[0], "Total": row[col]}
        #print("monthlyvals", json.dumps(list(monthly.values())))
        servicesVal = list(services.values())
        #print("servicesvals", json.dumps(servicesVal))

        servicesValuesDf = pd.DataFrame(servicesVal)
        servicesValuesDf = servicesValuesDf.sort_values(by='StartDate', ascending=False)
        servicesValuesDf.to_csv(outCustfolder + "/services.csv", index=False)
        servicesValuesDf.to_json(outCustfolder + "/json/services.json", orient='records', lines=False, indent=4)

        monthlyDf = pd.DataFrame(list(monthly.values()))
        monthlyDf = monthlyDf.sort_values(by='StartDate', ascending=False)
        monthlyDf.to_csv(outCustfolder + "/monthly.csv", index=False)
        monthlyDf.to_json(outCustfolder + "/json/monthly.json", orient='records', lines=False, indent=4)

# call for each cusotmer json
billingJson = AwsBillingReportsFromCsv()
billingJson.processCsv('Kamivision', './data/Kamivision-prod-Aws-Monthly-Billing.csv', "./out")
billingJson.processCsv('Guru', './data/Guru-Aws-Monthly-Billing.csv', "./out")

