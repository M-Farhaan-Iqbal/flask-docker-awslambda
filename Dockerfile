#AWS base image
FROM public.ecr.aws/lambda/python:3.11

# Copy requirements.txt
COPY requirements.txt ./

# Copy function code
COPY lambda_function.py ./

# Install the specified packages
RUN pip install -r requirements.txt

EXPOSE 8080

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "lambda_function.lambda_handler" ]
