## Asset Catalog Tinkerer

**Important: if you want to open asset catalogs from iOS 12, macOS Mojave, watchOS 5 or tvOS 12 you need to run the app in macOS Mojave. Apple introduced a new compression to asset catalogs so it's not possible to extract them with previous versions. An update for macOS Mojave will be released in the future with Dark Mode support.**

An app that lets you open `.car` files and browse/extract their images, or preview them on Finder with QuickLook.

[⬇ Download Latest Release](https://github.com/insidegui/AssetCatalogTinkerer/raw/master/releases/AssetCatalogTinkerer_latest.zip)

You can also install it using [Homebrew Cask](https://caskroom.github.io), simply `brew cask install asset-catalog-tinkerer`!

![screenshot](https://raw.github.com/insidegui/AssetCatalogTinkerer/master/screenshot.png)

### QuickLook PlugIn

The app also includes a QuickLook PlugIn so you can see previews of asset catalogs in QuickLook.

![quicklook thumbnail](./quicklook_thumb.png)

---

### How to use

The app can open any `.car` file, usually located within an app's `Resources` directory.

Once you have an asset catalog opened, you can drag individual assets out or export the entire catalog / selected images to a directory.

### Supported file types

Since version 2.2, Asset Catalog Tinkerer can now read theme store files, not only catalog files.

Theme store files contain assets for UI components, you can find examples of them in `/System/Library/CoreServices/SystemAppearance.bundle`. The app also supports ProKit's theme stores found inside `ProKit.framework`, `LunaKit.framework` and other folders within pro apps.

![screenshot2](https://raw.github.com/insidegui/AssetCatalogTinkerer/master/screenshot_themestore.png)