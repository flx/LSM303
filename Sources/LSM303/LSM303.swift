import SwiftyGPIO

let Address_Acc   = (0x32 >> 1)
let Address_Mag   = (0x3C >> 1)

public enum AccelRegisters:UInt8 {
        case Ctrl_Reg1_A     = 0x20
        case Ctrl_Reg2_A     = 0x21
        case Ctrl_Reg3_A     = 0x22
        case Ctrl_Reg4_A     = 0x23
        case Ctrl_Reg5_A     = 0x24
        case Ctrl_Reg6_A     = 0x25
        case Reference_A     = 0x26
        case Status_Reg_A    = 0x27
        case Out_X_L_A       = 0x28
        case Out_X_H_A       = 0x29
        case Out_Y_L_A       = 0x2A
        case Out_Y_H_A       = 0x2B
        case Out_Z_L_A       = 0x2C
        case Out_Z_H_A       = 0x2D
        case Fifo_Ctrl_Reg_A = 0x2E
        case Fifo_Src_Reg_A  = 0x2F
        case Int1_CFG_A      = 0x30
        case Int1_Source_A   = 0x31
        case Int1_THS_A      = 0x32
        case Int1_Duration_A = 0x33
        case Int2_CFG_A      = 0x34
        case Int2_Source_A   = 0x35
        case Int2_THS_A      = 0x36
        case Int2_Duration_A = 0x37
        case Click_CFG_A     = 0x38
        case Click_Src_A     = 0x39
        case Click_THS_A     = 0x3A
        case Time_Limit_A    = 0x3B
        case Time_Latency_A  = 0x3C
        case Time_Window_A   = 0x3D
}

public enum AccelScale:UInt8 {
	// The accelertions is only set in two bits, so this code actually sets other flags alongside. Consult data sheet for more information
        case G2  = 0b00000000 // Max is 2G
        case G4  = 0b00010000 // .. 4G
        case G8  = 0b00100000 // .. 8G
        case G16 = 0b00110000 // .. 16G
}

public enum MagRegisters : UInt8 {
        case CRA_Reg_M         = 0x00
        case CRB_Reg_M         = 0x01
        case MR_Reg_M          = 0x02
        case Out_X_H_M         = 0x03
        case Out_X_L_M         = 0x04
        case Out_Z_H_M         = 0x05
        case Out_Z_L_M         = 0x06
        case Out_Y_H_M         = 0x07
        case Out_Y_L_M         = 0x08
        case SR_Reg_Mg         = 0x09
        case IRA_Reg_M         = 0x0A
        case IRB_Reg_M         = 0x0B
        case IRC_Reg_M         = 0x0C
        case Temp_Out_H_M      = 0x31
        case Temp_Out_L_M      = 0x32
}

public enum MagGain : UInt8 {
        case Gain_1_3                    = 0x20 // +/- 1.3
        case Gain_1_9                    = 0x40 // +/- 1.9
        case Gain_2_5                    = 0x60 // +/- 2.5
        case Gain_4_0                    = 0x80 // +/- 4.0
        case Gain_4_7                    = 0xA0 // +/- 4.7
        case Gain_5_6                    = 0xC0 // +/- 5.6
        case Gain_8_1                    = 0xE0 // +/- 8.1
}

public struct AccelData {
        public var x, y, z : Float
}

public struct MagData {
        public var x, y, z : Float
}

public class LSM303 {
        var i2c : I2CInterface
        public var accel : AccelData = AccelData(x: 0, y: 0, z: 0)
        public var mag   : MagData   = MagData(x: 0, y: 0, z: 0)
        var magGain : MagGain = MagGain.Gain_1_3
        var accScale : AccelScale = AccelScale.G2

        public convenience init() {self.init(for:.RaspberryPi3)}
        public init(for board: SupportedBoard) {
                let i2cs = SwiftyGPIO.hardwareI2Cs(for:board)!
                self.i2c = i2cs[1] // not sure what i2cs[0] is ...
                // Enable the accelerometer
                i2c.writeByte(Address_Acc, command: AccelRegisters.Ctrl_Reg1_A.rawValue, value: 0x27);
                // Enable the magnetometer
                i2c.writeByte(Address_Mag, command: MagRegisters.MR_Reg_M.rawValue, value: 0x00);

                accel = AccelData(x: 0, y: 0, z: 0)
                mag   = MagData(x: 0, y: 0, z: 0)
        }

