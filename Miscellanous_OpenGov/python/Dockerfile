FROM python:3.8-bullseye
WORKDIR /code

RUN apt-get update &&\
    apt-get install -y binutils libproj-dev gdal-bin libgdal-dev

# Install required packages
ADD requirements.txt .
RUN pip install -r requirements.txt

# Copy the input files and the python script
COPY load_station_data.py .
#COPY data.zip .
#RUN unzip data.zip

# Run python script and load data to SQL db
CMD ["python", "-u", "load_station_data.py"]