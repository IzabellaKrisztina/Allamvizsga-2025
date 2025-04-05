#!/bin/bash

until pg_isready -h db -p 5432 -U postgres; do
  echo "Waiting for database to be ready..."
  sleep 2
done

echo "Database is ready!"
