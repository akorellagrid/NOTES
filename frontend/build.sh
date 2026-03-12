#!/bin/bash

# Frontend build script for Docker deployment

set -e

echo "🏗️  Building frontend for Docker deployment..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ to build the frontend."
    echo "💡 The frontend will only run when the Docker container is running."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm to build the frontend."
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Clean previous build
echo "🧹 Cleaning previous build..."
npm run clean

# Build for production
echo "🔨 Building for production..."
npm run build

echo "✅ Frontend build completed successfully!"
echo "📁 Built files are in frontend/public/"
echo ""
echo "🐳 To start the application:"
echo "   cd .."
echo "   docker-compose up"
echo ""
echo "🌐 The frontend will be available at http://localhost:8080"
echo "📡 The API will be available at http://localhost:8000"
echo ""
echo "💡 Note: Frontend only runs when Docker container is running (nginx:alpine from Docker Hub)"