import json, pprint, requests, textwrap
import os
import time

livy_ip = None
cwd = os.getcwd()
livy_ip="localhost"

print("livy_ip ", livy_ip)
host = "http://{0}:8998".format(livy_ip)


print( "1 ====================", host )
data = {'kind': 'spark'}
headers = {'Content-Type': 'application/json', 'X-Requested-By' : 'user' }
r = requests.post(host + '/sessions', data=json.dumps(data), headers=headers)
resp = r.json()
print(resp)

time.sleep(10)
location = r.headers['location']
session_url = host + r.headers['location']
print( "2 ====================", session_url )
r = requests.get(session_url, headers=headers)
resp2 = r.json()
pprint.pprint(r.json())
print( "END 2 ====================", session_url )

time.sleep(10)
statements_url = session_url + '/statements'
print( "3 ====================", statements_url )
data = {'code': '1 + 1'}
r = requests.post(statements_url, data=json.dumps(data), headers=headers)
resp3 = r.json()
pprint.pprint(r.json())
print( "END 3 ====================", statements_url )

time.sleep(10)
statement_url = host + location # r.headers['location']
print( "4 ====================", statement_url )
r = requests.get(statement_url, headers=headers)
resp4 = r.json()
pprint.pprint(r.json())
print( "END 4 ====================", statement_url )


statement_url = host + r.headers['location']
print( "5 ==================== PI ", statement_url )
data = {
  'code': textwrap.dedent("""
    val NUM_SAMPLES = 100000;
    val count = sc.parallelize(1 to NUM_SAMPLES).map { i =>
      val x = Math.random();
      val y = Math.random();
      if (x*x + y*y < 1) 1 else 0
    }.reduce(_ + _);
    println(\"Pi is roughly \" + 4.0 * count / NUM_SAMPLES)
    """)
}
r = requests.post(statements_url, data=json.dumps(data), headers=headers)
resp5 = r.json()
pprint.pprint(r.json())
print( "5 ==================== PI ", statement_url )

statement_url = host + r.headers['location']
print( "6==================== PI ", statement_url )
r = requests.get(statement_url, headers=headers)
resp6 = r.json()
pprint.pprint(r.json())
print( "END 6 ==================== PI ", statement_url )



