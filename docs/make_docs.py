import yaml
import os
import sys
from jinja2 import Environment, FileSystemLoader
from os import listdir
from os.path import isfile, join

def format_date(value, format):
    if format == "short":
        return value.strftime("%Y-%m-%d")
    elif format == "long":
        return value.strftime("%B %d, %Y")
    else:
        return value.strftime(format)

contents = { 'cards' : [ {'title': 'test 1',
                        'date': '2025-11-25',
                        'description': 'the first test',
                        'code': 'lorem ipsum'},
                         {'title': 'test 2' ,
                        'date': '2025-10-01',
                        'description': 'the second test',
                        'code': 'dolor esset'},
                        {'title': 'test 3',
                        'date': '2025-09-01',
                        'description': 'the third test',
                        'code': 'hmmm'},
                       ]
            }

script_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
output_dir = join(script_dir,'output')
template_dir = join(script_dir,'templates')

environment = Environment(loader=FileSystemLoader(template_dir),
                          extensions=['jinja2.ext.loopcontrols'])
environment.filters['format_date'] = format_date

filename = 'index.html'
with open(join(output_dir,filename), mode="w", encoding="utf-8") as fout:
    html = environment.get_template("index.html")
    content = html.render(contents)
    fout.write(content)
