import csv, sys


file = sys.argv[1]

#server = 'http://52.27.150.123:3000'


template = '''<td class="splash_td">
<a href="%s">
<div class="thumb" style="background-image: url('%s');" title=""></div></a>
<br/><b><a class="fr" href="%s">%s</a></b>
<!-- a class="fr" href="%s">%s</a -->
</td>'''

topbits = '''
<style>
.grid {padding: 12px; }
.splash_td {padding: 12px; background-color: light-gray; width: 230px; vertical-align: top;}
.splash_img {max-width:280px; padding: 0px 4px 4px 0px; }
.fr {float: right;}
.thumb {
    display: inline-block;
    width: 200px;
    height: 200px;
    margin: 2px;
    background-position: center center;
    background-size: cover;
}
</style>
<table>
<tr class="grid">
<td class="splash_td">
<h4 class='section-heading'>Explore the TENANT's collections</h4>
<p>
The TENANT cares for a vast and diverse collection. Enter a few interesting words for places, dates, people, or things in the search box above;
select one of the facets on the left to refine your search; or choose a featured collection on the right.
</p>
</td>
'''

dimension = 4
with open(file, 'r') as f1:
    reader = csv.reader(f1, delimiter="|", quoting=csv.QUOTE_NONE, quotechar=chr(255))
    n = 1
    tenant = next(reader)[0].strip()
    museum_name = next(reader)[0].strip()
    print(topbits.replace('TENANT', museum_name))
    for lineno, row in enumerate(reader):
        if len(row) < 4: continue
        search, caption, objno, search_field, image = row
        original = image
        musno = ''
        search_template = f'/?f[{search_field}][]={search}&per_page=30&search_field=advanced&view=index'
        # https://webapps.cspace.berkeley.edu/pahma/imageserver/blobs/67c7ea97-123f-4f4a-99d5/derivatives/Medium/content
        image = f'https://webapps.cspace.berkeley.edu/{tenant}/imageserver/blobs/{image}/derivatives/Medium/content'
        filled_in = template % (search_template,image,search_template,caption + ' >',search,musno)
        if n == dimension:
            print('<tr class="grid">')
            n = 0
        n = n + 1
        print(filled_in)

print('</table>')
