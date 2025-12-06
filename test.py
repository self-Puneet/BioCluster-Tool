import requests

url = "http://biocluster.nexiotech.cloud/similarity"

payload = {
    "sequences": ["ATCG", "ATCC", "ATGG", "ATGC"]
}

resp = requests.post(url, json=payload)
print(resp.status_code)
print(resp.text)
