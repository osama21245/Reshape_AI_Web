# ReshapeAI Mobile App

## Image Upload and Transformation Flow

The ReshapeAI mobile app allows users to upload room images and transform them using AI. Here's how the flow works:

### 1. Image Selection

- Users can select an image from their gallery or take a new photo with their camera
- The image is compressed and optimized for upload
- Users can select room type, design style, and add custom details

### 2. Image Upload Process

- The selected image is uploaded to Firebase Storage
- A unique filename is generated based on timestamp and original filename
- The image is stored in the 'room_images/' directory in Firebase Storage

### 3. AI Transformation

- The Firebase Storage URL is sent to the server API
- The server uses Replicate API to generate the transformed image
- The transformed image is stored in Firebase Storage

### 4. Result Display

- The original and transformed images are displayed side by side
- The transformation is saved to the user's account
- Users can view all their transformations in the Transformations screen

## API Endpoints

### Mobile-specific Endpoints

- `/api/mobile/generate-photo`: Generates a transformed image from an uploaded image
- `/api/mobile/get-user-data`: Retrieves user data including transformations

## Authentication

- The app uses token-based authentication
- All API requests include the authentication token in the header
- Tokens expire and need to be refreshed periodically

## Credits System

- Each transformation consumes one credit
- Credits can be purchased through the web app
- The app checks for sufficient credits before processing a transformation

## Firebase Integration

- Firebase Storage is used for storing original and transformed images
- Firebase Core is used for initializing Firebase services
