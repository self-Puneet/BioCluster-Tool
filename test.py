import requests
import json

def test_similarity_api():
    url = "http://127.0.0.1:5000/similarity"
    sample_sequences = [
        "AGCTAGCTAG",
        "AGCTTGCTAG",
        "AGCTAGGTAG"
    ]
    
    payload = {"sequences": sample_sequences}
    headers = {'Content-Type': 'application/json'}
    
    response = requests.post(url, data=json.dumps(payload), headers=headers)
    
    if response.status_code == 200:
        print("Similarity Matrix:")
        print(json.dumps(response.json(), indent=4))
    else:
        print("Error:", response.text)

if __name__ == "__main__":
    test_similarity_api()