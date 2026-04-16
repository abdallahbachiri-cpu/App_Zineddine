# Environment Variables Setup

## Quick Start

1. **Create `.env` file** in the project root:
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env`** with your actual secrets (see `.env.example` for format)

3. **For Android builds**, also update `android/gradle.properties` with:
   ```properties
   STRIPE_PUBLISHABLE_KEY=your_key_here
   GOOGLE_MAPS_API_KEY=your_key_here
   GOOGLE_SIGN_IN_CLIENT_ID=your_client_id_here
   ```

4. **Install dependencies**:
   ```bash
   flutter pub get
   ```

## Required Environment Variables

All secrets have been migrated to environment variables. See `.env.example` for the complete list.

## Files Using Environment Variables

- ✅ `lib/main.dart` - Stripe configuration
- ✅ `lib/core/constants/app_consts.dart` - API base URL
- ✅ `android/app/build.gradle.kts` - Android manifest placeholders
- ✅ `android/app/src/main/AndroidManifest.xml` - Android meta-data

## Important

- **Never commit `.env` file** - It's in `.gitignore`
- **Keep your secrets secure** - Use different keys for dev/staging/prod
- **See `ENV_SETUP.md`** for detailed documentation

