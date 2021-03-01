# BlueBillywigPlayerSDK

[![CI Status](https://img.shields.io/travis/weirdall/BlueBillywigPlayerSDK.svg?style=flat)](https://travis-ci.org/weirdall/BlueBillywigPlayerSDK)
[![Version](https://img.shields.io/cocoapods/v/BlueBillywigPlayerSDK.svg?style=flat)](https://cocoapods.org/pods/BlueBillywigPlayerSDK)
[![License](https://img.shields.io/cocoapods/l/BlueBillywigPlayerSDK.svg?style=flat)](https://cocoapods.org/pods/BlueBillywigPlayerSDK)
[![Platform](https://img.shields.io/cocoapods/p/BlueBillywigPlayerSDK.svg?style=flat)](https://cocoapods.org/pods/BlueBillywigPlayerSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

BlueBillywigPlayerSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BlueBillywigPlayerSDK'
```

## Xcode 12 libraries

XCode 12 needs different libraries for an actual iPhone and an iPhone simulator.

### For use on a simulator:

| Version | Library |
|--|--|
| Debug | bin/lib/libBBComponent-<version>-debug-iphonesimulator.a |
| Release | bin/lib/libBBComponent-<version>-iphonesimulator.a

### For use on an iPhone or iPad:

| Version | Library |
|--|--|
| Debug | bin/lib/libBBComponent-<version>-debug-iphoneos.a |
| Release | bin/lib/libBBComponent-<version>.a

### Fat library for XCode 11 and lower

| Version | Library |
|--|--|
| Debug | bin/lib/libBBComponent-<version>-debug-iphone-simulator.a |
| Release | bin/lib/libBBComponent-<version>-iphone-simulator.a

### Release library for only iPhone devices

Release: bin/lib/libBBComponent-<version>.a

## Author

Floris Groenendijk, f.groenendijk@bluebillywig.com

## License

BlueBillywigPlayerSDK is available under the MIT license. See the LICENSE file for more info.
