
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
export duplo_token="xxx"
export duplo_host="https://xxx.duplocloud.net"
export tokenpath="adminproxy/GetJITAwsConsoleAccessUrl"

curl -Ssf -H 'Content-type: application/json' \
 -H "Authorization: Bearer $duplo_token" "${duplo_host}/${path}"
# \
#  | jq -r '{AWS_ACCESS_KEY_ID: .AccessKeyId, AWS_SECRET_ACCESS_KEY: .SecretAccessKey, AWS_REGION: .Region, AWS_DEFAULT_REGION: .Region, AWS_SESSION_TOKEN: .SessionToken} | to_entries | map("\(.key)=\(.value)") | .[]'


webServerHostName = response["WebServerHostname"]
webToken = response["WebToken"]
airflowUIUrl = 'https://{0}/aws_mwaa/aws-console-sso?login=true#{1}'.format(webServerHostName, webToken)
