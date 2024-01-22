FROM python:latest
WORKDIR /code
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY app.py app.py
COPY AC20-FZK-Haus.ifc AC20-FZK-Haus.ifc
CMD ["python", "-u", "app.py"]