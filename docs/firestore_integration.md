# Firestore Integration Guide

This guide covers the comprehensive Firestore integration in the WhatsApp MicroLearning Bot application.

## Overview

The app uses Cloud Firestore as the primary database for storing:
- User profiles and preferences
- Chat history and sessions
- Learning progress and analytics
- Achievements and statistics
- Real-time data synchronization

## Architecture

### Data Models

#### FirestoreUser
```dart
FirestoreUser(
  uid: String,           // Firebase Auth UID
  email: String,         // User email
  displayName: String?,  // Optional display name
  photoURL: String?,     // Profile photo URL
  emailVerified: bool,   // Email verification status
  createdAt: DateTime,   // Account creation date
  updatedAt: DateTime,   // Last update timestamp
  lastSignInAt: DateTime?, // Last sign-in time
  signInMethods: List<String>, // Auth methods used
  preferences: Map<String, dynamic>, // User preferences
  stats: UserStats,      // User statistics
)
```

#### ChatSession
```dart
ChatSession(
  id: String,           // Unique session ID
  userId: String,       // Owner user ID
  title: String,        // Session title
  topic: String?,       // Optional topic
  createdAt: DateTime,  // Creation timestamp
  updatedAt: DateTime,  // Last update timestamp
  messageCount: int,    // Number of messages
  isActive: bool,       // Active status
  metadata: Map<String, dynamic>, // Additional data
)
```

#### ChatMessage
```dart
ChatMessage(
  id: String,           // Unique message ID
  sessionId: String,    // Parent session ID
  userId: String,       // Message owner
  content: String,      // Message content
  role: String,         // 'user', 'assistant', 'system'
  timestamp: DateTime,  // Message timestamp
  templateId: String?,  // Optional template ID
  templateData: Map?,   // Template data
  isLoading: bool,      // Loading state
  error: String?,       // Error message
  metadata: Map<String, dynamic>, // Additional data
)
```

#### LearningSession
```dart
LearningSession(
  id: String,           // Unique session ID
  userId: String,       // Learner user ID
  topic: String,        // Learning topic
  category: String?,    // Optional category
  startTime: DateTime,  // Session start time
  endTime: DateTime?,   // Session end time (null if active)
  durationMinutes: int, // Session duration
  messageCount: int,    // Messages in session
  topicsDiscussed: List<String>, // Topics covered
  experienceGained: int, // XP earned
  type: LearningSessionType, // Session type
  metadata: Map<String, dynamic>, // Additional data
)
```

### Collection Structure

```
/users/{userId}
  - User profile data
  
/chat_history/{userId}/sessions/{sessionId}
  - Chat session metadata
  
/chat_history/{userId}/sessions/{sessionId}/messages/{messageId}
  - Individual chat messages
  
/learning_sessions/{userId}/sessions/{sessionId}
  - Learning session data
  
/user_progress/{userId}/entries/{progressId}
  - Topic progress tracking
  
/user_progress/{userId}/achievements/{achievementId}
  - User achievements
```

## Services

### FirestoreService
Core service providing:
- Type-safe collection and document references
- Generic CRUD operations
- Real-time streaming
- Batch operations
- Transaction support
- Offline persistence management

### UserDataService
User-specific operations:
- Profile management
- Statistics tracking
- Level calculation
- Streak management
- Data export/deletion (GDPR compliance)

### ChatStorageService
Chat-related operations:
- Session management
- Message storage and retrieval
- Real-time chat streaming
- Search functionality
- Data cleanup

### LearningAnalyticsService
Learning progress tracking:
- Session management
- Progress calculation
- Achievement system
- Analytics generation
- Experience point calculation

## Security Rules

The app uses comprehensive Firestore security rules:

```javascript
// Users can only access their own data
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// Chat history is user-specific
match /chat_history/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// Learning data is private
match /learning_sessions/{userId} {
  allow read, write: if request.auth.uid == userId;
}
```

## Configuration

### Environment Variables

```env
# Firestore Configuration
ENABLE_FIRESTORE_OFFLINE=true
FIRESTORE_CACHE_SIZE=40MB
ENABLE_FIRESTORE_LOGGING=true
MAX_CHAT_HISTORY_DAYS=30
MAX_LEARNING_SESSIONS_STORED=100
```

### Initialization

