# SwiftNpy
Save/Load NumPy array files in Swift

```swift
let npy = try load(contentsOf: npyUrl)
let shape = npy.shape
let elements: [Float] = npy.elements()
let isFortranOrder = npy.isFortranOrder
try save(npy: npy, to: url)
```

```swift
let npz = try load(contentsOf: npzUrl)
let npy = npz["name-of-array"]
try save(npz: npz to: url)
```

## Suppoted format
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
- [zlib](https://github.com/madler/zlib)
- [Minizip](https://github.com/nmoinvaz/minizip)

are licenced under the [zlib license](http://www.zlib.net/zlib_license.html).

