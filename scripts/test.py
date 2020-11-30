#!/usr/bin/env python
import json
import requests

webhook_url = 'https://hooks.slack.com/services/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'
slack_data = {'text': "Test message from db01.dev.ny1"}

response = requests.post(
    webhook_url, data=json.dumps(slack_data),
    headers={'Content-Type': 'application/json'}
)

if response.status_code != 200:
    raise ValueError(
        'Request to slack returned an error %s, the response is:\n%s'
        % (response.status_code, response.text)
    )
