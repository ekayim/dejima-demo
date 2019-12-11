FROM python:3.7.5
MAINTAINER miyake <miyake.kouta@ist.osaka-u.ac.jp>

RUN pip install --upgrade pip
RUN pip install psycopg2
RUN pip install psycopg2-binary
RUN pip install requests

CMD ["python", "/proxy/main.py"]

