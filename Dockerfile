# Use official Python 3.9 image
FROM python:3.9

WORKDIR /app/backend

COPY requirements.txt /app/backend
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*


# Install app dependencies
RUN pip install mysqlclient
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/backend

EXPOSE 8000
# Run migrations (optional, but usually done at container start)
#RUN python manage.py makemigrations
#RUN python manage.py migrate

# Add this at the end to start Django
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]