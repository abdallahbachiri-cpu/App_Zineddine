fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android prepare_screenshots

```sh
[bundle exec] fastlane android prepare_screenshots
```

Copy generated golden tests to Fastlane metadata directories

### android upload_store_screenshots

```sh
[bundle exec] fastlane android upload_store_screenshots
```

Upload screenshots and metadata to the Google Play Store

### android deploy

```sh
[bundle exec] fastlane android deploy
```

Full Deployment (Build AAB, upload everything)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
