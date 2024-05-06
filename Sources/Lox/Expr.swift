// Expr.swift
// This is a generated file.

protocol Expr {
    func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR
}

protocol ExprVisitor {
	associatedtype ExprR

	func visitLiteralExpr(_ Expr: LiteralExpr) throws -> ExprR
	func visitVariableExpr(_ Expr: VariableExpr) throws -> ExprR
	func visitAssignExpr(_ Expr: AssignExpr) throws -> ExprR
	func visitLogicalExpr(_ Expr: LogicalExpr) throws -> ExprR
	func visitBinaryExpr(_ Expr: BinaryExpr) throws -> ExprR
	func visitGroupingExpr(_ Expr: GroupingExpr) throws -> ExprR
	func visitUnaryExpr(_ Expr: UnaryExpr) throws -> ExprR
}

struct LiteralExpr: Expr {
	var value: Optional<Any>

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitLiteralExpr(self)
	}
}

struct VariableExpr: Expr {
	var name: Token

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitVariableExpr(self)
	}
}

struct AssignExpr: Expr {
	var name: Token
	var value: Expr

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitAssignExpr(self)
	}
}

struct LogicalExpr: Expr {
	var left: Expr
	var op: Token
	var right: Expr

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitLogicalExpr(self)
	}
}

struct BinaryExpr: Expr {
	var left: Expr
	var op: Token
	var right: Expr

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitBinaryExpr(self)
	}
}

struct GroupingExpr: Expr {
	var expression: Expr

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitGroupingExpr(self)
	}
}

struct UnaryExpr: Expr {
	var op: Token
	var right: Expr

	func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ExprR {
		return try visitor.visitUnaryExpr(self)
	}
}

