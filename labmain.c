/* main.c

   This file written 2024 by Artur Podobas and Pedro Antunes

   For copyright and licensing, see file COPYING */


/* Below functions are external and found in other files. */

extern void print(const char*);
extern void print_dec(unsigned int);
extern void display_string(char*);
extern void time2string(char*,int);
extern void tick(int*);
extern void delay(int);
extern int nextprime( int );

int mytime = 0x5957;
char textstring[] = "text, more text, and even more text!";

int timoutcount = 0;
#define Timer_Base 0x04000020
#define Timer_Status  *((volatile unsigned short *) (Timer_Base + 0x00))
#define Timer_Control *((volatile unsigned short *) (Timer_Base + 0x02))
#define Timer_PeriodL *((volatile unsigned short *) (Timer_Base + 0x04))
#define Timer_PeriodH *((volatile unsigned short *) (Timer_Base + 0x06))
#define Interval 3000000


/* Below is the function that will be called when an interrupt is triggered. */
void handle_interrupt(unsigned cause) 
{}


/* Add your code here for initializing interrupts. */
void labinit(void){
  Timer_PeriodL = (Interval - 1) & 0xFFFF;       // Set the low period of the timer to the interval
  Timer_PeriodH = (Interval >> 16) & 0xFFFF; 
  
  Timer_Status = 0x0; //Reset
  Timer_Control = (1 << 1) | (1 << 2);  // Set CON and START to true 
}

void set_leds(int led_mask) {
  volatile int *p = (volatile int *) 0x04000000; //pointer to the address of the leds
  *p = led_mask & 0x3FF;                         // set the leaset 10 bits of the address to the value of led_mask

}

/** 
  * Set the value of a 7-segment display.
  * display_number: which display to set (0-5)
  * value: which value to display (0-9)
  * Returns: nothing
 */
void set_displays(int display_number, int value) {
  int new_display_number = 0x04000050 + (display_number * 0x10);
  volatile int *p = (volatile int *) new_display_number; // pointer to the address of the display. The value is the base address + (the display number * 0x10)
  if (value == 0) {
    *p = 64;  
  }
  if (value == 1) {
    *p = 121; 
  }
  if (value == 2) {
    *p = 36;  
  }
  if (value == 3) {
    *p = 48;
  }
  if (value == 4) {
    *p = 25;
  }
  if (value == 5) {
    *p = 18;
  }
  if (value == 6) {
    *p = 2;
  }
  if (value == 7) {
    *p = 120;
  }
  if (value == 8) {
    *p = 0;
  }
  if (value == 9) {
    *p = 16;
  }
}
/**
 * Get the state value of switch 
 * Returns 0 or 1 depending on state.
 */
int get_sw (void) {
  volatile int *p = (volatile int *) 0x04000010;
  int val = *p & 0x3ff;
  return val;
}

/**
 * Get the state value of the button
 * Returns 0 or 1 depending on state.
 */
int get_btn (void){
  volatile int *p = (volatile int *) 0x040000d0;
  int val = *p & 0x1;
  return val; 
}


/* Your code goes into main as well as any needed functions. */
int main() {
  // Call labinit()
  labinit();
  int ledval = 0;
  int h0 = 9;
  int h1 = 0;


  // Enter a forever loop
  while (1) {
   
    print_dec((unsigned int)get_btn());

    if(timeoutcount < 10){

    labinit();     
    timeoutcount += 1;

    time2string(textstring, mytime); // Converts mytime to string
    display_string(textstring); //Print out the string 'textstring'
    if (textstring[0]=='5' && textstring[1]=='9' && textstring[2]==':' && textstring[3]=='5' && textstring[4]=='9' && textstring[5]=='\0') {
      h0 += 1;
      if (h0 == 10) {
        h0 = 0;
        h1 += 1;    
      }
    }

    tick(&mytime);     // Ticks the clock once
    if (ledval < 15) {
      ledval += 1;
      set_leds(ledval);
    }

    set_displays(0, textstring[4] - '0');
    set_displays(1, textstring[3] - '0');
    set_displays(2, textstring[1] - '0');
    set_displays(3, textstring[0] - '0');
    set_displays(4, h0);
    set_displays(5, h1);
  }
    
  }
}
