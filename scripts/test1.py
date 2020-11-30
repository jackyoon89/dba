#!/usr/bin/env python
import json
import requests
import slackweb

slack = slackweb.Slack(url = "https://hooks.slack.com/services/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")
#slack.notify(text = "Sending message to slack from db01.dev.ny1")
slack.notify(text = "Sending another message to slack from db01.dev.ny1", channel="#dba", username="DB-bot", icon_emoji=":robot_face:")

