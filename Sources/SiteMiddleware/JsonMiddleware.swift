import Foundation
import HttpPipeline
import Prelude

/// Sends / encodes json data as the response type from incoming requests.
func respondJson<A: Encodable>() -> (Conn<HeadersOpen, A>) -> IO<Conn<ResponseEnded, Data>>
{
  { conn in
    let encoder = JSONEncoder()
    let data = try! encoder.encode(conn.data)

    return conn.map(const(data))
      |> writeHeader(.contentType(.json))
      >=> writeHeader(.contentLength(data.count))
      >=> closeHeaders
      >=> end
  }
}
