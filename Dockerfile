

# OPTIMIZED VERSION - Add cache and skip unnecessary packages
FROM python:3.10-slim

WORKDIR /app

# 1. Install system dependencies first (better caching)
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Copy requirements and install with cache
COPY requirements.txt .
RUN pip install --default-timeout=300 --retries=10 -r requirements.txt

# 3. Copy app
COPY . .

EXPOSE 8501
CMD ["streamlit", "run", "mediconsult_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
