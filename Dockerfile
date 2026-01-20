FROM python:3.11-slim

WORKDIR /app

# 1. Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2. Copy the rest of the application code
COPY . .

# 3. SECURITY: Create a non-root user (Razan's Security Practice)
# This prevents the container from running as 'root'
RUN useradd -m fypuser
USER fypuser

EXPOSE 5000

CMD ["python", "app.py"]
