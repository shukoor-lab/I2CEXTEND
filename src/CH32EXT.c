#include "CH32EXT.h"

void ch32ext_init() {
    i2c_app_init(MASTER_ADDR);
}

int adcInit(pins pin) {
    uint8_t cmd = 0;
    switch(pin) {
        case GPIO1:
            cmd = ADC1_INIT;
            break;
        case GPIO2:
            cmd = ADC2_INIT;
            break;
        case GPIO3:
            cmd = ADC3_INIT;
            break;
        default:
            return CH_ERROR;
    }
    
    int ret = i2c_write_to(SLAVE_ADDR >> 1, &cmd, 1, true, true);
    return ret == 0 ? CH_OK : CH_ERROR;                       
}

uint16_t getAdcVal(pins pin) {
    uint8_t cmd = 0;
    switch(pin) {
        case GPIO1:
            cmd = ADC1_GETV;
            break;
        case GPIO2:
            cmd = ADC2_GETV;
            break;
        case GPIO3:
            cmd = ADC3_GETV;
            break;
        default:
            return CH_ERROR;
    }
    
    uint8_t data[2] = {0};
    int ret = i2c_write_to(SLAVE_ADDR >> 1, &cmd, 1, true, true);
    if (ret != 0) {
        return CH_ERROR;
    }
    int ret = i2c_read_from(SLAVE_ADDR >> 1, data, sizeof(data), true, 1000);
    if (ret < 0) {
        return CH_ERROR;
    }
    
    return (data[0] << 8) | data[1];
}

int pwmInit(pins pin, uint16_t arr, uint16_t pcr, uint16_t ccp) {
    uint8_t cmd = 0;
    switch(pin) {
        case GPIO1:
            cmd = PWM1_INIT;
            break;
        case GPIO2:
            cmd = PWM2_INIT;
            break;
        case GPIO3:
            cmd = PWM3_INIT;
            break;
        default:
            return CH_ERROR;
    }
    
    uint8_t data[5] = {cmd,
                    (arr >> 8) & 0xFF, 
                    (arr & 0xFF),
                    (pcr >> 8) & 0xFF, 
                    (pcr & 0xFF), 
                    (ccp >> 8) & 0xFF,
                    (ccp & 0xFF)};
    int ret = i2c_write_to(SLAVE_ADDR >> 1, data, sizeof(data), true, true);
    return ret == 0 ? CH_OK : CH_ERROR;                    
}

int pwmSetDuty(pins pin, uint16_t duty) {
    uint8_t cmd = 0;
    switch(pin) {
        case GPIO1:
            cmd = PWM1_SETD;
            break;
        case GPIO2:
            cmd = PWM2_SETD;
            break;
        case GPIO3:
            cmd = PWM3_SETD;
            break;
        default:
            return CH_ERROR;
    }
    
    uint8_t data[3] = {cmd,
                    (duty >> 8) & 0xFF, 
                    (duty & 0xFF)};
    int ret = i2c_write_to(SLAVE_ADDR >> 1, data, sizeof(data), true, true);
    return ret == 0 ? CH_OK : CH_ERROR;                    
}


