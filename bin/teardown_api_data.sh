#!/bin/bash

org_id=${1:-"62309201-d2f0-407f-875b-9f836f94f2ca"}
echo
echo "Deleting liquidvoting api data for organization: $org_id :"

for table in votes delegations results participants
do
	echo "for $table..."
	echo "DELETE FROM $table WHERE organization_id = '$org_id';" |psql --username=postgres --dbname=liquid_voting_dev
done
