#!/bin/sh

echo "Waiting for database..."
/wait-for-db.sh db 5432

if [ $? -ne 0 ]; then
    echo "Database connection failed!"
    exit 1
fi

echo "Database is up!"

# cd models
echo "Running Alembic migrations..."
alembic upgrade head

if [ $? -ne 0 ]; then
    echo "Alembic migration failed!"
    exit 1
fi

echo "Alembic migrations applied successfully!"

cd /app

echo "Starting Uvicorn server..."
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
0.0.0.0