# Use official Python 3.9 image
FROM python:3.9

# Set working directory
WORKDIR /app/backend

# Copy requirements file
COPY requirements.txt /app/backend/

# Install system dependencies including netcat for DB wait
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config netcat \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install mysqlclient

# Copy application code
COPY . /app/backend

# Expose Django port
EXPOSE 8000

# Entrypoint: Wait for DB, migrate, and run server
CMD bash -c "\
    echo 'Waiting for database at $DB_HOST:$DB_PORT...' && \
    until nc -z $DB_HOST $DB_PORT; do \
        echo 'Database not ready yet. Sleeping 2s...'; \
        sleep 2; \
    done; \
    echo 'Database is up! Running migrations...' && \
    python manage.py migrate && \
    echo 'Starting Django server...' && \
    python manage.py runserver 0.0.0.0:8000"
