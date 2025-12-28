from jinja2 import Environment, FileSystemLoader
from pathlib import Path
from sys import argv

import yaml


def format_date(value, fmt):
    if fmt == "short":
        return value.strftime("%Y-%m-%d")
    elif fmt == "long":
        return value.strftime("%B %d, %Y")
    else:
        return value.strftime(fmt)

def retrieve_cards(directory):
    cards = []
    for root, dirs, files in Path.walk(directory):
        for file in files:
            if file == "read.me":
                rme = (root/file).resolve()
                with rme.open('r') as yml:
                    readme = yaml.safe_load(yml)
                    program_file = readme.get('program',None)
                    program_full = (root/program_file).resolve()
                    if program_full.is_file():
                        with program_full.open('r') as bas:
                            readme['code'] = bas.read()
                    
                    relpath = program_full.relative_to(root_dir,walk_up=True).as_posix()
                    readme['url'] = root_url+relpath
                
                screenshot = (root/readme.get('screenshot',None)).resolve()
                if screenshot.is_file():
                    destination = output_dir/'images'/screenshot.name
                    screenshot.copy(destination)
                    readme['screenshot'] = 'images/' + screenshot.name
                else:
                    readme['screenshot'] = None
                
                cards.append(readme)
    return cards

# find important directories
script_dir = Path(argv[0]).parent.resolve()
output_dir = script_dir/'output'
template_dir = script_dir/'templates'

# walk the directory looking for 'read.me' files and associated '*.bas' files
root_dir = script_dir.parent
root_url='https://github.com/aefarrell/picomite_library/blob/main'
categories = [ 'art', 'math', 'toys', 'utils' ]
cards = { cat:retrieve_cards(root_dir/cat) for cat in categories }

# load templates and generate the html files
environment = Environment(loader=FileSystemLoader(template_dir),
                          extensions=['jinja2.ext.loopcontrols'])
environment.filters['format_date'] = format_date

filename = 'index.html'
index = environment.get_template("index.html")
content = index.render({ 'cards': cards })
with open((output_dir/filename), mode="w", encoding="utf-8") as fout:
    fout.write(content)

progfile = environment.get_template("program.html")
for category in categories:
    for card in cards[category]:
        filename = card['program'] + '.html'
        content = progfile.render({'program': card})
        with open((output_dir/filename), mode="w", encoding="utf-8") as fout:
            fout.write(content)
        
    
    
