## Asset Catalog Tinkerer

Asset Catalog Tinkerer lets you open asset catalog files (`.car`) and view the images and colors that they contain. You can also copy and export individual assets out or export all assets from an asset catalog.

[⬇ Download and contribute with any amount on Gumroad](https://insidegui.gumroad.com/l/AssetCatalogTinkerer)

[⬇ Download Latest Release](https://github.com/insidegui/AssetCatalogTinkerer/raw/main/releases/AssetCatalogTinkerer_latest.zip)

You can also install it with [Homebrew](https://brew.sh) by running `brew install asset-catalog-tinkerer`!

![screenshot](https://raw.github.com/insidegui/AssetCatalogTinkerer/master/screenshot.png)

### Supported Asset Types

Asset Catalog Tinkerer supports:
- **Images**: PNG, SVG, and other image formats including @2x/@3x retina variants
- **Colors**: Named colors are displayed as color swatches and can be exported as JSON files containing RGB/hex values

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
