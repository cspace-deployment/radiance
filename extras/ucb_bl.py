# set global variables

# nb: this script now requires python3

import csv
from os import path, popen, sys
import json


def getParms(parmFile, prmz):
    try:
        f = open(parmFile, 'r')
        csvfile = csv.reader(f, delimiter="\t")
    except IOError:
        raise
        message = 'Expected to be able to read %s, but it was not found or unreadable' % parmFile
        return message, -1
    except:
        raise

    try:
        rows = []
        for row, values in enumerate(csvfile):
            rows.append(values)

        f.close()

        return parseRows(rows, prmz)

    except IOError:
        message = 'Could not read (or maybe parse) rows from %s' % parmFile
        return message, -1
    except:
        raise


def parseRows(rows, prmz):
    prmz.PARMS = {}
    prmz.HEADER = {}
    labels = {}
    prmz.FIELDS = {}
    prmz.DEFAULTSORTKEY = 'None'

    prmz.SEARCHCOLUMNS = 0
    prmz.SEARCHROWS = 0
    prmz.CSRECORDTYPE = 'cataloging'  # default

    prmz.LOCATION = ''
    prmz.DROPDOWNS = []

    functions = 'Search,Facet,bMapper,listDisplay,fullDisplay,gridDisplay,mapDisplay,inCSV'.split(',')
    for function in functions:
        prmz.FIELDS[function] = []

    fieldkeys = 'label fieldtype suggestions solrfield name X order searchtarget'.split(' ')

    for rowid, row in enumerate(rows):
        rowtype = row[0]

        if rowtype == 'header':
            for i, r in enumerate(row):
                prmz.HEADER[i] = r
                labels[r] = i

        elif rowtype == 'server':
            prmz.SOLRSERVER = row[1]

        elif rowtype == 'csrecordtype':
            prmz.CSRECORDTYPE = row[1]

        elif rowtype == 'core':
            prmz.SOLRCORE = row[1]

        elif rowtype == 'title':
            prmz.TITLE = row[1]

        elif rowtype == 'field':

            needed = [row[labels[i]] for i in 'Label Role Suggestions SolrField Name Search SearchTarget'.split(' ')]
            if row[labels['Suggestions']] != '':
                # suggestname = '%s.%s' % (row[labels['Suggestions']], row[labels['Name']])
                suggestname = row[labels['Name']]
            else:
                suggestname = row[labels['Name']]
            needed[4] = suggestname
            prmz.PARMS[suggestname] = needed
            needed.append(rowid)
            if 'sortkey' in row[labels['Role']]:
                prmz.DEFAULTSORTKEY = row[labels['SolrField']]

            for function in functions:
                if len(row) > labels[function] and row[labels[function]] != '':
                    fieldhash = {}
                    for n, v in enumerate(needed):
                        if n == 5 and function == 'Search':  # 5th item in needed is search field x,y coord for layout
                            if v == '':
                                continue
                            searchlayout = (v + ',1').split(',')
                            fieldhash['column'] = int('0' + searchlayout[1])
                            fieldhash['row'] = int('0' + searchlayout[0])
                            prmz.SEARCHCOLUMNS = max(prmz.SEARCHCOLUMNS, int('0' + searchlayout[1]))
                            prmz.SEARCHROWS = max(prmz.SEARCHROWS, int('0' + searchlayout[0]))
                        else:
                            fieldhash[fieldkeys[n]] = v
                    fieldhash['order'] = int(row[labels[function]].split(',')[0])
                    fieldhash['style'] = ''  # temporary hack!
                    fieldhash['type'] = 'text'  # temporary hack!
                    prmz.FIELDS[function].append(fieldhash)

                prmz.FIELDS[function] = sorted(prmz.FIELDS[function], key=lambda x: x['order'])

    if prmz.SEARCHROWS == 0: prmz.SEARCHROWS = 1
    if prmz.SEARCHCOLUMNS == 0: prmz.SEARCHCOLUMNS = 1

    for p in prmz.PARMS:
        if 'dropdown' in prmz.PARMS[p][1]:
            prmz.DROPDOWNS.append(prmz.PARMS[p][4])
        if 'location' in prmz.PARMS[p][1]:
            prmz.LOCATION = prmz.PARMS[p][3]

    prmz.FACETS = [f['solrfield'] for f in prmz.FIELDS['Search'] if 'dropdown' in f['fieldtype']]

    return prmz


