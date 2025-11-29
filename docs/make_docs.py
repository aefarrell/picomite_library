import yaml
import sys
from jinja2 import Environment, FileSystemLoader
from os import walk
from os.path import abspath, dirname, isfile, join

def format_date(value, format):
    if format == "short":
        return value.strftime("%Y-%m-%d")
    elif format == "long":
        return value.strftime("%B %d, %Y")
    else:
        return value.strftime(format)

def retrieve_cards(directory):
    cards = []
    for path, folders, files in walk(directory):
        for filename in files:
            if filename == "read.me":
                with open(join(path, filename), 'r') as yml:
                    readme = yaml.safe_load(yml)
                
                program = join(path,readme.get('program',None))
                if isfile(program):
                    with open(program, 'r') as bas:
                        readme['code'] = bas.read()
                
                screenshot = join(path,readme.get('screenshot',None))
                if isfile(screenshot):
                    with open(screenshot, 'rb') as bmp:
                        image = bmp.read()
                    
                    outfile = readme.get('program')+'.bmp'
                    with open(join(output_dir,'images',outfile), 'wb') as outbmp:
                        outbmp.write(image)
                        readme['screenshot'] = outfile
                else:
                    readme['screenshot'] = None
                
                cards.append(readme)
    return cards

# find important directories
script_dir = dirname(abspath(sys.argv[0]))
output_dir = join(script_dir,'output')
template_dir = join(script_dir,'templates')

# walk the directory looking for 'read.me' files and associated '*.bas' files
root_dir = dirname(script_dir)
categories = [ 'math', 'art', 'utils', 'toys' ]
cards = { cat:retrieve_cards(join(root_dir,cat)) for cat in categories }

# load templates and generate the html files
environment = Environment(loader=FileSystemLoader(template_dir),
                          extensions=['jinja2.ext.loopcontrols'])
environment.filters['format_date'] = format_date

filename = 'index.html'
index = environment.get_template("index.html")
content = index.render({ 'cards': cards })
with open(join(output_dir,filename), mode="w", encoding="utf-8") as fout:
    fout.write(content)

progfile = environment.get_template("program.html")
for category in categories:
    for card in cards[category]:
        filename = card['program'] + '.html'
        content = progfile.render({'program': card})
        with open(join(output_dir,filename), mode="w", encoding="utf-8") as fout:
            fout.write(content)
        
    
    
