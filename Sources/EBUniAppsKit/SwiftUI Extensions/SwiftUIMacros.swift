@attached(member, names: named(horizontalSizeClass), named(verticalSizeClass), named(isIpad))
public macro DeviceDependent() = #externalMacro(module: "EBUniAppsKitMacros", type: "DeviceDependentMacro")
