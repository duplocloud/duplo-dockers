FROM amazon/aws-lambda-python:3.11

COPY app.py ${LAMBDA_TASK_ROOT}
COPY requirements.txt ${LAMBDA_TASK_ROOT}

RUN pip install -r requirements.txt

CMD [ "app.handler" ]