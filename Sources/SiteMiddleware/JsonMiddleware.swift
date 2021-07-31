import EnvVars
import Foundation
import HttpPipeline
import Prelude

/// Sends / encodes json data as the response type from incoming requests, finalizing the response.
func respondJson<A: Encodable>(
  envVars: EnvVars
) -> (Conn<HeadersOpen, A>) -> IO<Conn<ResponseEnded, Data>> {
  { conn in
    let encoder = JSONEncoder()
    if envVars.appEnv == .testing {
      encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    }
    let data = try! encoder.encode(conn.data)

    return conn.map(const(data))
      |> writeHeader(.contentType(.json))
      >=> writeHeader(.contentLength(data.count))
      >=> closeHeaders
      >=> end
  }
}
