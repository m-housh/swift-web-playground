import ApplicativeRouter
import CrudRouter
import Foundation
import SharedModels

// TODO: Remove this dependency if possible. Also remove from Package.swift
import DatabaseClient

public typealias UserRoute = CRUDRoute<User, DatabaseClient.InsertUserRequest, DatabaseClient.UpdateUserRequest>
public typealias UserRouter = Router<UserRoute>

extension UserRouter {
  
  public init(
    _ path: String...,
    encoder jsonEncoder: JSONEncoder = .init(),
    decoder jsonDecoder: JSONDecoder = .init()
  ) {
    self = crudRouter(
      path,
      id: .uuid,
      encoder: jsonEncoder,
      decoder: jsonDecoder
    )
  }
}
