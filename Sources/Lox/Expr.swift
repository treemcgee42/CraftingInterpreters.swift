// Expr.swift
// This is a generated file.

import Foundation

protocol Expr {
    var id: UUID { get }
    func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR
}

protocol ExprVisitor {
	associatedtype ExprR

	func visitSetExpr(_ Expr: SetExpr) throws -> ExprR
	func visitLogicalExpr(_ Expr: LogicalExpr) throws -> ExprR
	func visitUnaryExpr(_ Expr: UnaryExpr) throws -> ExprR
	func visitLiteralExpr(_ Expr: LiteralExpr) throws -> ExprR
	func visitGetExpr(_ Expr: GetExpr) throws -> ExprR
	func visitVariableExpr(_ Expr: VariableExpr) throws -> ExprR
	func visitAssignExpr(_ Expr: AssignExpr) throws -> ExprR
	func visitGroupingExpr(_ Expr: GroupingExpr) throws -> ExprR
	func visitThisExpr(_ Expr: ThisExpr) throws -> ExprR
	func visitBinaryExpr(_ Expr: BinaryExpr) throws -> ExprR
	func visitCallExpr(_ Expr: CallExpr) throws -> ExprR
}

struct SetExpr: Expr {
	var object: Expr
	var name: Token
	var value: Expr

	var id: UUID = UUID()

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitSetExpr(self)
	}
}

struct LogicalExpr: Expr {
	var left: Expr
	var op: Token
	var right: Expr

	var id: UUID = UUID()

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitLogicalExpr(self)
	}
}

struct UnaryExpr: Expr {
	var op: Token
	var right: Expr

	var id: UUID = UUID()

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitUnaryExpr(self)
	}
}

struct LiteralExpr: Expr {
	var value: Optional<Any>

	var id: UUID = UUID()

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitLiteralExpr(self)
	}
}

struct GetExpr: Expr {
	var object: Expr
	var name: Token

	var id: UUID = UUID()

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitGetExpr(self)
	}
}

struct VariableExpr: Expr {
	var name: Token

	var id: UUID = UUID()

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitVariableExpr(self)
	}
}

struct AssignExpr: Expr {
	var name: Token
	var value: Expr

	var id: UUID = UUID()

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitAssignExpr(self)
	}
}

struct GroupingExpr: Expr {
	var expression: Expr

	var id: UUID = UUID()

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitGroupingExpr(self)
	}
}

struct ThisExpr: Expr {
	var keyword: Token

	var id: UUID = UUID()

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitThisExpr(self)
	}
}

struct BinaryExpr: Expr {
	var left: Expr
	var op: Token
	var right: Expr

	var id: UUID = UUID()

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitBinaryExpr(self)
	}
}

struct CallExpr: Expr {
	var callee: Expr
	var paren: Token
	var arguments: [Expr]

	var id: UUID = UUID()

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitCallExpr(self)
	}
}

