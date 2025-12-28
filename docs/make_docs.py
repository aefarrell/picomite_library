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
    for root, _, files in Path.walk(directory):
        for file in filter(lambda x: x == "read.me", files):
            yml = (root/file).resolve().read_text()
            readme = yaml.safe_load(yml)
            program_file = readme.get('program',None)
            program_full = (root/program_file).resolve()
            if program_full.is_file():
                readme['code'] = program_full.read_text()
            
            relpath = program_full.relative_to(root_dir,walk_up=True).as_posix()
            readme['url'] = root_url + "/" + relpath
            
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

index_tmpl = environment.get_template("index.html")
content = index_tmpl.render({ 'cards': cards })
index_out = (output_dir/'index.html')
index_out.touch()
index_out.write_text(content, encoding="utf-8")

progfile = environment.get_template("program.html")
for category in categories:
    for card in filter(lambda x: x.get('program',None) is not None, cards[category]):
        filename = card['program'] + '.html'
        content = progfile.render({'program': card})
        file = (output_dir/filename)
        file.touch()
        file.write_text(content, encoding="utf-8")
        
    
    
