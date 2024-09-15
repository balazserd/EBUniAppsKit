import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

public struct DeviceDependentMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw Error.notAStruct
        }
        
        guard structDecl.inheritanceClause?.inheritedTypes
            .compactMap({ $0.type.as(IdentifierTypeSyntax.self) })
            .first(where: { $0.name.text == "View" }) != nil else {
            throw Error.missingViewConformance
        }
        
        var horizontalSizeClassMember = try VariableDeclSyntax("@Environment(\\.horizontalSizeClass) var horizontalSizeClass")
        var verticalSizeClassMember = try VariableDeclSyntax("@Environment(\\.verticalSizeClass) var verticalSizeClass")
        var isIpadMember = try VariableDeclSyntax("var isIpad: Bool { verticalSizeClass == .regular && horizontalSizeClass == .regular }")
        
        return [
            horizontalSizeClassMember,
            verticalSizeClassMember,
            isIpadMember
        ].compactMap { DeclSyntax($0) }
    }
    
    public enum Error: String, Swift.Error {
        case notAStruct = "The macro can only be attached to structs!"
        case missingViewConformance = "The type to which the macro is attached does not conform to View!"
    }
}
