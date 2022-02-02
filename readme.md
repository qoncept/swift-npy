# SwiftNpy
Save/Load NumPy array files in Swift

```swift
let npy = try Npy(contentsOf: npyUrl)
let shape = npy.shape
let elements: [Float] = npy.elements()
let isFortranOrder = npy.isFortranOrder
try save(npy: npy, to: url)
```

```swift
let npz = try Npz(contentsOf: npzUrl)
let npy = npz["name-of-array"]
try npz.save(to: url)
```

## Suppoted formats
`npy`, `npz` files.

### Bool
`Bool`

### UInt
`UInt8`, `UInt16`, `UInt32`, `UInt64`  
They also can be read as `UInt`

### Int
`Int8`, `Int16`, `Int32`, `Int64`  
They also can be read as `Int`

### Float, Double
`Float`, `Double`

## License

[The MIT License](https://github.com/qoncept/swift-npy/blob/master/LICENSE)
