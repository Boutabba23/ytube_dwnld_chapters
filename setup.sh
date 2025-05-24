#!/bin/bash

# YouTube Chapter Downloader Setup Script
# This script helps set up the development environment

echo "🎬 YouTube Chapter Downloader Setup"
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

echo -e "\n${BLUE}Checking prerequisites...${NC}"

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC} Node.js found: $NODE_VERSION"
else
    echo -e "${RED}✗${NC} Node.js not found. Please install Node.js (v16 or higher)"
    echo "  Visit: https://nodejs.org/"
    exit 1
fi

# Check npm
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓${NC} npm found: $NPM_VERSION"
else
    echo -e "${RED}✗${NC} npm not found"
    exit 1
fi

# Check Flutter
if command_exists flutter; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo -e "${GREEN}✓${NC} Flutter found: $FLUTTER_VERSION"
else
    echo -e "${RED}✗${NC} Flutter not found. Please install Flutter SDK"
    echo "  Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check yt-dlp
if command_exists yt-dlp; then
    YTDLP_VERSION=$(yt-dlp --version)
    echo -e "${GREEN}✓${NC} yt-dlp found: $YTDLP_VERSION"
else
    echo -e "${YELLOW}⚠${NC} yt-dlp not found. Installing..."
    
    # Try to install yt-dlp
    if command_exists pip; then
        pip install yt-dlp
        print_status $? "yt-dlp installation"
    elif command_exists apt; then
        sudo apt update && sudo apt install -y yt-dlp
        print_status $? "yt-dlp installation"
    elif command_exists brew; then
        brew install yt-dlp
        print_status $? "yt-dlp installation"
    else
        echo -e "${RED}✗${NC} Could not install yt-dlp automatically"
        echo "  Please install manually: https://github.com/yt-dlp/yt-dlp#installation"
        exit 1
    fi
fi

# Check ffmpeg
if command_exists ffmpeg; then
    FFMPEG_VERSION=$(ffmpeg -version | head -n 1 | cut -d' ' -f3)
    echo -e "${GREEN}✓${NC} ffmpeg found: $FFMPEG_VERSION"
else
    echo -e "${YELLOW}⚠${NC} ffmpeg not found. Installing..."
    
    # Try to install ffmpeg
    if command_exists apt; then
        sudo apt update && sudo apt install -y ffmpeg
        print_status $? "ffmpeg installation"
    elif command_exists brew; then
        brew install ffmpeg
        print_status $? "ffmpeg installation"
    else
        echo -e "${RED}✗${NC} Could not install ffmpeg automatically"
        echo "  Please install manually: https://ffmpeg.org/download.html"
        exit 1
    fi
fi

echo -e "\n${BLUE}Setting up backend...${NC}"

# Install backend dependencies
cd backend
if [ -f "package.json" ]; then
    echo "Installing Node.js dependencies..."
    npm install
    print_status $? "Backend dependencies installed"
else
    echo -e "${RED}✗${NC} Backend package.json not found"
    exit 1
fi

echo -e "\n${BLUE}Setting up Flutter app...${NC}"

# Install Flutter dependencies
cd ../ytube_dwnld
if [ -f "pubspec.yaml" ]; then
    echo "Installing Flutter dependencies..."
    flutter pub get
    print_status $? "Flutter dependencies installed"
else
    echo -e "${RED}✗${NC} Flutter pubspec.yaml not found"
    exit 1
fi

echo -e "\n${GREEN}🎉 Setup completed successfully!${NC}"
echo -e "\n${BLUE}Next steps:${NC}"
echo "1. Start the backend server:"
echo -e "   ${YELLOW}cd backend && npm run dev${NC}"
echo ""
echo "2. In a new terminal, run the Flutter app:"
echo -e "   ${YELLOW}cd ytube_dwnld && flutter run${NC}"
echo ""
echo "3. Update the server URL in the Flutter app if needed:"
echo -e "   ${YELLOW}ytube_dwnld/lib/services/api_service.dart${NC}"
echo ""
echo -e "${BLUE}For more information, see README.md${NC}"