import solr
import sys
import random
import csv

query = 'blob_ss:[* TO *]'
#link = 'https://blacklight-dev.ets.berkeley.edu/?f%5Bhasimages_s%5D%5B%5D=yes&f%5B{solr_field}%5D%5B%5D={search_key}&per_page=40&q=tea&search_field=text&view=masonry'
dimension = int(sys.argv[1])


museums = {'botgarden': ['botgarden-public', 'family_s', 'family_s,determination_s,accessionnumber_s', 'UC Botanical Garden'],
           'bampfa': ['bampfa-public', 'title_s', 'title_s,artistcalc_s,idnumber_s', 'BAM/PFA'],
           'cinefiles': ['cinefiles-public', 'doctitle_s', 'family_s,determination_s,accessionnumber_s','CineFiles'],
           'pahma': ['pahma-public', 'objname_s', 'objname_s,objcolldate_s,objmusno_s', 'Phoebe A. Hearst Museum of Anthropology'],
           'ucjeps': ['ucjeps-public', 'family_s', 'family_s,determination_s,accessionnumber_s', 'University and Jepson Herbaria']
           }

for museum in museums:
    core = museums[museum][0]
    solr_key_field = museums[museum][1]
    solr_fields = museums[museum][2]
    museum_name = museums[museum][3]

    with open(f'{museum}.static.csv', 'w') as f1:
        writer = csv.writer(f1, delimiter="|", quoting=csv.QUOTE_NONE, quotechar=chr(255))
        writer.writerow([museum])
        writer.writerow([museum_name])

        try:
            # create a connection to a solr server
            s = solr.SolrConnection(url='https://webapps.cspace.berkeley.edu/solr/%s' % core)

            # do a search
            response = s.query(query, rows=500)
            print(f'%s, records found: %s' % (core, response._numFound))

            # make a set of the different object names
            seen = {}
            for r in response.results:
                try:
                    seen[r[solr_key_field]] = r
                except:
                    pass
            try:
                x = random.sample(list(seen), dimension * dimension - 1)
            except:
                continue
            for h, z in enumerate(x):
                r = seen[z]
                result = []
                for field in solr_fields.split(','):
                    try:
                        result.append(r[field])
                    except:
                        result.append('')
                result.append(solr_key_field)
                result.append(r['blob_ss'][0])
                writer.writerow(result)
                print(h, result)

        except:
            raise
            print(f'could not access {core}.')
    f1.close()