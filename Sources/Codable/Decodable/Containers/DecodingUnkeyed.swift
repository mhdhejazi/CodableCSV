import Foundation

extension ShadowDecoder {
    /// Unkeyed container for the CSV shadow decoder.
    ///
    /// This container iterates through all the records on a CSV or through all the fields in a single record.
    struct UnkeyedContainer: UnkeyedDecodingContainer {
        /// The representation of the decoding process point-in-time.
        private let decoder: ShadowDecoder
        /// The focus for this container.
        private let focus: Focus
        /// Depending on the container's focus, this index represents the next row or the next field to decode.
        private(set) var currentIndex: Int
        /// Creates a unkeyed container only if the passed decoder coding path is valid.
        ///
        /// This initializer only allows the creation of a container when the decoder's coding path:
        /// - is empty (implying a unkeyed container traversing the CSV file).
        /// - has a single coding key with an integer value (impliying a unkeyed container traversing a single CSV row).
        init(decoder: ShadowDecoder) throws {
            switch decoder.codingPath.count {
            case 0:  self.focus = .file
            case 1:  let r = try decoder.codingPath[0].intValue ?! DecodingError.invalidRowKey(codingPath: decoder.codingPath)
                     self.focus = .row(r)
            default: throw DecodingError.invalidContainerRequest(codingPath: decoder.codingPath)
            }
            self.currentIndex = 0
            self.decoder = decoder
        }
        /// Convenience initializer for performance purposes that doesn't check the coding path and expects a row index.
        /// - parameter decoder: The `Decoder` instance in charge of decoding the CSV data.
        internal init(unsafeDecoder decoder: ShadowDecoder, rowIndex: Int) {
            self.decoder = decoder
            self.focus = .row(rowIndex)
            self.currentIndex = 0
        }
        
        var codingPath: [CodingKey] {
            self.decoder.codingPath
        }
        
        var count: Int? {
            switch self.focus {
            case .file: return self.decoder.source.numRows
            case .row: return self.decoder.source.numFields
            }
        }
        
        var isAtEnd: Bool {
            switch self.focus {
            case .file: return self.decoder.source.isRowAtEnd(index: self.currentIndex)
            case .row: return self.decoder.source.isFieldAtEnd(index: self.currentIndex)
            }
        }
    }
}

extension ShadowDecoder.UnkeyedContainer {
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey:CodingKey {
        switch self.focus {
        case .file:
            let rowIndex = self.currentIndex
            let decoder = self.decoder.duplicate(appendingKey: DecodingKey(rowIndex))
            self.currentIndex += 1
            return KeyedDecodingContainer(ShadowDecoder.KeyedContainer<NestedKey>(unsafeDecoder: decoder, rowIndex: rowIndex))
        case .row: throw DecodingError.invalidContainerRequest(codingPath: self.codingPath)
        }
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        switch self.focus {
        case .file:
            let rowIndex = self.currentIndex
            let decoder = self.decoder.duplicate(appendingKey: DecodingKey(rowIndex))
            self.currentIndex += 1
            return Self(unsafeDecoder: decoder, rowIndex: rowIndex)
        case .row: throw DecodingError.invalidContainerRequest(codingPath: self.codingPath)
        }
    }
    
    mutating func superDecoder() throws -> Decoder {
        switch self.focus {
        case .file:
            let result = self.decoder.duplicate(appendingKey: DecodingKey(self.currentIndex))
            self.currentIndex += 1
            return result
        case .row: throw DecodingError.invalidContainerRequest(codingPath: self.codingPath)
        }
    }
}