```dart
// Initialize Firestore service
await FirestoreService.instance.initialize();

// Enable offline persistence
await FirestoreService.instance.enableOfflinePersistence();
```

## Usage Examples

### Creating a User Profile

```dart
final userDataService = UserDataService.instance;

await userDataService.createOrUpdateUser(appUser);
```

### Starting a Chat Session

```dart
final chatService = ChatStorageService.instance;

final sessionId = await chatService.createChatSession(
  userId: userId,
  title: 'Learning Flutter',
  topic: 'Programming',
);
```

### Saving Chat Messages

```dart
await chatService.saveChatMessage(
  userId: userId,
  sessionId: sessionId,
  content: 'Hello, AI!',
  role: 'user',
);
```

### Tracking Learning Progress

```dart
final analyticsService = LearningAnalyticsService.instance;

// Start learning session
final sessionId = await analyticsService.startLearningSession(
  userId: userId,
  topic: 'Dart Basics',
  type: LearningSessionType.explanation,
);

// End session with progress
await analyticsService.endLearningSession(
  userId,
  sessionId,
  topicsDiscussed: ['Variables', 'Functions'],
);
```

### Real-time Data Streaming

```dart
// Stream user profile changes
userDataService.streamUser(userId).listen((user) {
  // Update UI with new user data
});

// Stream chat messages
chatService.streamChatMessages(userId, sessionId).listen((messages) {
  // Update chat UI
});
```

## Offline Support

The app supports offline functionality:

### Automatic Offline Persistence
- Firestore automatically caches data for offline access
- Configurable cache size (default: 40MB)
- Automatic sync when connection is restored

### Manual Network Control
```dart
// Disable network for testing
await FirestoreService.instance.disableNetwork();

// Re-enable network
await FirestoreService.instance.enableNetwork();

// Clear offline cache
await FirestoreService.instance.clearPersistence();
```

## Data Management

### Cleanup Policies
- Chat history older than 30 days is automatically cleaned up
- Learning sessions are limited to 100 per user
- Configurable through environment variables

### GDPR Compliance
```dart
// Export user data
final userData = await userDataService.exportUserData(userId);

// Delete all user data
await userDataService.deleteUserData(userId);
```

## Performance Optimization

### Indexing
Firestore automatically creates indexes for:
- Single-field queries
- Composite queries are defined in `firestore.indexes.json`

### Pagination
```dart
// Paginated message loading
final messages = await chatService.getChatMessages(
  userId,
  sessionId,
  limit: 20,
  startAfter: lastDocument,
);
```

### Batch Operations
```dart
final batch = FirestoreService.instance.batch();
// Add multiple operations
await FirestoreService.instance.commitBatch(batch);
```

## Monitoring and Analytics

### Built-in Analytics
- User engagement metrics
- Learning progress tracking
- Session duration analysis
- Achievement unlock rates

### Error Handling
- Comprehensive error logging
- Graceful degradation for offline scenarios
- User-friendly error messages

## Testing

### Unit Tests
- Model serialization/deserialization
- Service method functionality
- Error handling scenarios

### Integration Tests
- End-to-end data flow
- Offline functionality
- Real-time synchronization

## Best Practices

1. **Always use type-safe references** through FirestoreService
2. **Implement proper error handling** for all Firestore operations
3. **Use real-time listeners** for UI updates
4. **Batch related operations** for better performance
5. **Clean up old data** regularly to manage storage costs
6. **Test offline scenarios** thoroughly
7. **Follow security rules** strictly for data protection

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Check security rules
   - Verify user authentication
   - Ensure correct user ID

2. **Offline Data Not Syncing**
   - Check network connectivity
   - Verify offline persistence is enabled
   - Clear cache if necessary

3. **Performance Issues**
   - Review query efficiency
   - Check for missing indexes
   - Optimize data structure

### Debug Tools

```dart
// Enable Firestore logging
FirebaseFirestore.setLoggingEnabled(true);

// Check network status
final isOnline = await FirestoreService.instance.enableNetwork();
```

## Migration and Updates

When updating data models:
1. Create migration scripts for existing data
2. Update security rules accordingly
3. Test with existing user data
4. Deploy incrementally

This comprehensive Firestore integration provides a robust, scalable, and secure backend for the WhatsApp MicroLearning Bot application.
