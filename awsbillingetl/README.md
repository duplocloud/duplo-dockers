
# install 

## install prerequisite  
* tested with python 10 

## install requirements  
* install requirments and generate reports.
```bash
pip install -r requirments.txt
python aws-billing-reports.py
```


## Generated CSV reports 

* (Latest build) create useful csv reports from billing json, which can be further analysed
``` python

billingJson = AwsBillingReports()
billingJson.createCsv('qa-aws', './data/qa-aws-Aws-Monthly-Billing-file.json', "./out")
billingJson.createCsv('Clearstep', './data/Clearstep-Aws-Monthly-Billing-file.json', "./out")
...

```
## monthly billing for last 12+ months
* out/qa-aws/monthly.csv
* out/qa-aws/json/monthly.json
``` csv
StartDate,Customer,Total,Weekly,Usage,Tax,Support,Other
2023-03-01T00:00:00,qa-aws,744.0684083297,"[6.2993469695, 159.20569140049997, 214.38585076499956, 192.21772460570028, 171.9597945889997]",744.0684083297,0,0,0
```
```json 
[
    {
        "StartDate":"2023-03-01T00:00:00",
        "Customer":"qa-aws",
        "Total":744.0684083297,
        "Weekly":"[6.2993469695, 159.20569140049997, 214.38585076499956, 192.21772460570028, 171.9597945889997]",
        "Usage":744.0684083297,
        "Tax":0,
        "Support":0,
        "Other":0
    }
  ]
    
```

* monthly 'service' billing for last 12+ months
  * out/qa-aws/service.csv
  * out/qa-aws/json/service.json
```csv
StartDate,Customer,Total,Weekly,Service
2023-03-01T00:00:00,qa-aws,49.37,"[1.23, 3.37, 13.59, 16.810000000000002, 14.37]",AWS Cost Explorer
```
```json
[
    {
        "StartDate":"2023-03-01T00:00:00",
        "Customer":"qa-aws",
        "Total":49.37,
        "Weekly":"[1.23, 3.37, 13.59, 16.810000000000002, 14.37]",
        "Service":"AWS Cost Explorer"
    }
]    
```
* monthly 'tenant' billing for last 12+ months
  * out/qa-aws/tenant.csv
  * out/qa-aws/json/tenant.json
```csv 
StartDate,Customer,Total,Weekly,Tenant
2023-03-01T00:00:00,qa-aws,423.4303546396,"[6.2301743671, 86.60622633759998, 125.37037051989994, 114.66043959439999, 90.56314382059999]",shared
```
```json 
[
    {
        "StartDate":"2023-03-01T00:00:00",
        "Customer":"qa-aws",
        "Total":423.4303546396,
        "Weekly":"[6.2301743671, 86.60622633759998, 125.37037051989994, 114.66043959439999, 90.56314382059999]",
        "Tenant":"shared"
    }
]
```
* monthly 'service' per 'tenant' billing for last 12+ months
  * out/qa-aws/tenant-service.csv
  * out/qa-aws/json/tenant-service.json
```csv 
StartDate,Customer,Total,Weekly,Service,Tenant
2023-03-01T00:00:00,qa-aws,49.37,"[1.23, 3.37, 13.59, 16.810000000000002, 14.37]",AWS Cost Explorer,shared
```

```json 
[
    {
        "StartDate":"2023-03-01T00:00:00",
        "Customer":"qa-aws",
        "Total":49.37,
        "Weekly":"[1.23, 3.37, 13.59, 16.810000000000002, 14.37]",
        "Service":"AWS Cost Explorer",
        "Tenant":"shared"
    }
]
```


 