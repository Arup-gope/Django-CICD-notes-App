# Use official Python 3.9 image
FROM python:3.9

# Set working directory
WORKDIR /app/backend

# Copy requirements
COPY requirements.txt /app/backend/

# Install system dependencies including netcat-openbsd for DB wait
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        default-libmysqlclient-dev \
        pkg-config \
        netcat-openbsd && \
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
    python manage.py migrate && \
    python manage.py runserver 0.0.0.0:8000"]
