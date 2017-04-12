public struct Npy<T: DataType> {
    public let shape: [Int]
    public let elements: [T]
    public let numpyDataType: NumpyDataType
    public let isFortranOrder: Bool
    
    init(shape: [Int], elements: [T], numpyDataType: NumpyDataType, isFortranOrder: Bool) {
        self.shape = shape
        self.elements = elements
        self.numpyDataType = numpyDataType
        self.isFortranOrder = isFortranOrder
    }
}
