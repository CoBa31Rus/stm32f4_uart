
#include "stm32f4xx.h"


//~ void rcc_init_168mHz(void)
//~ {
	//~ SCB->CPACR |= (3UL << 20) | (3UL << 22);
	//~ RCC->CR |= RCC_CR_HSEON;
	//~ while(!(RCC->CR & RCC_CR_HSERDY));
	//~ RCC->PLLCFGR &= ~(RCC_PLLCFGR_PLLN | RCC_PLLCFGR_PLLM);
	//~ RCC->PLLCFGR |= RCC_PLLCFGR_PLLSRC_HSE | (4 << RCC_PLLCFGR_PLLM_Pos) | (168 << RCC_PLLCFGR_PLLN_Pos);
	//~ RCC->CR |= RCC_CR_PLLON;
	//~ while(!(RCC->CR & RCC_CR_PLLRDY));
	//~ FLASH->ACR = FLASH_ACR_PRFTEN | FLASH_ACR_ICEN | FLASH_ACR_DCEN | (5 << FLASH_ACR_LATENCY_Pos);
	//~ RCC->CFGR = RCC_CFGR_PPRE1_DIV4 | RCC_CFGR_PPRE2_DIV2 | RCC_CFGR_SW_PLL;
	//~ while((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_PLL);
//~ }

int main(void)
{
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
	GPIOA->MODER |= GPIO_MODER_MODE9_1 | GPIO_MODER_MODE10_1;
	GPIOA->AFR[1] |= (7 << 4) | (7 << 8);
	RCC->APB2ENR |= RCC_APB2ENR_USART1EN;
	USART1->BRR = 0x683;
	USART1->CR1 |= USART_CR1_TE | USART_CR1_UE;
	for(;;)
	{
		for(uint16_t i = 0; i < 30000; i++);
		if(USART1->SR & USART_SR_TXE)
		{
			USART1->DR = 0x41;
		}
	}
}
