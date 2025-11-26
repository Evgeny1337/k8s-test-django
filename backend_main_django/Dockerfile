FROM unit:1.29.1-python3.11

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /webapp


COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


COPY src/ /webapp/src/


COPY unit_config.json /docker-entrypoint.d/

WORKDIR /webapp/src


ENV SECRET_KEY=temp-key-for-build-only
RUN python manage.py collectstatic --noinput


ENV SECRET_KEY=emporary-key-for-build-only