cd /Users/alexkorotkov/Library/Developer/Xcode/DerivedData/CardKit-fiasgfecitaeqsckuguntkkqzhuv/Build/Products

# lipo -remove arm64 "Release-iphonesimulator/CardKitCore.framework/CardKitCore" -output "Release-iphonesimulator/CardKitCore.framework/CardKitCore"

# mkdir release

lipo -create -output "release/CardKitCore" "Release-iphoneos/CardKitCore.framework/CardKitCore" "Release-iphonesimulator/CardKitCore.framework/CardKitCore"



