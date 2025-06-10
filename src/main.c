#include "CH57x_common.h"
#include "CH32EXT.h"

void DebugInit() {
    GPIOA_SetBits(bTXD_0);
    GPIOA_ModeCfg(bRXD_0, GPIO_ModeIN_PU);      // RXD-������������
    GPIOA_ModeCfg(bTXD_0, GPIO_ModeOut_PP_5mA); // TXD-�������������ע������IO������ߵ�ƽ
    UART_Remap(ENABLE, UART_TX_REMAP_PA3, UART_RX_REMAP_PA2);
    UART_DefInit();
    GPIOA_ModeCfg(GPIO_Pin_8 | GPIO_Pin_9, GPIO_ModeIN_PU);//ʹ���˸�λ�ţ�����ʱע�ⲻҪʹ��RST��λ���Ź���
}

int main()
{
    uint8_t i = 0;
    HSECFG_Capacitance(HSECap_18p);
    SetSysClock(CLK_SOURCE_HSE_PLL_100MHz);
    DebugInit();
    ch32ext_init();

    printf("CH32EXT Demo\r\n");
    adcInit(GPIO1);
    pwmInit(GPIO2, 100, 48000, 50);

    pwmSetDuty(GPIO2, 30);

    while(1) {
        uint16_t adc_val = getAdcVal(GPIO1);
        if (adc_val != CH_ERROR) {
            printf("ADC Value: %d\r\n", adc_val);
        } else {
            printf("ADC Read Error\r\n");
        }
        delay_ms(50);
    }
    while(1);
}

