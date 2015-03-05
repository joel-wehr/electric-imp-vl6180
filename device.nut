/******************************************************************************
 * Transcribed to squirrel, originally from:
 * https://github.com/sparkfun/
 *
 * The VL6180x by ST micro is a time of flight range finder that
 * uses pulsed IR light to determine distances from object at close
 * range.  The average range of a sensor is between 0-200mm
 *
 ******************************************************************************/

// Please note that many vendors’ device datasheets specify a 7-bit base
// I²C address. In this case, you will need to bit-shift the address left by
// 1 (ie. multiply it by 2):
const I2C_ADDRESS = 0x29;


i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_100_KHZ);
rangeFinder <- null;


imp.onidle(function() {
    rangeFinder = RangeFinder(i2c, I2C_ADDRESS);

    imp.sleep(0.1); // delay .1s

    // Retrieve manufacture info from device memory
    printIdentification(rangeFinder.getIdentification());

    imp.wakeup(0.5, loop);
});


function loop() {
    // Get Ambient Light level and report in LUX
    server.log("Ambient Light Level(Lux): " + rangeFinder.getAmbientLight(RangeFinder.GAIN_1));

    // Get Distance and report in mm
    server.log("Distance measured(mm): " + rangeFinder.getDistance());

    imp.wakeup(0.5, loop);
}


// Helper function to print all the Module information
function printIdentification(id){
    server.log("Model ID: " + id.model);
    server.log("Model Rev: " + id.modelRevMajor + "." + id.modelRevMinor);
    server.log("Module Rev: " + id.moduleRevMajor + "." + id.moduleRevMindor);
    server.log("Manufacture Date: " + (id.date >> 3) & 0x001F + "/"
        + (id.date >> 8) & 0x000F + "/" + (id.date >> 12) & 0x000F + " Phase: "
        + id.date & 0x0007);
    server.log("Manufacture Time(s): " + (id.time * 2) + "\n\n");
}


// for the VL6180x
class RangeFinder {
    static IDENTIFICATION_MODEL_ID              = "\x0000";
    static IDENTIFICATION_MODEL_REV_MAJOR       = "\x0001";
    static IDENTIFICATION_MODEL_REV_MINOR       = "\x0002";
    static IDENTIFICATION_MODULE_REV_MAJOR      = "\x0003";
    static IDENTIFICATION_MODULE_REV_MINOR      = "\x0004";
    static IDENTIFICATION_DATE                  = "\x0006"; // 16bit value
    static IDENTIFICATION_TIME                  = "\x0008"; // 16bit value

    static SYSTEM_MODE_GPIO0                    = "\x0010";
    static SYSTEM_MODE_GPIO1                    = "\x0011";
    static SYSTEM_HISTORY_CTRL                  = "\x0012";
    static SYSTEM_INTERRUPT_CONFIG_GPIO         = "\x0014";
    static SYSTEM_INTERRUPT_CLEAR               = "\x0015";
    static SYSTEM_FRESH_OUT_OF_RESET            = "\x0016";
    static SYSTEM_GROUPED_PARAMETER_HOLD        = "\x0017";

    static SYSRANGE_START                       = "\x0018";
    static SYSRANGE_THRESH_HIGH                 = "\x0019";
    static SYSRANGE_THRESH_LOW                  = "\x001A";
    static SYSRANGE_INTERMEASUREMENT_PERIOD     = "\x001B";
    static SYSRANGE_MAX_CONVERGENCE_TIME        = "\x001C";
    static SYSRANGE_CROSSTALK_COMPENSATION_RATE = "\x001E";
    static SYSRANGE_CROSSTALK_VALID_HEIGHT      = "\x0021";
    static SYSRANGE_EARLY_CONVERGENCE_ESTIMATE  = "\x0022";
    static SYSRANGE_PART_TO_PART_RANGE_OFFSET   = "\x0024";
    static SYSRANGE_RANGE_IGNORE_VALID_HEIGHT   = "\x0025";
    static SYSRANGE_RANGE_IGNORE_THRESHOLD      = "\x0026";
    static SYSRANGE_MAX_AMBIENT_LEVEL_MULT      = "\x002C";
    static SYSRANGE_RANGE_CHECK_ENABLES         = "\x002D";
    static SYSRANGE_VHV_RECALIBRATE             = "\x002E";
    static SYSRANGE_VHV_REPEAT_RATE             = "\x0031";

    static SYSALS_START                         = "\x0038";
    static SYSALS_THRESH_HIGH                   = "\x003A";
    static SYSALS_THRESH_LOW                    = "\x003C";
    static SYSALS_INTERMEASUREMENT_PERIOD       = "\x003E";
    static SYSALS_ANALOGUE_GAIN                 = "\x003F";
    static SYSALS_INTEGRATION_PERIOD            = "\x0040";

