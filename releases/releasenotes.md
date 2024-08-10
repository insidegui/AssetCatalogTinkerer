### Support for SVG Assets

This version introduces support for reading and exporting SVG assets, including SF Symbols embedded in asset catalogs. Thanks a bunch to [@zats](https://github.com/zats) for making this happen!

### Command-Line Tool

The new ‘act’ command line tool is here to help you get information and extract asset catalogs right from your command line.

You can find it in the ‘Contents/MacOS’ directory of Asset Catalog Tinkerer.app.

To make it even easier to use, you can set an alias for it in your favorite shell, like this for zsh:

`echo "\nalias act='/Applications/Asset\ Catalog\ Tinkerer.app/Contents/MacOS/act'" >> ~/.zshrc`

### Raycast Integration

There is a new [Raycast extension](https://www.raycast.com/chrismessina/asset-catalog-extractor) that leverages the `act` tool, allowing for easy extraction of asset catalogs in Raycast. Thanks [@chrismessina](https://github.com/chrismessina) for making this happen!
