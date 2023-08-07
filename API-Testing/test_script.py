import requests
import json

def run_tests():
    try:
        with open('api_tests.json', 'r') as file:
            api_tests = json.load(file)
    except Exception as e:
        print("Error loading API tests:", e)
        return
    
    for test in api_tests:
        api_request = test['data']
        expected_response = test['expected_response']

        try:
            response = requests.post("http://localhost:8080/2015-03-31/functions/function/invocations", json=api_request)
            response.raise_for_status()
            
            assert response.status_code == int(expected_response['statusCode'])
            assert response.text.strip() == expected_response['body'].strip()

            print(f"Test '{test['name']}' passed successfully!")
        except requests.RequestException as e:
            print(f"Request error for test '{test['name']}':", e)
        except AssertionError as e:
            print(f"Test '{test['name']}' failed:")
            print("Expected response:")
            print(json.dumps(expected_response, indent=4))
            print("Actual response:")
            print(json.dumps({
                'statusCode': response.status_code,
                'body': response.text.strip()
            }, indent=4))

if __name__ == "__main__":
    run_tests()
