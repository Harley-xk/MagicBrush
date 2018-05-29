import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    router.group(DeviceInfoMiddleware()) { (router) in
        let sms = SMSController()
        router.post("sms/captcha", use: sms.postCaptcha)
        
        let register = RegisterController()
        router.post("auth/mobile-register", use: register.phoneRegister)
        
        let login = LoginController()
        router.post("auth/login", use: login.accountLogin)
    }
    

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}
