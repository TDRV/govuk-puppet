#!/usr/bin/env bash
#
# Fetch the most recent database dump files from production and restore locally.
#

set -eu

. $(dirname $0)/common-args.sh

status "Running bundle install"
bundle install --quiet

$(dirname $0)/sync-mysql.sh "$@" mysql-backup-1.backend.integration
$(dirname $0)/sync-mysql.sh "$@" whitehall-mysql-backup-1.backend.integration

$(dirname $0)/sync-mongo.sh "$@" mongo-1.backend.integration
$(dirname $0)/sync-mongo.sh "$@" api-mongo-1.api.integration
$(dirname $0)/sync-mongo.sh "$@" router-backend-1.router.integration

if ! ($SKIP_MONGO || $DRY_RUN); then
  if $TRAINING_ENVIRONMENT; then
    status "Munging router backend hostnames for training VM"
    mongo --quiet --eval 'db = db.getSiblingDB("router"); db.backends.find().forEach( function(b) { b.backend_url = b.backend_url.replace(".integration.publishing.service.gov.uk", ".training.publishing.service.gov.uk"); db.backends.save(b); } );'
    mongo --quiet --eval 'db = db.getSiblingDB("draft_router"); db.backends.find().forEach( function(b) { b.backend_url = b.backend_url.replace(".integration.publishing.service.gov.uk", ".training.publishing.service.gov.uk"); db.backends.save(b); } );'
  else
    status "Munging router backend hostnames for dev VM"
    mongo --quiet --eval 'db = db.getSiblingDB("router"); db.backends.find().forEach( function(b) { b.backend_url = b.backend_url.replace(".integration.publishing.service.gov.uk", ".dev.gov.uk").replace("https","http"); db.backends.save(b); } );'
    mongo --quiet --eval 'db = db.getSiblingDB("draft_router"); db.backends.find().forEach( function(b) { b.backend_url = b.backend_url.replace(".integration.publishing.service.gov.uk", ".dev.gov.uk").replace("https","http"); db.backends.save(b); } );'
  fi
fi

$(dirname $0)/sync-postgresql.sh "$@" postgresql-primary-1.backend.integration
if ignored "transition"; then
  status "Skipping transition"
else
  $(dirname $0)/sync-postgresql.sh "$@" transition-postgresql-master-1.backend.integration
fi

if ignored "mapit"; then
  status "Skipping mapit"
else
  $(dirname $0)/sync-mapit.sh
fi

$(dirname $0)/sync-elasticsearch.sh "$@" rummager-elasticsearch-1.api.integration

if ! ($SKIP_ELASTIC || $DRY_RUN); then
  status "Deleting old elasticsearch indexes"
  ruby $(dirname $0)/delete_closed_indices.rb
fi

if ! $DRY_RUN; then
  status "Munging Signon db tokens for dev VM"
  if [[ -d $(dirname $0)/../../../signon ]]; then
    cd $(dirname $0)/../../../signon && bundle install && bundle exec ruby script/make_oauth_work_in_dev
  fi
fi

ok "Data replication complete"
