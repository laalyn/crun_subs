from sys import argv
from ass import parse
from json import dumps
from re import sub

input_path = argv[1]
output_path = argv[2]

with open(input_path) as subs:
  doc = parse(subs)

  payload = {
    'events': []
  }

  for e in doc.events:
      event = ' '.join(e.text.replace('\\N', ' ').split())
      payload['events'].append(sub(r'\{.*?\}', '', event))
  
  with open(output_path, 'w') as out:
    out.write(dumps(payload))

