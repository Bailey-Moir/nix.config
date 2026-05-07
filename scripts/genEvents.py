#!/usr/bin/env python
# RUN DAILY BY SYSTEMD
import os
import re
from selenium import webdriver
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.firefox.options import Options
from bs4 import BeautifulSoup
from datetime import datetime
import time
import json

profile_path = "/home/charps/.mozilla/firefox/0l0il7dn.default-release"

options = Options()
options.add_argument("-headless")
options.profile = profile_path
service = Service("/usr/bin/geckodriver")

driver = webdriver.Firefox(service=service, options=options)
driver.get("https://calendar.google.com/calendar/u/0/r/day")

time.sleep(3)

soup = BeautifulSoup(driver.page_source, "html.parser")
driver.quit()

source = str(soup.select('div[jsname="ff2wFe"]'))
matches: list[str] = re.findall(
    r"(\d{1,2}(?::\d\d)?[a,p]m to \d{1,2}(?::\d\d)?[a,p]m[^<]*)", source
)
print(matches)

events = []
for match in matches:
    event = {}
    i1 = match.find(",")
    event["startStr"], event["endStr"] = match[0:i1].split(" to ")
    for key in ["startStr", "endStr"]:
        if event[key].find(":") == -1:
            event[key] = event[key][:-2] + ":00" + event[key][-2] + "m"
        if len(event[key]) == 6:
            event[key] = "0" + event[key]

    i2 = match.find(", Calendar: ", i1 + 2)
    if i2 == -1:
        i2 = match.find(", Personal", i1 + 2)
    event["name"] = match[i1 + 2 : i2]

    i3 = match.find(", Location: ", i2 + 1)
    if i3 != -1:
        i4 = match.find(", ", i3 + 1)
        event["location"] = match[i3 + 12 : i4]
    else:
        event["location"] = ""

    today = datetime.today().date()
    for prefix in ["start", "end"]:
        event[prefix] = datetime.combine(
            today, datetime.strptime(event[prefix + "Str"], f"%I:%M%p").time()
        ).strftime("%Y/%m/%d %I:%M%p")

    del event["startStr"]
    del event["endStr"]

    # if datetime.now() > event['start'] + (event['end']- event['start'])*3/4: # until last quater
    events.append(event)

os.system("~/.config/scripts/eww-open.sh event")
json.dump(events, open("/home/charps/.config/eww/events.json", "w"))
