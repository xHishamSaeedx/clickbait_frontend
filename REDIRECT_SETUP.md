# Redirect Functionality Setup Guide

This guide explains how the redirect functionality works and how to set it up.

## Overview

When users open the app, they are automatically redirected to their default browser with a URL fetched from the backend API.

## Backend Setup

The backend already has the necessary endpoints:

1. **GET /api/url** - Returns a random URL from a predefined list
2. **GET /api/redirect-config** - Returns redirect configuration settings

### Backend Endpoints

```javascript
// GET /api/url
{
  "url": "https://www.google.com",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "totalUrls": 8
}

// GET /api/redirect-config
{
  "mandatory": true,
  "maxRedirectsPerDay": 2,
  "minTimeBetweenRedirects": 24,
  "enabled": true,
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## Frontend Setup

### Dependencies Added

The following dependencies have been added to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0 # For API calls
  url_launcher: ^6.2.1 # For opening URLs in browser
```

### Files Created/Modified

1. **lib/shared/services/api_service.dart** - Handles API calls to backend
2. **lib/shared/services/url_launcher_service.dart** - Handles opening URLs in browser
3. **lib/core/constants/api_constants.dart** - Centralized API configuration
4. **lib/features/home/presentation/pages/splash_screen.dart** - Modified to implement redirect logic
5. **android/app/src/main/AndroidManifest.xml** - Added internet permission and URL queries
6. **ios/Runner/Info.plist** - Added URL scheme queries

### Configuration

To change the backend URL, modify `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'http://192.168.1.100:3000'; // Change to your actual IP address
  // ... rest of the constants
}
```

#### Finding Your IP Address

**Option 1: Using the provided script (Recommended)**

1. Open terminal/command prompt in the project root
2. Run: `node find_ip.js`
3. Copy the displayed IP address

**Option 2: Manual method**

**Windows:**

1. Open Command Prompt
2. Run: `ipconfig`
3. Look for "IPv4 Address" under your active network adapter (usually starts with 192.168.x.x)

**Mac/Linux:**

1. Open Terminal
2. Run: `ifconfig` (Mac/Linux) or `ip addr` (Linux)
3. Look for "inet" followed by your IP address

**Important Notes:**

- Use your computer's local IP address (usually starts with 192.168.x.x or 10.0.x.x)
- Make sure your phone/device is on the same WiFi network as your computer
- The backend server must be accessible from your device's network

## How It Works

1. **App Launch**: When the app starts, it shows the splash screen
2. **API Call**: After 3 seconds, the app fetches a URL from the backend
3. **Browser Redirect**: The app opens the fetched URL in the user's default browser
4. **App Navigation**: After the redirect, the app navigates to the start page

## Error Handling

The implementation includes comprehensive error handling:

- **API Connection Errors**: Shows error message and continues to start page
- **URL Launch Failures**: Shows error message and continues to start page
- **Network Issues**: Graceful fallback with user feedback

## Permissions

### Android

- `INTERNET` permission for API calls
- URL queries for opening external URLs

### iOS

- `LSApplicationQueriesSchemes` for HTTP/HTTPS URLs

## Testing

1. **Find your computer's IP address** (see Configuration section above)
2. **Update the IP address** in `lib/core/constants/api_constants.dart`
3. **Start the backend server**: `npm start` (in clickbait_backend directory)
4. **Run the Flutter app**: `flutter run`
5. The app should automatically redirect to a random website after 3 seconds

## Network Configuration

### Backend Server Setup

Make sure your backend server is configured to accept connections from other devices:

1. **Check if the server is listening on all interfaces**:

   ```javascript
   // In your server.js, make sure you're not binding to localhost only
   app.listen(PORT, "0.0.0.0", () => {
     console.log(`Server is running on port ${PORT}`);
   });
   ```

2. **Firewall Configuration**:
   - Windows: Allow Node.js through Windows Firewall
   - Mac: Allow incoming connections for Node.js
   - Linux: Configure iptables if needed

### Troubleshooting

**If the app can't connect to the backend:**

1. **Test connectivity**: Try accessing `http://YOUR_IP:3000/health` from your device's browser
2. **Check firewall**: Ensure port 3000 is open on your computer
3. **Verify IP address**: Make sure you're using the correct IP address
4. **Network issues**: Ensure both devices are on the same WiFi network
5. **Backend logs**: Check if the backend is receiving requests

## Customization

### Adding More URLs

Modify the `redirectUrls` array in `../clickbait_backend/src/routes/api.js`:

```javascript
const redirectUrls = [
  "https://www.google.com",
  "https://www.youtube.com",
  // Add more URLs here
];
```

### Changing Redirect Timing

Modify the Timer duration in `splash_screen.dart`:

```dart
Timer(const Duration(seconds: 5), () async { // Change from 3 to 5 seconds
```

### Disabling Redirect

Set `enabled: false` in the backend `/api/redirect-config` endpoint or modify the frontend logic to check this configuration.