        public func read() {
                // Read acceleration
		let xlo : UInt8 = i2c.readByte(Address_Acc, command: AccelRegisters.Out_X_L_A.rawValue); // Wire.read();
                let xhi : UInt8 = i2c.readByte(Address_Acc, command: AccelRegisters.Out_X_H_A.rawValue); // Wire.read();
                let ylo : UInt8 = i2c.readByte(Address_Acc, command: AccelRegisters.Out_Y_L_A.rawValue); // Wire.read();
                let yhi : UInt8 = i2c.readByte(Address_Acc, command: AccelRegisters.Out_Y_H_A.rawValue); // Wire.read();
                let zlo : UInt8 = i2c.readByte(Address_Acc, command: AccelRegisters.Out_Z_L_A.rawValue); // Wire.read();
                let zhi : UInt8 = i2c.readByte(Address_Acc, command: AccelRegisters.Out_Z_H_A.rawValue); // Wire.read();
                
		var g : Float = 1000.0
                switch (self.accScale) {
                        case .G2  : g =  1000.0 // LSB/g from the data sheet
                        case .G4  : g =  2000.0
                        case .G8  : g =  4000.0
                        case .G16 : g = 12000.0
                }
                accel.x = Float(((Int16(xhi) << 8) | Int16(xlo)) >> 4) / g
                accel.y = Float(((Int16(yhi) << 8) | Int16(ylo)) >> 4) / g
                accel.z = Float(((Int16(zhi) << 8) | Int16(zlo)) >> 4) / g
		
		// Read magnetometer
                i2c.writeByte(Address_Mag, value: MagRegisters.Out_X_H_M.rawValue)
                let axlo : UInt8 = i2c.readByte(Address_Mag, command: MagRegisters.Out_X_L_M.rawValue); // Wire.read();
                let axhi : UInt8 = i2c.readByte(Address_Mag, command: MagRegisters.Out_X_H_M.rawValue); // Wire.read();
                let aylo : UInt8 = i2c.readByte(Address_Mag, command: MagRegisters.Out_Y_L_M.rawValue); // Wire.read();
                let ayhi : UInt8 = i2c.readByte(Address_Mag, command: MagRegisters.Out_Y_H_M.rawValue); // Wire.read();
                let azlo : UInt8 = i2c.readByte(Address_Mag, command: MagRegisters.Out_Z_L_M.rawValue); // Wire.read();
                let azhi : UInt8 = i2c.readByte(Address_Mag, command: MagRegisters.Out_Z_H_M.rawValue); // Wire.read();
                
		var mxy : Float = 1.0
		var mz  : Float = 1.0
		switch (self.magGain) {
			case .Gain_1_3 : mxy = 1100.0; mz = 980.0 // LSB/gauss
                        case .Gain_1_9 : mxy =  855.0; mz = 760.0
                        case .Gain_2_5 : mxy =  670.0; mz = 600.0
                        case .Gain_4_0 : mxy =  450.0; mz = 400.0
                        case .Gain_4_7 : mxy =  400.0; mz = 355.0
                        case .Gain_5_6 : mxy =  330.0; mz = 295.0
                        case .Gain_8_1 : mxy =  230.0; mz = 205.0
		}
		mag.x = Float((Int16(axhi) << 8) | Int16(axlo)) / mxy
                mag.y = Float((Int16(ayhi) << 8) | Int16(aylo)) / mxy
                mag.z = Float((Int16(azhi) << 8) | Int16(azlo)) / mz
        }

        public func setMagGain(gain: MagGain) {
                self.magGain = gain
                i2c.writeByte(Address_Mag, command: MagRegisters.CRB_Reg_M.rawValue, value: gain.rawValue)
        }

        public func setAccScale(scale: AccelScale) {
                self.accScale = scale
                i2c.writeByte(Address_Acc, command: AccelRegisters.Ctrl_Reg4_A.rawValue, value: scale.rawValue)
        }
}
