FROM python:3.9

# Set working directory
WORKDIR /app/backend

# Copy requirements first (leverages Docker cache)
COPY requirements.txt /app/backend/

# Install system dependencies including netcat for DB wait
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        default-libmysqlclient-dev \
        pkg-config \
        netcat && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install mysqlclient

# Copy application code
COPY . /app/backend

# Expose Django port
EXPOSE 8000

# Entrypoint: wait for DB, migrate, and run server
CMD ["bash", "-c", "\
    until nc -zv $DB_HOST $DB_PORT >/dev/null 2>&1; do \
        echo 'Waiting for database...'; sleep 5; \
    done; \
    echo 'Database is up! Running migrations...'; \
    python manage.py migrate; \
    echo 'Starting Django server...'; \
    python manage.py runserver 0.0.0.0:8000"]
