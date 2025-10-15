FROM python:3.9

# Set working directory
WORKDIR /app/backend

# Copy and install dependencies
COPY requirements.txt /app/backend
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN pip install mysqlclient
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app
COPY . /app/backend

# Expose the Django port
EXPOSE 8000

# Run database migrations (optional, better to do via entrypoint script)
# RUN python manage.py migrate
# RUN python manage.py makemigrations

# 🔹 Keep container running by starting the Django app
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
