public struct NpyData<T: DataType> {
    public let shape: [Int]
    public let elements: [T]
    public let isFortranOrder: Bool
    
    init(shape: [Int], elements: [T], isFortranOrder: Bool) {
        self.shape = shape
        self.elements = elements
        self.isFortranOrder = isFortranOrder
    }
}