    static RESULT_RANGE_STATUS                  = "\x004D";
    static RESULT_ALS_STATUS                    = "\x004E";
    static RESULT_INTERRUPT_STATUS_GPIO         = "\x004F";
    static RESULT_ALS_VAL                       = "\x0050";
    static RESULT_HISTORY_BUFFER                = "\x0052";
    static RESULT_RANGE_VAL                     = "\x0062";
    static RESULT_RANGE_RAW                     = "\x0064";
    static RESULT_RANGE_RETURN_RATE             = "\x0066";
    static RESULT_RANGE_REFERENCE_RATE          = "\x0068";
    static RESULT_RANGE_RETURN_SIGNAL_COUNT     = "\x006C";
    static RESULT_RANGE_REFERENCE_SIGNAL_COUNT  = "\x0070";
    static RESULT_RANGE_RETURN_AMB_COUNT        = "\x0074";
    static RESULT_RANGE_REFERENCE_AMB_COUNT     = "\x0078";
    static RESULT_RANGE_RETURN_CONV_TIME        = "\x007C";
    static RESULT_RANGE_REFERENCE_CONV_TIME     = "\x0080";

    static READOUT_AVERAGING_SAMPLE_PERIOD      = "\x010A";
    static FIRMWARE_BOOTUP                      = "\x0119";
    static FIRMWARE_RESULT_SCALER               = "\x0120";
    static I2C_SLAVE_DEVICE_ADDRESS             = "\x0212";
    static INTERLEAVED_MODE_ENABLE              = "\x02A3";

    static GAIN_20   = 0x00; // Actual ALS Gain of 20
    static GAIN_10   = 0x01; // Actual ALS Gain of 10.32
    static GAIN_5    = 0x02; // Actual ALS Gain of 5.21
    static GAIN_2_5  = 0x03; // Actual ALS Gain of 2.60
    static GAIN_1_67 = 0x04; // Actual ALS Gain of 1.72
    static GAIN_1_25 = 0x05; // Actual ALS Gain of 1.28
    static GAIN_1    = 0x06; // Actual ALS Gain of 1.01
    static GAIN_40   = 0x07; // Actual ALS Gain of 40


    _address = null;
    _i2c = null;


    constructor(i2c, _address) {
        this._address = registerAddr ;
        this._i2c = i2c;

        this._i2c.write((registerAddr >> 8) & 0xFF); // MSB of register address
        Wire.write(registerAddr & 0xFF); // LSB of register address
        if (this.getRegister(SYSTEM_FRESH_OUT_OF_RESET) != 1) {
            throw "Failed to init.";
        }

        //Required by datasheet
        //http://www.st.com/st-web-ui/static/active/en/resource/technical/document/application_note/DM00122600.pdf
        this.setRegister(0x0207, 0x01);
        this.setRegister(0x0208, 0x01);
        this.setRegister(0x0096, 0x00);
        this.setRegister(0x0097, 0xfd);
        this.setRegister(0x00e3, 0x00);
        this.setRegister(0x00e4, 0x04);
        this.setRegister(0x00e5, 0x02);
        this.setRegister(0x00e6, 0x01);
        this.setRegister(0x00e7, 0x03);
        this.setRegister(0x00f5, 0x02);
        this.setRegister(0x00d9, 0x05);
        this.setRegister(0x00db, 0xce);
        this.setRegister(0x00dc, 0x03);
        this.setRegister(0x00dd, 0xf8);
        this.setRegister(0x009f, 0x00);
        this.setRegister(0x00a3, 0x3c);
        this.setRegister(0x00b7, 0x00);
        this.setRegister(0x00bb, 0x3c);
        this.setRegister(0x00b2, 0x09);
        this.setRegister(0x00ca, 0x09);
        this.setRegister(0x0198, 0x01);
        this.setRegister(0x01b0, 0x17);
        this.setRegister(0x01ad, 0x00);
        this.setRegister(0x00ff, 0x05);
        this.setRegister(0x0100, 0x05);
        this.setRegister(0x0199, 0x05);
        this.setRegister(0x01a6, 0x1b);
        this.setRegister(0x01ac, 0x3e);
        this.setRegister(0x01a7, 0x1f);
        this.setRegister(0x0030, 0x00);

        // Recommended settings from datasheet
        // http://www.st.com/st-web-ui/static/active/en/resource/technical/document/application_note/DM00122600.pdf
        // Enable Interrupts on Conversion Complete (any source)
        this.setRegister(SYSTEM_INTERRUPT_CONFIG_GPIO, (4 << 3)|(4)); // Set GPIO1 high when sample complete
        this.setRegister(SYSTEM_MODE_GPIO1, 0x10); // Set GPIO1 high when sample complete
        this.setRegister(READOUT_AVERAGING_SAMPLE_PERIOD, 0x30); //Set Avg sample period
        this.setRegister(SYSALS_ANALOGUE_GAIN, 0x46); // Set the ALS gain
        this.setRegister(SYSRANGE_VHV_REPEAT_RATE, 0xFF); // Set auto calibration period (Max = 255)/(OFF = 0)
        this.setRegister(SYSALS_INTEGRATION_PERIOD, 0x63); // Set ALS integration time to 100ms
        this.setRegister(SYSRANGE_VHV_RECALIBRATE, 0x01); // perform a single temperature calibration

        // Optional settings from datasheet
        // http://www.st.com/st-web-ui/static/active/en/resource/technical/document/application_note/DM00122600.pdf
        this.setRegister(SYSRANGE_INTERMEASUREMENT_PERIOD, 0x09); // Set default ranging inter-measurement period to 100ms
        this.setRegister(SYSALS_INTERMEASUREMENT_PERIOD, 0x0A); // Set default ALS inter-measurement period to 100ms
        this.setRegister(SYSTEM_INTERRUPT_CONFIG_GPIO, 0x24); // Configures interrupt on ‘New Sample Ready threshold event’

        // Additional settings defaults from community
        this.setRegister(SYSRANGE_MAX_CONVERGENCE_TIME, 0x32);
        this.setRegister(SYSRANGE_RANGE_CHECK_ENABLES, 0x10 | 0x01);
        this.setRegister16(SYSRANGE_EARLY_CONVERGENCE_ESTIMATE, 0x7B);
        this.setRegister16(SYSALS_INTEGRATION_PERIOD, 0x64);

        this.setRegister(READOUT_AVERAGING_SAMPLE_PERIOD,0x30);
        this.setRegister(SYSALS_ANALOGUE_GAIN,0x40);
        this.setRegister(FIRMWARE_RESULT_SCALER,0x01);

        imp.sleep(1);
    }


