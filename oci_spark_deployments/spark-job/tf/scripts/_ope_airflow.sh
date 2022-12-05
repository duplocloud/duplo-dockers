
export airflowenv="duploservices-demo01-airflow1"
open $(aws mwaa create-web-login-token --name  $airflowenv --profile duplo-jsr | jq '"https://"+ .WebServerHostname + "/aws_mwaa/aws-console-sso?login=true#" + .WebToken ' \
| echo https://$WebServerHostname/aws_mwaa/aws-console-sso?login=true#${WebToken})

export airflowenv="duploservices-demo01-airflow1"
open $(aws mwaa create-web-login-token --name  $airflowenv --profile duplo-jsr | jq '"https://"+ .WebServerHostname + "/aws_mwaa/aws-console-sso?login=true#" + .WebToken ' \
| echo )


export airflowenv=""
open $(aws mwaa create-web-login-token --name  duploservices-demo01-airflow1 --profile duplo-jsr | jq '"https://"+ .WebServerHostname + "/aws_mwaa/aws-console-sso?login=true#" + .WebToken ' )



open $airflow


aws mwaa create-web-login-token --name  duploservices-demo01-airflow1 --profile duplo-jsr --query '{tkn:WebToken,host:WebServerHostname}'

'Volumes[*]'
export duplo_token="AQAAANCMnd8BFdERjHoAwE_Cl-sBAAAAQk4I8I2z4E-VPI4m6Vb5hgAAAAACAAAAAAAQZgAAAAEAACAAAABY1Kiak9zMi4whTa4KK3AmTY6d7H2XmaWPgZT4ve7PXwAAAAAOgAAAAAIAACAAAABiA0wg-06YaRAGB1oKDH27z6F2kl5fwUmiQTIwPaUzFKAAAADdSu0BtjoM9L0KPv-6_JGq-GLGkafDsm1OdhtzyyLkO_XvhiGeSZaqj35qju-5hgRf2W6KAvw27ZoZB1ZjRz56XULgn17-WZMUKlXvuT7urCX8pO_ALetU5EIVoYbJm6SkIEQdBDlqgGXsVIuh338tyhN-SrUVCC7M1vYnHAmDVjzyydEm8UpmwsYvJt93szWAhxdSRIyZbfTzjAWNy4v-QAAAAOd3IihzEBHFlXiCW5C25PD1zwiYXg0OERZcTAG8z7KUhBd-7sR2Th_bn2ze3oyTagdSklreGNQkk7CO9tXcFzY"
export duplo_host="https://ia.duplocloud.net"
export tokenpath="adminproxy/GetJITAwsConsoleAccessUrl"

curl -Ssf -H 'Content-type: application/json' \
 -H "Authorization: Bearer $duplo_token" "${duplo_host}/${path}"
# \
#  | jq -r '{AWS_ACCESS_KEY_ID: .AccessKeyId, AWS_SECRET_ACCESS_KEY: .SecretAccessKey, AWS_REGION: .Region, AWS_DEFAULT_REGION: .Region, AWS_SESSION_TOKEN: .SessionToken} | to_entries | map("\(.key)=\(.value)") | .[]'


webServerHostName = response["WebServerHostname"]
webToken = response["WebToken"]
airflowUIUrl = 'https://{0}/aws_mwaa/aws-console-sso?login=true#{1}'.format(webServerHostName, webToken)
