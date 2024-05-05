// Stmt.swift
// This is a generated file.

protocol Stmt {
    func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR
}

protocol StmtVisitor {
	associatedtype StmtR

	func visitBlockStmt(_ Stmt: BlockStmt) throws -> StmtR
	func visitVarStmt(_ Stmt: VarStmt) throws -> StmtR
	func visitExpressionStmt(_ Stmt: ExpressionStmt) throws -> StmtR
	func visitPrintStmt(_ Stmt: PrintStmt) throws -> StmtR
}

struct BlockStmt: Stmt {
	var statements: [Stmt?]

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitBlockStmt(self)
	}
}

struct VarStmt: Stmt {
	var name: Token
	var initializer: Expr?

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitVarStmt(self)
	}
}

struct ExpressionStmt: Stmt {
	var expression: Expr

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitExpressionStmt(self)
	}
}

struct PrintStmt: Stmt {
	var expression: Expr

	func accept<V: StmtVisitor>(_ visitor: V) throws -> V.StmtR {
		return try visitor.visitPrintStmt(self)
	}
}

