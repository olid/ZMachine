//
//  Extensions.swift
//  ZMachine
//

typealias Char = Int
typealias ZChar = Int
typealias Word = Int
typealias CharString = [Char]

extension Int {
    var toBinaryString: String {
        return (0...15).reduce("") {
            $0 + "\( self >> (15 - $1) & 0x1 )"
        }
    }
}

class when<T> {
    let itIs: () -> Bool
    var thenFn: (() -> T)!
    
    init(_ itIs: () -> Bool) {
        self.itIs = itIs
    }
    
    func then(fn: () -> T) -> when {
        thenFn = fn
        return self
    }
    
    func otherwise(elseFn: () -> T) -> T {
        if itIs() {
            return thenFn()
        } else {
            return elseFn()
        }
    }
}

extension String {
    var charString: CharString {
        return self.utf8.map {
            return Char($0)
        }
    }
}

extension Array {
    static func length(array: Array) -> Int {
        return array.count
    }
    
    static func sub(a: Array, start: Int, length: Int) -> Array {
        return Array(a[start..<(start + length)])
    }
    
    static func fold_left<E, A>(array: [E], acc: A, map: (A, E) -> A) -> A {
        return array.reduce(acc, combine: map)
    }
    
    var head: Element? {
        return self.first
    }
    
    var tail: [Element] {
        return self.count > 1
            ? [Element](self.dropFirst())
            : []
    }
    
    var headtail: (Element?, [Element]) {
        return (self.head, self.tail)
    }
}

func not(fn: () -> Bool) -> Bool {
    return !fn()
}

struct Map<K: Hashable, V: Hashable> {
    typealias DictType = [K: V]
    let values: DictType
    
    init() {
        self.values = DictType()
    }
    
    init(values: DictType) {
        self.values = values
    }
    
    func find(key: K) -> V {
        return values[key]!
    }
    
    func mem(key: K) -> Bool {
        return values.keys.contains(key)
    }
    
    func add(key: K, value: V) -> Map<K, V> {
        var newDictionary = values
        newDictionary[key] = value
        
        return Map(values: newDictionary)
    }
}

infix operator |< { associativity right precedence 90 }
func |<<T>(left: T, right: [T]) -> [T] {
    return [left] + right
}

infix operator >< { associativity right precedence 90 }
func ><<T>(left: [T], right: [T]) -> [T] {
    return left + right
}

infix operator >| { associativity right precedence 90 }
func >|<T>(left: [T], right: T) -> [T] {
    return left + [right]
}




