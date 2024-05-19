// Stmt.swift
// This is a generated file.

import Foundation

protocol Stmt {
    var id: UUID { get }
    func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR
}

protocol StmtVisitor {
	associatedtype StmtR

	func visitFunctionStmt(_ Stmt: FunctionStmt) throws -> StmtR
	func visitPrintStmt(_ Stmt: PrintStmt) throws -> StmtR
	func visitWhileStmt(_ Stmt: WhileStmt) throws -> StmtR
	func visitReturnStmt(_ Stmt: ReturnStmt) throws -> StmtR
	func visitExpressionStmt(_ Stmt: ExpressionStmt) throws -> StmtR
	func visitVarStmt(_ Stmt: VarStmt) throws -> StmtR
	func visitBlockStmt(_ Stmt: BlockStmt) throws -> StmtR
	func visitIfStmt(_ Stmt: IfStmt) throws -> StmtR
}

struct FunctionStmt: Stmt {
	var name: Token
	var params: [Token]
	var body: [Stmt?]

	var id: UUID = UUID()

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitFunctionStmt(self)
	}
}

struct PrintStmt: Stmt {
	var expression: Expr

	var id: UUID = UUID()

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitPrintStmt(self)
	}
}

struct WhileStmt: Stmt {
	var condition: Expr
	var body: Stmt

	var id: UUID = UUID()

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitWhileStmt(self)
	}
}

struct ReturnStmt: Stmt {
	var keyword: Token
	var value: Expr?

	var id: UUID = UUID()

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitReturnStmt(self)
	}
}

struct ExpressionStmt: Stmt {
	var expression: Expr

	var id: UUID = UUID()

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitExpressionStmt(self)
	}
}

struct VarStmt: Stmt {
	var name: Token
	var initializer: Expr?

	var id: UUID = UUID()

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitVarStmt(self)
	}
}

struct BlockStmt: Stmt {
	var statements: [Stmt?]

	var id: UUID = UUID()

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitBlockStmt(self)
	}
}

struct IfStmt: Stmt {
	var condition: Expr
	var thenBranch: Stmt
	var elseBranch: Stmt?

	var id: UUID = UUID()

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitIfStmt(self)
	}
}

