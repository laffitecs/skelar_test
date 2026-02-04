import requests
import json
import os
from datetime import datetime, timedelta


def fetch_exchange_rates(date_str=None):
    if date_str:
        url = f'https://openexchangerates.org/api/historical/{date_str}.json'
    else:
        url = 'https://openexchangerates.org/api/latest.json'

    params = {'app_id': 'fbc3a4fce7f9404f9eb8c7efa8f01a15'}
    response = requests.get(url, params=params)

    if response.status_code == 200:
        data = response.json()
        return data
    return None

data = fetch_exchange_rates()
print(data)


















