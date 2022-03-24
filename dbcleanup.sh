#!/bin/bash

NOTIFY="jblowe@berkeley.edu"

echo "CLEANUP - $(/bin/date) - cleanup starting" 1>&2

for TENANT in pahma cinefiles
do
   DBDIR="/var/cspace/${TENANT}/blacklight/db"
   DBNAME="production.sqlite3.${TENANT}.$(/bin/date +%Y%m%d)"
   SQLERRORS=0

   echo "CLEANUP - $TENANT - $(/bin/date) - dumping current db" 1>&2
   if ! /usr/bin/sqlite3 ${DBDIR}/production.sqlite3 ".dump" > ${DBDIR}/${DBNAME}
   then
      ((SQLERRORS++))
   fi

   echo "CLEANUP - $TENANT - $(/bin/date) - gzipping dump" 1>&2
   if [ -f ${DBDIR}/${DBNAME}.gz ] || ! /bin/gzip ${DBDIR}/${DBNAME}
   then
      echo "CLEANUP - $TENANT - $(/bin/date) - gzip failed, aborting" 1>&2
      /usr/bin/mail -s "CLEANUP - $TENANT Blacklight DB clean up failed" ${NOTIFY} <<< 'Unable to gzip, see dbclean.log'
   else
      echo "CLEANUP - $TENANT - $(/bin/date) - copying to drive" 1>&2
      if ! /usr/bin/rclone copy --ignore-existing ${DBDIR}/${DBNAME}.gz blacklight_db_backups:/blacklight_db_backups/prod/${TENANT}/
      then
         echo "CLEANUP - $TENANT - $(/bin/date) - rclone failed, aborting" 1>&2
         /usr/bin/mail -s "CLEANUP - $TENANT Blacklight DB clean up failed" ${NOTIFY} <<< 'Unable to copy to drive, see dbclean.log for details.'
      else
         SQLERRORS=0

         echo "CLEANUP - $TENANT - $(/bin/date) - deleting searches" 1>&2
         if ! /usr/bin/sqlite3 ${DBDIR}/production.sqlite3 "delete from searches;"
         then
            ((SQLERRORS++))
         fi

         echo "CLEANUP - $TENANT - $(/bin/date) - deleting users" 1>&2
         if ! /usr/bin/sqlite3 ${DBDIR}/production.sqlite3 "delete from users where email like 'guest_%';"
         then
            ((SQLERRORS++))
         fi

         echo "CLEANUP - $TENANT - $(/bin/date) - deleting bookmarks" 1>&2
         if ! /usr/bin/sqlite3 ${DBDIR}/production.sqlite3 "delete from bookmarks where user_id not in (select id from users);"
         then
            ((SQLERRORS++))
         fi

         echo "CLEANUP - $TENANT - $(/bin/date) - vacuuming" 1>&2
         if ! /usr/bin/sqlite3 ${DBDIR}/production.sqlite3 "vacuum;"
         then
            ((SQLERRORS++))
         fi

         if [ "$SQLERRORS" -gt "0" ]
         then
            /usr/bin/mail -s "CLEANUP - $TENANT Blacklight DB clean up completed with errors" ${NOTIFY} <<< 'See dbclean.log for details.'
         fi
      fi
   fi

   if [ "$SQLERRORS" -eq "0" ]
   then
      echo "CLEANUP - $TENANT - $(/bin/date) - removing 4 week old backup" 1>&2
      /bin/rm -f ${DBDIR}/production.sqlite3.${TENANT}."$(/bin/date +%Y%m%d --date='4 weeks ago')".gz
   fi
done

echo "CLEANUP - $(/bin/date) - finished" 1>&2
