# Use official Python image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend application code
COPY backend/ ./backend/

# Set Python path to include backend directory
ENV PYTHONPATH=/app

# Expose FastAPI default port
EXPOSE 8000

# Run Alembic migrations and start FastAPI app
CMD ["sh", "-c", "cd backend && alembic upgrade head && python main.py"]
