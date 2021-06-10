# TakeSelfie
An iOS framework that opens the front camera and draws an oval overlay on the center of the screen. When a single face has been included in the overlay, selfie automatically will be taken and saved in photo album.

## Requirements

| TakeSelfie Version | Minimum iOS Target  | Swift Version |
|:-------------------:|:-------------------:|:-------------------:|
| 1.0.0 | 13.0| 5.0 |


#### Privacy

You need to add two privacy keys to your app's Info.plist to allow the usage of the camera and photo library, or your app will crash. 

Add the keys below to the `<dict>` tag of your Info.plist, replacing the strings with the description you want to provide when prompting the user:

```
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Enable Photos access to save selfies.</string>
	<key>NSCameraUsageDescription</key>
	<string>Enable Camera to take selfies.</string>
```

### Adding to your project

[CocoaPods](http://cocoapods.org) is the recommended way to add TakeSelfie to your project.

Add a `pod` entry for TakeSelfie to your Podfile:

```
pod 'TakeSelfie'
```

Install the pod by running:

```
pod install
```

Alternatively, you can download the [latest code version](https://github.com/afzal-hossain-ovi/TakeSelfie/archive/refs/heads/main.zip) directly and import the files to your project.

## Usage

Add `import TakeSelfie` to the top of your controller file.

In the viewController instantiate `TakeSelfieViewController` and present as modal view controller.
```swift
  let selfieViewController = TakeSelfieViewController()
  present(selfieViewController, animated: true)
```

### Other usage options

You can also get the captured image using `captureImage` callback.
```swift
  selfieViewController.captureImage = { image in
      imageView.image = image
  }
  
```