def getversion():
    try:
        version = popen("/usr/bin/git describe --always").read().strip()
        if version == '':  # try alternate location for git (this is the usual Mac location)
            version = popen("/usr/local/bin/git describe --always").read().strip()
    except:
        version = 'Unknown'
    return version

def check_use(field_to_check, bl_field, used_so_far):
    if field_to_check in used_so_far[bl_field]:
        return True
    else:
        used_so_far[bl_field][field_to_check] = True
        return False

if __name__ == "__main__":

    # holder for global variables and other parameters
    class prmz:
        pass


    prmz = getParms(sys.argv[1], prmz)
    pass

    bl_fields = 'facet search show gallery index sort'.split(' ')

    '''
    facet_field "objproddate_begin_dt", :label => "Production Date", :partial => "blacklight_range_limit/range_limit_panel", :range => {
          :input_label_range_begin => "from year",
          :input_label_range_end => "to year"
    }
    '''

    used_so_far = {'sort': {}}
    bl_config = {key: {} for key in bl_fields}

    for i, fieldtype in enumerate('Facet Search fullDisplay gridDisplay listDisplay'.split(' ')):
        for fields in prmz.FIELDS[fieldtype]:
            solr_field = fields['solrfield']
            label_field = fields['label']
            bl_field = bl_fields[i]
            if bl_field == 'gallery':
                continue
            if bl_field not in used_so_far:
                used_so_far[bl_field] = {}
            limit = ''
            # the catch-all field 'text' is already included
            if solr_field == 'text':
                continue
            if 'mainentry' in fields['fieldtype']:
                bl_config['sort'][ "config.index.title_field =  '%s'" % solr_field] = True
                bl_config['sort'][ "config.show.title_field =  '%s'" % solr_field] = True
                if check_use(solr_field, 'sort', used_so_far): continue
                bl_config['sort'][ "config.add_sort_field '%s asc', label: '%s'" % (solr_field, label_field)] = True
            if 'sortkey' in fields['fieldtype'] or 'musno' in fields['fieldtype']:
                if check_use(solr_field, 'sort', used_so_far): continue
                bl_config['sort'][ "config.add_sort_field '%s asc', label: '%s'" % (solr_field, label_field)] = True
                continue
            if 'blob' in fields['fieldtype']:
                bl_config[bl_field][ "config.index.thumbnail =  '%s'" % solr_field] = True
                bl_config[bl_field][ "config.show.thumbnail =  '%s'" % solr_field] = True
                continue
            if bl_field == 'facet':
                limit = ', limit: true'
            if '_dt' in solr_field:
                bl_config[bl_field][ '''
                config.add_facet_field "%s", :label => "%s", :partial => "blacklight_range_limit/range_limit_panel", :range => {
                      :input_label_range_begin => "from year",
                      :input_label_range_end => "to year"
                }
                ''' % (solr_field, label_field)] = True
            else:
                bl_config[bl_field]["config.add_%s_field '%s', label: '%s'%s" % (bl_field, solr_field, label_field, limit)] = True

     # add two 'constant' fields at end of 'show' display for blobs
     bl_config['show']["config.add_show_field 'blob_ss', helper_method: 'render_media', label: 'Images'"] = True
     bl_config['show']["config.add_show_field 'card_ss', helper_method: 'render_media', label: 'Cards'"] = True

for section in bl_config:
    print('# %s' % section)
    for c in sorted(bl_config[section]):
        print(c)

print('''
  end
end
''')