extension ShadowDecoder.UnkeyedContainer {
    mutating func decode(_ type: String.Type) throws -> String {
        let result = try self.fieldContainer().decode(String.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decodeNil() throws -> Bool {
        let result = try self.fieldContainer().decodeNil()
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        let result = try self.fieldContainer().decode(Bool.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: Int.Type) throws -> Int {
        let result = try self.fieldContainer().decode(Int.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        let result = try self.fieldContainer().decode(Int8.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        let result = try self.fieldContainer().decode(Int16.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        let result = try self.fieldContainer().decode(Int32.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        let result = try self.fieldContainer().decode(Int64.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        let result = try self.fieldContainer().decode(UInt.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        let result = try self.fieldContainer().decode(UInt8.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        let result = try self.fieldContainer().decode(UInt16.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        let result = try self.fieldContainer().decode(UInt32.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        let result = try self.fieldContainer().decode(UInt64.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: Float.Type) throws -> Float {
        let result = try self.fieldContainer().decode(Float.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode(_ type: Double.Type) throws -> Double {
        let result = try self.fieldContainer().decode(Double.self)
        self.currentIndex += 1
        return result
    }
    
    mutating func decode<T>(_ type: T.Type) throws -> T where T:Decodable {
        let result: T
        
        if T.self == Date.self {
            result = try self.fieldContainer().decode(Date.self) as! T
        } else if T.self == Data.self {
            result = try self.fieldContainer().decode(Data.self) as! T
        } else if T.self == Decimal.self {
            result = try self.fieldContainer().decode(Decimal.self) as! T
        } else if T.self == URL.self {
            result = try self.fieldContainer().decode(URL.self) as! T
        } else {
            result = try T(from: self.decoder.duplicate(appendingKey: DecodingKey(self.currentIndex)))
        }
        
        self.currentIndex += 1
        return result
    }
}

extension ShadowDecoder.UnkeyedContainer {
    mutating func decodeIfPresent(_ type: String.Type) throws -> String? {
        try? self.decode(String.self)
    }
    
    mutating func decodeIfPresent(_ type: Bool.Type) throws -> Bool? {
        try? self.decode(Bool.self)
    }
    
    mutating func decodeIfPresent(_ type: Int.Type) throws -> Int? {
        try? self.decode(Int.self)
    }
    
    mutating func decodeIfPresent(_ type: Int8.Type) throws -> Int8? {
        try? self.decode(Int8.self)
    }
    
    mutating func decodeIfPresent(_ type: Int16.Type) throws -> Int16? {
        try? self.decode(Int16.self)
    }
    
    mutating func decodeIfPresent(_ type: Int32.Type) throws -> Int32? {
        try? self.decode(Int32.self)
    }
    
    mutating func decodeIfPresent(_ type: Int64.Type) throws -> Int64? {
        try? self.decode(Int64.self)
    }
    
    mutating func decodeIfPresent(_ type: UInt.Type) throws -> UInt? {
        try? self.decode(UInt.self)
    }
    
    mutating func decodeIfPresent(_ type: UInt8.Type) throws -> UInt8? {
        try? self.decode(UInt8.self)
    }
    
    mutating func decodeIfPresent(_ type: UInt16.Type) throws -> UInt16? {
        try? self.decode(UInt16.self)
    }
    
    mutating func decodeIfPresent(_ type: UInt32.Type) throws -> UInt32? {
        try? self.decode(UInt32.self)
    }
    
    mutating func decodeIfPresent(_ type: UInt64.Type) throws -> UInt64? {
        try? self.decode(UInt64.self)
    }
    
    mutating func decodeIfPresent(_ type: Float.Type) throws -> Float? {
        try? self.decode(Float.self)
    }
    
    mutating func decodeIfPresent(_ type: Double.Type) throws -> Double? {
        try? self.decode(Double.self)
    }
    
    mutating func decodeIfPresent<T>(_ type: T.Type) throws -> T? where T:Decodable {
        try? self.decode(T.self)
    }
}

extension ShadowDecoder.UnkeyedContainer {
    /// CSV unkeyed container focus (i.e. where the container is able to operate on).
    private enum Focus {
        /// The container represents the whole CSV file and each decoding operation outputs a row/record.
        case file
        /// The container represents a CSV row and each decoding operation outputs a field.
        case row(Int)
    }
    
    /// Returns a single value container to decode a single field within a row.
    /// - returns: The single value container holding the field decoding functionality.
    private mutating func fieldContainer() throws -> ShadowDecoder.SingleValueContainer {
        let index: (row: Int, field: Int)
        let decoder: ShadowDecoder
        
        switch self.focus {
        case .row(let rowIndex):
            index = (rowIndex, self.currentIndex)
            decoder = self.decoder.duplicate(appendingKey: DecodingKey(index.field))
        case .file:
            // Values are only allowed to be decoded directly from a nested container in "file level" if the CSV rows have a single column.
            guard self.decoder.source.numFields == 1 else {
                throw DecodingError.invalidNestedRequired(codingPath: self.codingPath)
            }
            index = (self.currentIndex, 0)
            decoder = self.decoder.duplicate(appendingKeys: DecodingKey(index.row), DecodingKey(index.field))
        }
        
        return .init(unsafeDecoder: decoder, rowIndex: index.row, fieldIndex: index.field)
    }
}
