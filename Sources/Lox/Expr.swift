// Expr.swift
// This is a generated file.

protocol Expr {
    func accept<V: Visitor>(_ visitor: V) throws -> V.R
}

protocol Visitor {
	associatedtype R

	func visitBinaryExpr(_ Expr: Binary) throws -> R
	func visitGroupingExpr(_ Expr: Grouping) throws -> R
	func visitLiteralExpr(_ Expr: Literal) throws -> R
	func visitUnaryExpr(_ Expr: Unary) throws -> R
}

struct Binary: Expr {
	var left: Expr
	var op: Token
	var right: Expr

	func accept<V: Visitor>(_ visitor: V) throws -> V.R {
		return try visitor.visitBinaryExpr(self)
	}
}

struct Grouping: Expr {
	var expression: Expr

	func accept<V: Visitor>(_ visitor: V) throws -> V.R {
		return try visitor.visitGroupingExpr(self)
	}
}

struct Literal: Expr {
	var value: Optional<Any>

	func accept<V: Visitor>(_ visitor: V) throws -> V.R {
		return try visitor.visitLiteralExpr(self)
	}
}

struct Unary: Expr {
	var op: Token
	var right: Expr

	func accept<V: Visitor>(_ visitor: V) throws -> V.R {
		return try visitor.visitUnaryExpr(self)
	}
}

