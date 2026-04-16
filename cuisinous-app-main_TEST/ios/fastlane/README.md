fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios prepare_screenshots

```sh
[bundle exec] fastlane ios prepare_screenshots
```

Copy generated golden tests to Fastlane screenshots directory

### ios upload_store_screenshots

```sh
[bundle exec] fastlane ios upload_store_screenshots
```

Upload screenshots and metadata to App Store Connect

### ios deploy

```sh
[bundle exec] fastlane ios deploy
```

Full Deployment (Build IPA, upload everything)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
