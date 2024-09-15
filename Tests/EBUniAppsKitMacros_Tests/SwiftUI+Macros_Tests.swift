import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(EBUniAppsKitMacros)
import EBUniAppsKitMacros

let testMacros: [String: Macro.Type] = [
    "DeviceDependent": DeviceDependentMacro.self,
]
#endif

final class EBUniAppsMacrosTests: XCTestCase {
    func testMacro() throws {
        #if canImport(EBUniAppsKitMacros)
        assertMacroExpansion(
            """
            @DeviceDependent
            struct TestStruct: View {
                @Environment(\\.verticalSizeClass) private var verticalSizeClass
                @Environment(\\.horizontalSizeClass) private var horizontalSizeClass
            
                var isIpad: Bool {
                    verticalSizeClass == .regular && horizontalSizeClass == .regular
                }
            }
            """,
            expandedSource: """
            struct TestStruct: View { }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
