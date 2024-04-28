// Expr.swift
// This is a generated file.

protocol Expr {
    func accept<V: Visitor>(_ visitor: V) -> V.R
}

protocol Visitor {
	associatedtype R

	func visitGroupingExpr(_ Expr: Grouping) -> R
	func visitLiteralExpr(_ Expr: Literal) -> R
	func visitBinaryExpr(_ Expr: Binary) -> R
	func visitUnaryExpr(_ Expr: Unary) -> R
}

struct Grouping: Expr {
	var expression: Expr

	func accept<V: Visitor>(_ visitor: V) -> V.R { return visitor.visitGroupingExpr(self) }
}

struct Literal: Expr {
	var value: Optional<Any>

	func accept<V: Visitor>(_ visitor: V) -> V.R { return visitor.visitLiteralExpr(self) }
}

struct Binary: Expr {
	var left: Expr
	var op: Token
	var right: Expr

	func accept<V: Visitor>(_ visitor: V) -> V.R { return visitor.visitBinaryExpr(self) }
}

struct Unary: Expr {
	var op: Token
	var right: Expr

	func accept<V: Visitor>(_ visitor: V) -> V.R { return visitor.visitUnaryExpr(self) }
}

