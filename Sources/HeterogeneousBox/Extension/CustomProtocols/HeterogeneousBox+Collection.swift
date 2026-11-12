extension HeterogeneousBox: Collection {
    public typealias Index = Int
    public typealias Element = Any

    public var startIndex: Index {
        0
    }

    public var endIndex: Index {

        count
    }

    public func index(after i: Index) -> Index {

        i + 1
    }

    /// Creates one type-erased snapshot for iteration.
    public func makeIterator() -> IndexingIterator<[Any]> {
        array.makeIterator()
    }

    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        var result: [T] = []
        result.reserveCapacity(count)
        for element in repeat each value {
            result.append(try transform(element))
        }
        return result
    }

    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
        var result: [T] = []
        for element in repeat each value {
            if let transformed = try transform(element) {
                result.append(transformed)
            }
        }
        return result
    }

    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        var result: [Element] = []
        for element in repeat each value {
            if try isIncluded(element) {
                result.append(element)
            }
        }
        return result
    }

    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        for element in repeat each value {
            if try predicate(element) {
                return element as Any
            }
        }
        return nil
    }

    public func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        for element in repeat each value {
            guard try predicate(element) else { return false }
        }
        return true
    }

    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        for element in repeat each value {
            if try predicate(element) { return true }
        }
        return false
    }
}
