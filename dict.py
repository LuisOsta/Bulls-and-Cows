import requests
import json


def two_same(string):
  for i in range(len(string)-1):
    if string.count(string[i])>1:
         return True
  return False
#File i/o
file = open('dictionary.txt', 'w')

# TODO: replace with your own app_id and app_key
app_id = '8325d9e7'
app_key = 'fd8d942324121e4a11f8f733847483d9'
language = 'en'
word_id = 'Ace'
url = 'https://od-api.oxforddictionaries.com:443/api/v1/wordlist/'+language+'/lexicalCategory%3Dnoun%2Cadjective?word_length=4'
#url Normalized frequency

r = requests.get(url, headers = {'app_id' : app_id, 'app_key' : app_key})
print("code {}\n".format(r.status_code))

# grabs the results resonse list, turns it into a json object then into a python list
results = json.loads(json.dumps(r.json()["results"]))

for i in range(len(results)):
  string = results[i]['word'].encode('utf-8').strip()
  if(two_same(string)==True):
    continue

  if(i+1==len(results)):
    print("Result: "+str(results[i]))
    file.write(string)
  else:
    print("Result: "+str(results[i])+"\n")
    file.write(string+'\n')

