import json
import os
import pandas as pd

#pd.set_option('display.max_colwidth', None)
class AwsBillingReports:

    def __init__(self):
        pass

    def createCsv(self, customer, jsonfile, outfolder):
        outCustfolder = outfolder + "/" + customer
        os.makedirs(outCustfolder, exist_ok=True)
        os.makedirs(outCustfolder + "/json", exist_ok=True)
        with open(jsonfile) as f:
            data = json.load(f)
        # df = ((k, v) for k,v in monthly)
        # for key, value in json_dict.iteritems():
        monthlyData= data['Monthly']
        monthlyBill=[]
        servicesBill = []
        tenantsBill = []
        tenantsServiceBill = []
        for startDate in monthlyData:
            billingData = monthlyData[startDate]
            tenants = monthlyData[startDate]['Tenants']
            services = monthlyData[startDate]['Services']
            monthlyBill.append({'Customer':customer,
                              'StartDate': startDate,
                              'Total':billingData['T'],
                               'Weekly': json.dumps(billingData['W']),
                              'Service': None,
                              'Tenant': None,
                              'Usage': billingData['Usage'],
                              'Tax': billingData['Tax'],
                              'Support': billingData['Support'],
                              'Other': billingData['Other'],
                            })
            self._processTenants(tenantsServiceBill, tenantsBill, startDate, tenants, customer)
            self._processServices(servicesBill, startDate, services, customer)

        # out/Clearstep/monthly.csv
        monthlyDf = pd.DataFrame(monthlyBill)
        monthlyDf = monthlyDf.filter(['StartDate', 'Customer', 'Total', 'Weekly','Usage', 'Tax', 'Support', 'Other'])
        monthlyDf.to_csv(outCustfolder + "/monthly.csv", index=False)
        monthlyDf.to_json(outCustfolder + "/json/monthly.json", orient='records', lines=False, indent=4)

        # out/Clearstep/service.csv
        servicesBillDf = pd.DataFrame(servicesBill)
        servicesBillDf = servicesBillDf.filter(['StartDate', 'Customer', 'Total', 'Weekly', 'Service'])
        servicesBillDf.to_csv(outCustfolder + "/service.csv", index=False)
        servicesBillDf.to_json(outCustfolder + "/json/service.json", orient='records', lines=False, indent=4)

        # out/Clearstep/tenant.csv
        tenantsBillDf = pd.DataFrame(tenantsBill)
        tenantsBillDf = tenantsBillDf.filter(['StartDate', 'Customer', 'Total', 'Weekly', 'Tenant'])
        tenantsBillDf.to_csv(outCustfolder + "/tenant.csv", index=False)
        tenantsBillDf.to_json(outCustfolder + "/json/tenant.json", orient='records', lines=False, indent=4)

        #  out/Clearstep/tenant-service.csv
        tenantsServiceBillDf = pd.DataFrame(tenantsServiceBill)
        tenantsServiceBillDf = tenantsServiceBillDf.filter(['StartDate', 'Customer', 'Total', 'Weekly', 'Service', 'Tenant'])
        tenantsServiceBillDf.to_csv(outCustfolder + "/tenant-service.csv", index=False)
        tenantsServiceBillDf.to_json(outCustfolder + "/json/tenant-service.json", orient='records', lines=False, indent=4)

        # out/Clearstep/billing-all.csv
        allBill= monthlyBill + tenantsBill + servicesBill + tenantsServiceBill
        allDf = pd.DataFrame(allBill)
        allDf.to_csv(outCustfolder + "/billing-all.csv", index=False)
        allDf.to_json(outCustfolder + "/json/billing-all.json", orient='records', lines=False, indent=4)

    def _processTenants(self, tenantsServiceBill, billing, startDate, tenants, customer):
        for tenant in tenants:
            billingData = tenants[tenant]
            services = tenants[tenant]['Services']
            billing.append({'Customer':customer,
                              'StartDate': startDate,
                              'Total':billingData['T'],
                              'Weekly': json.dumps(billingData['W']),
                              'Service': None,
                              'Tenant': tenant,
                              'Usage': None,
                              'Tax':  None,
                              'Support':  None,
                              'Other':  None,
                            })
            self._processServices(tenantsServiceBill, startDate, services, customer, tenant)

    def _processServices(self, bill, startDate, services, customer, tenant=None):
        for service in services:
            data = services[service]
            bill.append({'Customer': customer,
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

# call for each cusotmer json
billingJson = AwsBillingReports()
billingJson.createCsv('qa-aws', './data/qa-aws-Aws-Monthly-Billing-file.json', "./out")
billingJson.createCsv('Clearstep', './data/Clearstep-Aws-Monthly-Billing-file.json', "./out")

