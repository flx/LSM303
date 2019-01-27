# LSM303

A Swift driver for the LSM303DLHC controller over I2C, using SwiftyGPIO. The code has been tested with the FLORA sensor sold by Adafruit (https://www.adafruit.com/product/1247).

```swift
import Foundation
import LSM303

print("start")
let lsm303 = LSM303(for: .RaspberryPi3)
lsm303.setAccScale(scale: .G2)
lsm303.setMagGain(gain: .GAIN_1_3)

while (true) {
        lsm303.read()
        print("accel \(lsm303.accel.x) \(lsm303.accel.y) \(lsm303.accel.z) mag \(lsm303.mag.x) \(lsm303.mag.y) \(lsm303.mag.z)")
}
```
