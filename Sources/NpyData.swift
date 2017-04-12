public struct NpyData<T: DataType> {
    let shape: [Int]
    let elements: [T]
    let isFortranOrder: Bool
}
