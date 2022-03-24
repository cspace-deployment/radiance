#!/bin/bash

echo "CLEANUP - $(/bin/date) - cleanup starting" 1>&2

if ! /bin/systemctl --quiet is-active apache2.service
then
   echo "CLEANUP - $(/bin/date) - apache is not running!" 1>&2
   echo "CLEANUP - $(/bin/date) - finished" 1>&2
   exit
fi

echo "CLEANUP - $(/bin/date) - stopping apache" 1>&2
while /bin/systemctl --quiet is-active apache2.service
do
   /bin/systemctl stop apache2.service
   /bin/sleep 5
done

for TENANT in pahma cinefiles
do
   SQLERRORS=1

   echo "CLEANUP - $TENANT - $(/bin/date) - gzipping current db" 1>&2
   if [ -f /root/dbbackup/production.sqlite3.${TENANT}."$(/bin/date +%Y%m%d)".gz ] || ! /bin/gzip -c /var/cspace/${TENANT}/blacklight/db/production.sqlite3 > /root/dbbackup/production.sqlite3.${TENANT}."$(/bin/date +%Y%m%d)".gz
   then
      echo "CLEANUP - $TENANT - $(/bin/date) - gzip failed, aborting" 1>&2
      /usr/bin/mail -s "CLEANUP - $TENANT Blacklight DB clean up failed" felder@berkeley.edu <<< 'Unable to gzip, see /root/dbclean.log for details or make sure there is not already a backup for the current date.'
   else
      echo "CLEANUP - $TENANT - $(/bin/date) - copying to drive" 1>&2
      if ! /usr/bin/rclone copy --ignore-existing /root/dbbackup/production.sqlite3.${TENANT}."$(/bin/date +%Y%m%d)".gz blacklight_db_backups:/blacklight_db_backups/prod/${TENANT}/
      then
         echo "CLEANUP - $TENANT - $(/bin/date) - rclone failed, aborting" 1>&2
         /usr/bin/mail -s "CLEANUP - $TENANT Blacklight DB clean up failed" felder@berkeley.edu <<< 'Unable to copy to drive, see /root/dbclean.log for details.'
      else
         SQLERRORS=0

         echo "CLEANUP - $TENANT - $(/bin/date) - deleting searches" 1>&2
         if ! /usr/bin/sqlite3 /var/cspace/${TENANT}/blacklight/db/production.sqlite3 "delete from searches;"
         then
            ((SQLERRORS++))
         fi

         echo "CLEANUP - $TENANT - $(/bin/date) - deleting users" 1>&2
         if ! /usr/bin/sqlite3 /var/cspace/${TENANT}/blacklight/db/production.sqlite3 "delete from users where email like 'guest_%';"
         then
            ((SQLERRORS++))
         fi

         echo "CLEANUP - $TENANT - $(/bin/date) - deleting bookmarks" 1>&2
         if ! /usr/bin/sqlite3 /var/cspace/${TENANT}/blacklight/db/production.sqlite3 "delete from bookmarks where user_id not in (select id from users);"
         then
            ((SQLERRORS++))
         fi

         echo "CLEANUP - $TENANT - $(/bin/date) - vacuuming" 1>&2
         if ! /usr/bin/sqlite3 /var/cspace/${TENANT}/blacklight/db/production.sqlite3 "vacuum;"
         then
            ((SQLERRORS++))
         fi

         if [ "$SQLERRORS" -gt "0" ]
         then
            /usr/bin/mail -s "CLEANUP - $TENANT Blacklight DB clean up completed with errors" felder@berkeley.edu <<< 'See /root/dbclean.log for details.'
         fi
      fi
   fi

   if [ "$SQLERRORS" -eq "0" ]
   then
      echo "CLEANUP - $TENANT - $(/bin/date) - removing 4 week old backup" 1>&2
      /bin/rm -f /root/dbbackup/production.sqlite3.${TENANT}."$(/bin/date +%Y%m%d --date='4 weeks ago')".gz
   fi
done

echo "CLEANUP - $(/bin/date) - starting apache" 1>&2
while ! /bin/systemctl --quiet is-active apache2.service
do
   /bin/systemctl start apache2.service
   /bin/sleep 5
done

echo "CLEANUP - $(/bin/date) - finished" 1>&2
