#ifndef CH32EXT_H
#define CH32EXT_H


#include "CH57x_common.h"
#include "app_i2c.h"

#define     CH_OK               1
#define     CH_ERROR            0

#define     MASTER_ADDR         0x42
#define     SLAVE_ADDR          0x03

// Commands
#define     ADC1_INIT           0xC2
#define     ADC2_INIT           0xC3
#define     ADC3_INIT           0xC4
#define     ADC1_GETV           0xC5
#define     ADC2_GETV           0xC6
#define     ADC3_GETV           0xC7
#define     PWM1_INIT           0xC8
#define     PWM2_INIT           0xC9
#define     PWM3_INIT           0xCA
#define     PWM1_SETD           0xCB
#define     PWM2_SETD           0xCC
#define     PWM3_SETD           0xCD

typedef enum{
    GPIO1 = 1,   // PD6
    GPIO2 = 2,   // PC4  
    GPIO3 = 3,   // PA2
    NONE  = 0,    // NULL PIN
}pins;


void ch32ext_init();
int adcInit(pins pin);
uint16_t getAdcVal(pins pin);
int pwmInit(pins pin, uint16_t arr, uint16_t pcr, uint16_t ccp);
int pwmSetDuty(pins pin, uint16_t duty);

#endif