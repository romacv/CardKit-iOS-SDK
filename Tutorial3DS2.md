# Integration 3DS2 SDK

## 3DS2

For integration 3DS2 SDK:

1. Download and add ThreeDSSDK.xcframework in a project;

<div align="center">
  <img src="./images/3DS2/add_framework.png" width="600"/>
</div>

2. Mark ThreeDSSDK.xcframework as `Embed & Sign` in tagrete -> general;

<div align="center">
  <img src="./images/3DS2/setting_framework.png" width="600"/>
</div>

3. Import ThreeDSSDK.

```swift
import ThreeDSSDK
...
```