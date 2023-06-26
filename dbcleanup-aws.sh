#!/bin/bash

NOTIFY="jblowe@berkeley.edu"

echo "CLEANUP - $(/bin/date) - cleanup starting" 1>&2

source /home/app_cspace/bin/set_environment.sh  || { echo 'could not set environment vars. set_environment.sh failed'; exit 1; }

for TENANT in pahma cinefiles bampfa
do
   DBDIR="/cspace/blacklight/${TENANT}/db"
   DBNAME="production.sqlite3.${TENANT}.$(/bin/date +%Y%m%d)"
   ERRORS=0

   echo "CLEANUP - $TENANT - $(/bin/date) - dumping current db" 1>&2
   if ! /usr/bin/sqlite3 ${DBDIR}/production.sqlite3 ".dump" > ${DBDIR}/${DBNAME}
   then
      ((ERRORS++))
   fi

   echo "CLEANUP - $TENANT - $(/bin/date) - gzipping dump" 1>&2
   if [ -f ${DBDIR}/${DBNAME}.gz ] || ! /bin/gzip ${DBDIR}/${DBNAME}
   then
      echo "CLEANUP - $TENANT - $(/bin/date) - gzip failed, aborting" 1>&2
      /usr/bin/mail -r "cspace-support@lists.berkeley.edu" -s "CLEANUP - $BL_ENVIRONMENT $TENANT Blacklight DB clean up failed" ${NOTIFY} <<< 'Unable to gzip, see dbclean.log'
   else
      echo "CLEANUP - $TENANT - $(/bin/date) - copying to s3" 1>&2
      if ! /usr/bin/aws s3 cp --quiet ${DBDIR}/${DBNAME}.gz s3://${BL_ENVIRONMENT}/dbbackups/${TENANT}/${DBNAME}.gz
      then
         echo "CLEANUP - $TENANT - $(/bin/date) - copy to s3 failed, aborting" 1>&2
         /usr/bin/mail -r "cspace-support@lists.berkeley.edu" -s "CLEANUP - $BL_ENVIRONMENT $TENANT Blacklight DB clean up failed" ${NOTIFY} <<< 'Unable to copy to S3, see dbclean.log for details.'
      else
         ERRORS=0

         cd /home/app_cspace/projects/search_$TENANT
         echo "CLEANUP - $TENANT - $(/bin/date) - deleting searches" 1>&2
         if ! rake blacklight:delete_old_searches
         then
            ((ERRORS++))
         fi

         echo "CLEANUP - $TENANT - $(/bin/date) - deleting guests" 1>&2
         if ! rake devise_guests:delete_old_guest_users
         then
            ((ERRORS++))
         fi

         # for now, let's skip cleaning up bookmarks: there are so few of them
         # echo "CLEANUP - $TENANT - $(/bin/date) - deleting bookmarks" 1>&2
         # if ! /usr/bin/sqlite3 ${DBDIR}/production.sqlite3 "delete from bookmarks where user_id not in (select id from users);"
         # then
         #    ((ERRORS++))
         # fi

         echo "CLEANUP - $TENANT - $(/bin/date) - vacuuming" 1>&2
         if ! /usr/bin/sqlite3 ${DBDIR}/production.sqlite3 "vacuum;"
         then
            ((ERRORS++))
         fi

         if [ "$ERRORS" -gt "0" ]
         then
            /usr/bin/mail -r "cspace-support@lists.berkeley.edu" -s "CLEANUP - $BL_ENVIRONMENT $TENANT Blacklight DB clean up completed with errors" ${NOTIFY} <<< 'See dbclean.log for details.'
         fi
      fi
   fi

   if [ "$ERRORS" -eq "0" ]
   then
      echo "CLEANUP - $TENANT - $(/bin/date) - removing 4 week old backup" 1>&2
      /bin/rm -f ${DBDIR}/production.sqlite3.${TENANT}."$(/bin/date +%Y%m%d --date='4 weeks ago')".gz
   fi
done

echo "CLEANUP - $(/bin/date) - finished" 1>&2