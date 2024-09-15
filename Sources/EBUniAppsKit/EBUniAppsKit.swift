public struct EBUniAppsKit {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

@attached(member, names: arbitrary)
public macro DeviceDependent() = #externalMacro(module: "EBUniAppsKitMacros", type: "DeviceDependentMacro")
