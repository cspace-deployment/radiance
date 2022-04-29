#!/bin/bash

NOTIFY="jblowe@berkeley.edu"

echo "CLEANUP - $(/bin/date) - cleanup starting" 1>&2

BL_ENVIRONMENT=`/usr/bin/curl -s -m 5 http://169.254.169.254/latest/meta-data/tags/instance/Name`

if [[ -z $BL_ENVIRONMENT || ( "$BL_ENVIRONMENT" != "blacklight-dev" && "$BL_ENVIRONMENT" != "blacklight-qa" && "$BL_ENVIRONMENT" != "blacklight-prod" ) ]]; then
        echo "CLEANUP - $(/bin/date) - Cannot get host, are you sure you're on AWS? Aborting!" 1>&2
        /usr/bin/mail -r "cspace-support@lists.berkeley.edu" -s "CLEANUP - $TENANT Blacklight DB clean up failed" ${NOTIFY} <<< 'See dbclean.log for details.'
        exit 1
fi

for TENANT in pahma cinefiles bampfa
do
   DBDIR="/cspace/blacklight/${TENANT}/db"
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
      /usr/bin/mail -r "cspace-support@lists.berkeley.edu" -s "CLEANUP - $BL_ENVIRONMENT $TENANT Blacklight DB clean up failed" ${NOTIFY} <<< 'Unable to gzip, see dbclean.log'
   else
      echo "CLEANUP - $TENANT - $(/bin/date) - copying to s3" 1>&2
      if ! /usr/bin/aws s3 cp ${DBDIR}/${DBNAME}.gz s3://${BL_ENVIRONMENT}/dbbackups/${TENANT}/${DBNAME}.gz
      then
         echo "CLEANUP - $TENANT - $(/bin/date) - copy to s3 failed, aborting" 1>&2
         /usr/bin/mail -r "cspace-support@lists.berkeley.edu" -s "CLEANUP - $BL_ENVIRONMENT $TENANT Blacklight DB clean up failed" ${NOTIFY} <<< 'Unable to copy to S3, see dbclean.log for details.'
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
            /usr/bin/mail -r "cspace-support@lists.berkeley.edu" -s "CLEANUP - $BL_ENVIRONMENT $TENANT Blacklight DB clean up completed with errors" ${NOTIFY} <<< 'See dbclean.log for details.'
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