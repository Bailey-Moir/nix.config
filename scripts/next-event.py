from datetime import datetime
import os
import json

events = json.load(open(os.path.expanduser("~/.config/eww/events.json")))
for event in events:
    for key in ["start", "end"]:
        event[key + "Date"] = datetime.strptime(event[key], "%Y/%m/%d %I:%M%p")

nextEvent = {}
for event in events:
    if (
        datetime.now() <= event["startDate"] + (event["endDate"] - event["startDate"]) * 1 / 2
    ):  # until last half
        if nextEvent == {}:
            nextEvent = event
        else:
            if event["startDate"] < nextEvent["startDate"]:
                nextEvent = event

if nextEvent != {}:
    del nextEvent["startDate"]
    del nextEvent["endDate"]

    print(json.dumps(nextEvent), flush=True)
else:
    print("", flush=True)
    os.system("eww close event")
