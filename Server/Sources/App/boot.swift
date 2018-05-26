import Vapor
import Crypto
import Random

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    
    let random = try OSRandom().generateData(count: 10)
//    let string = String(data: random, encoding: .utf8)
//    print("Ramdom: \(random.base64EncodedString())")
//
//    var result: [String] = []
//    for _ in 0 ..< 100 {
//        result.append(String.random())
//    }
//    print(result.joined(separator: ", "))
    


}
