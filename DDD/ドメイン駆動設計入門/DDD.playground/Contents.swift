import Foundation

extension String {
    func pregMatche(
        pattern: String,
        options: NSRegularExpression.Options = []
    ) -> Bool {
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: options
        ) else { return false }

        let matches = regex.matches(
            in: self,
            options: [],
            range: NSRange(
                location: 0,
                length: count
            )
        )
        return matches.count > 0
    }
}

enum ServiceError: Error {
    case deffirenceMoneyCurrency
    case shouldOver3CharactersForUserName
    
    var description: String {
        switch self {
        case .deffirenceMoneyCurrency:
            return "通過の単位が違います。"
        case .shouldOver3CharactersForUserName:
            return "ユーザ名は3文字以上です。"
        }
    }
}

// MARK: 第二章 値オブジェクト

// 2.1

struct FullName: Equatable {
    let firstName: String
    let lastName: String
}

let fullName = FullName(
    firstName: "yosei",
    lastName: "yamagishi"
)
print(fullName.firstName)


// 2.2.1

// 値オブジェクトは、不変であるべき
// 値オブジェクトにプロパティを更新するためのふるまいをするメソッドを定義されるべきではない
struct FullNameOfBadEx {
    let firstName: String
    var lastName: String
    
    mutating func changeToLastName(lastName: String) {
        self.lastName = lastName
    }
}

var fullNameOfBadEx = FullNameOfBadEx(
    firstName: "yosei",
    lastName: "yamagishi"
)
fullNameOfBadEx.changeToLastName(lastName: "sato")

// 2.2.2
// 値オブジェクトは、交換可能

var fullName1 = FullName(
    firstName: "yosei",
    lastName: "yamagishi"
)

fullName1 = FullName(
    firstName: "yosei",
    lastName: "sato"
)

// 2.2.3
// 等価性によって比較される

let fullNameA = FullName(
    firstName: "yosei",
    lastName: "yamagishi"
)

let fullNameB = FullName(
    firstName: "yosei",
    lastName: "yamagishi"
)

var isEqualedName = fullNameA == fullNameB
print(isEqualedName)

// 2.3 値オブジェクトにする基準

// リスト2.21
struct FullName2: Equatable {
    let firstName: FirstName
    let lastName: LastName
}

struct FirstName: Equatable {
    let value: String
    
    init?(value: String) {
        if value.isEmpty {
            return nil
        }
        self.value = value
    }
}

struct LastName: Equatable {
    let value: String
    
    init?(value: String) {
        if value.isEmpty {
            return nil
        }
        self.value = value
    }
}

// リスト2.24
struct FullName3: Equatable {
    let firstName: String
    let lastName: String
    
    init?(firstName: String, lastName: String) {
        if !Self.validateName(value: firstName) { return nil }
        if !Self.validateName(value: lastName) { return nil }
        
        self.firstName = firstName
        self.lastName = lastName
    }
    
    // アルファベット限定
    static private func validateName(value: String) -> Bool {
        value.pregMatche(pattern: "^[a-zA-Z]+$")
    }
}

// リスト2.25
struct Name: Equatable {
    let value: String
    
    init?(value: String) {
        if !Self.validateName(value: value) { return nil }
        self.value = value
    }
    
    // アルファベット限定
    static private func validateName(value: String) -> Bool {
        value.pregMatche(pattern: "^[a-zA-Z]+$")
    }
}

// リスト2.26
struct FullName4: Equatable {
    let firstName: Name
    let lastName: Name
    
    init?(firstName: Name, lastName: Name) {
        self.firstName = firstName
        self.lastName = lastName
    }
}

// リスト2.27,2.28
struct Money: Equatable {
    private let amount: Float
    private let currency: String
    
    init(amount: Float, currency: String){
        self.amount = amount
        self.currency = currency
    }
    
    func add(money: Money) throws -> Money {
        if currency != money.currency {
            throw ServiceError.deffirenceMoneyCurrency
        }
        return Money(
            amount: self.amount + money.amount,
            currency: currency
        )
    }
}

// リスト2.29
let myMoney = Money(amount: 1000, currency: "JPY")
let allowance = Money(amount: 3000, currency: "JPY")

do {
    var result = try myMoney.add(money: allowance)
    print(result)
} catch {
    print(error)
}

// リスト2.31
let jpy = Money(amount: 1000, currency: "JPY")
let usd = Money(amount: 3000, currency: "USD")

do {
    var result = try jpy.add(money: usd)
    print(result)
} catch {
    print(error)
}

// リスト2.35
struct ModelNumber: Equatable {
    let productCode: String
    let branch: String
    let lot: String
    
    func toString() -> String {
        productCode + "-" + branch + "-" + lot
    }
    
}

// リスト2.38, 2.41, 2.46
struct UserName: Equatable {
    let value: String
    
    init(value: String) throws {
        if value.count < 3 {
            throw ServiceError.shouldOver3CharactersForUserName
        }
        
        self.value = value
    }
}

do {
    let userName = try UserName(value: "佐々")
    print(userName)
} catch {
    print(error)
}

// リスト2.40
struct UserId: Equatable {
    let value: String
}

// リスト2.42, 2.43
struct User: Equatable {
    let userId: UserId = UserId(value: "")
    let name: UserName = try! UserName(value: "")
    
    func createUser(name: UserName) -> User {
        var user = User()
        // コンパイルエラー！
        // user.id = name
        return user
    }
}

// MARK: 第三章 エンティティ