    function setRegister(registerAddr, data) {
        this._i2c.write(this._addr, registerAddr, data); // Data/setting to be sent to device.
    }


    function setRegister16(registerAddr, data) {
        local temp = (data >> 8) & 0xff;
        this._i2c.write(this._addr, registerAddr, temp);
        temp = data & 0xff;
        this._i2c.write(this._addr, registerAddr, temp);
    }


    // returns unsigned 8 bit
    function getRegister(registerAddr) {
        return this._i2c.read(this._address, registerAddr, 1);
    }


    // returns unsigned 16 bit
    function getRegister16() {
        // just in case we need to switch the parity
        local data_high = this._i2c.read(this._address, registerAddr, 1);
        local data_low = this._i2c.read(this._address, registerAddr, 1);
        local data = (data_high << 8) | data_low;
        return data;
    }


    function getDistance() {
        local distance;
        this.setRegister(SYSRANGE_START, 0x01); //Start Single shot mode
        imp.sleep(10);
        distance = this.getRegister(RESULT_RANGE_VAL);
        this.setRegister(SYSTEM_INTERRUPT_CLEAR, 0x07);
        return distance;
    }


    function changeAddress(address) {
        this._address = address;
        this.setRegister(I2C_SLAVE_DEVICE_ADDRESS, this._address);

        return this.getRegister(I2C_SLAVE_DEVICE_ADDRESS);
    }


    function getAmbientLight(gain) {
        local alsGain;
        local alsIntegrationPeriod;
        local alsIntegrationPeriodRaw;
        local alsRaw;
        local alsCalculated;
        // First load in Gain we are using, do it everytime incase someone changes it on us.
        // Note: Upper nibble shoudl be set to 0x4 i.e. for ALS gain of 1.0 write 0x46
        this.setRegister(SYSALS_ANALOGUE_GAIN, (0x40 | gain)); // Set the ALS gain

        // Start ALS Measurement
        this.setRegister(SYSALS_START, 0x01);

        imp.sleep(100); // give it time...

        this.setRegister(SYSTEM_INTERRUPT_CLEAR, 0x07);

        // Retrieve the Raw ALS value from the sensoe
        alsRaw = this.getRegister16bit(RESULT_ALS_VAL);

        // Get Integration Period for calculation, we do this everytime incase someone changes it on us.
        alsIntegrationPeriodRaw = this.getRegister16bit(SYSALS_INTEGRATION_PERIOD);

        alsIntegrationPeriod = 100.0 / alsIntegrationPeriodRaw;

        // Calculate actual LUX from Appnotes

        alsGain = 0.0;

        switch (gain){
            case GAIN_20: alsGain = 20.0; break;
            case GAIN_10: alsGain = 10.32; break;
            case GAIN_5: alsGain = 5.21; break;
            case GAIN_2_5: alsGain = 2.60; break;
            case GAIN_1_67: alsGain = 1.72; break;
            case GAIN_1_25: alsGain = 1.28; break;
            case GAIN_1: alsGain = 1.01; break;
            case GAIN_40: alsGain = 40.0; break;
        }

        // Calculate LUX from formula in AppNotes

        alsCalculated = 0.32 * (alsRaw / alsGain) * alsIntegrationPeriod;

        return alsCalculated;
    }


    function getIdentification() {
        return {
            model: this.getRegister(IDENTIFICATION_MODEL_ID),
            modelRevMajor: this.getRegister(IDENTIFICATION_MODEL_REV_MAJOR),
            modelRevMinor: this.getRegister(IDENTIFICATION_MODEL_REV_MINOR),
            moduleRevMajor: this.getRegister(IDENTIFICATION_MODULE_REV_MAJOR),
            moduleRevMinor: this.getRegister(IDENTIFICATION_MODULE_REV_MINOR),
            date: this.getRegister16bit(IDENTIFICATION_DATE),
            time: this.getRegister16bit(IDENTIFICATION_TIME)
        };
    }
}
