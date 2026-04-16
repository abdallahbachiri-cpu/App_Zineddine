# Environment Variables Setup Guide

This project uses environment variables to manage secrets and configuration. All sensitive data has been migrated from hardcoded values to environment variables.

## Setup Instructions

### 1. Create `.env` File

Copy the `.env.example` file to create your `.env` file:

```bash
cp .env.example .env
```

**Note:** The `.env` file is ignored by git (it's in `.gitignore`) and should never be committed to version control.

### 2. Fill in Your Values

Open `.env` and replace the placeholder values with your actual secrets:

```env
# API Configuration
API_BASE_URL=https://your-api-url.com/
API_BASE_URL_LOCAL=http://10.0.2.2/cuisinous-backend/public/

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
STRIPE_MERCHANT_IDENTIFIER=ca.cuisinous

# Google Services Configuration
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
GOOGLE_SIGN_IN_CLIENT_ID=your_google_sign_in_client_id_here

# Environment
# Options: local, development, production
# - local/development: Shows detailed error messages for debugging
# - production: Shows generic error messages to end users
ENVIRONMENT=development
```

### 3. Android Configuration

For Android builds, you also need to set the environment variables in `android/gradle.properties`:

```properties
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
GOOGLE_SIGN_IN_CLIENT_ID=your_google_sign_in_client_id_here
```

**Important:** The `android/gradle.properties` file should NOT be committed to git if it contains secrets. Consider using `android/local.properties` instead or add these keys to your CI/CD environment variables.

### 4. Install Dependencies

After creating the `.env` file, install the Flutter dependencies:

```bash
flutter pub get
```

### 5. Verify Setup

Run the app to ensure environment variables are loaded correctly:

```bash
flutter run
```

## Environment Variables Reference

| Variable | Description | Required |
|----------|-------------|----------|
| `API_BASE_URL` | Production API base URL | Yes |
| `API_BASE_URL_LOCAL` | Local development API base URL | No |
| `STRIPE_PUBLISHABLE_KEY` | Stripe publishable key | Yes |
| `STRIPE_MERCHANT_IDENTIFIER` | Stripe merchant identifier | Yes |
| `GOOGLE_MAPS_API_KEY` | Google Maps API key | Yes |
| `GOOGLE_SIGN_IN_CLIENT_ID` | Google Sign-In client ID | Yes |
| `ENVIRONMENT` | Environment type: `local`, `development`, or `production`. Affects error handling: dev shows detailed errors, prod shows generic messages | Yes |


## Files Modified

The following files have been updated to use environment variables:

- `lib/main.dart` - Stripe configuration
- `lib/core/constants/app_consts.dart` - API base URL
- `android/app/build.gradle.kts` - Android manifest placeholders
- `android/app/src/main/AndroidManifest.xml` - Android meta-data values

## Environment-Based Error Handling

The app's error handling behavior changes based on the `ENVIRONMENT` variable:

### Development Mode (`local` or `development`)
- Shows **detailed error messages** including status codes and server responses
- Helps developers debug issues quickly
- **Use for:** Local development, testing, debugging

### Production Mode (`production`)
- Shows **generic error messages** to end users
- Hides technical details for better UX and security
- Unknown server errors display: "Server error. Please try again later."
- **Use for:** Production releases, app store builds

**Example `.env` configurations:**

```env
# For local development
ENVIRONMENT=local

# For development/staging servers
ENVIRONMENT=development

# For production releases
ENVIRONMENT=production
```

## Security Notes


1. **Never commit `.env` file** - It's already in `.gitignore`
2. **Never commit `android/gradle.properties`** - If you add secrets there, add it to `.gitignore`
3. **Use different keys for different environments** - Create separate `.env` files for dev/staging/prod
4. **Rotate secrets regularly** - Update your API keys and tokens periodically
5. **Use CI/CD secrets** - For automated builds, use your CI/CD platform's secret management

## Troubleshooting

### Environment variables not loading

1. Ensure `.env` file exists in the project root
2. Verify `.env` is listed in `pubspec.yaml` assets section
3. Run `flutter clean` and `flutter pub get`
4. Restart the app

### Android build fails with missing keys

1. Ensure `android/gradle.properties` has the required keys (or use system environment variables)
2. Check that `android/app/build.gradle.kts` correctly references the keys
3. Verify `AndroidManifest.xml` uses the correct placeholder names

