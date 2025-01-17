#include <Timer1.h>
#include <Timer3.h>
#include <Timer4.h>
#include <Timer5.h>

//DEFINED COMPONENTS  AND PINS
#define ACQ_S_PIN 21
#define PUMP_TTL_WIDTH 120000 //us feeding duration
#define PUMP_TTL1_WIDTH 120000 // Added feeding duration us feeding duration
#define PumpTTL_PIN 36
#define PumpTTL1_PIN 32 // added pump
#define LICK_IND_PIN 35
#define LICK_IND1_PIN 35 //added pin
#define EXT_INT 0
#define LICK_INPUT_PIN 2
#define LICK_INPUT1_PIN 3 // added lick
#define MP3_TRIG_PIN 37
#define PUMP_START HIGH
#define PUMP_START1 HIGH
#define TIMER_PACE 1000000 //1 second pace
#define BLOCK_PIN 12


//Treadmill encoder ( IGNORE FOR LATENT PROJECT)
#define ENCODER_A_PIN 20
#define ENCODER_B_PIN 4
#define SPEED_COUNT_PEROID 1000000 // 1 second
//#define MICRONS_PER_COUNT 399

enum STATE
{
  TRIAL_START,
  RESP,
  TRIAL_END
};

unsigned long lPre_Resp = 60000000; //Time between cue and extension of lickometer
unsigned long lRespTime = 45000000; // response window us
volatile unsigned long lTimerLoops = 0;
volatile unsigned long lTimerResidual = 0;
volatile unsigned long lTimer = 0;
volatile STATE emState = TRIAL_END;
volatile boolean bStateChanged = false;

volatile int iLickAftPump = 0;
const int iConsumption = 3;// licks per pump
unsigned long lFeed = 0;
unsigned long lFeed1 = 0;
unsigned int iAutoPump = 1;//2 iAutoPump per drop
volatile unsigned int iPumpTime = iAutoPump;
volatile unsigned int iPumpTime1 = iAutoPump;
unsigned char MtMsg[6] = {
  0, 0, 0, 0, 0, 0
};

volatile long lDist_Rel = 0;
volatile unsigned long lDist_Abs_Pre = 0;
volatile unsigned long lDist_Abs = 0;
volatile unsigned long lSpeed_Abs = 0;
void startTime3_Long(unsigned long lTime)
{
  //pauseTimer3();
  lTimerLoops = lTime / TIMER_PACE;
  lTimerResidual = lTime % TIMER_PACE;
  if (lTimerLoops > 0)
  {
	startTimer3(TIMER_PACE);
  }
  else
  {
	startTimer3(lTime);
  }
  lTimer = 0;
}

void setup() //PUMP AND LICK SETUP
{
  pinMode(PumpTTL_PIN, OUTPUT);
  pinMode(PumpTTL1_PIN, OUTPUT);
  pinMode(LICK_INPUT_PIN, INPUT);
  pinMode(LICK_INPUT1_PIN, INPUT);
  pinMode(BLOCK_PIN, INPUT);
  pinMode(LICK_IND_PIN, OUTPUT);
  pinMode(LICK_IND1_PIN, OUTPUT);
  digitalWrite(LICK_IND_PIN, LOW);
  digitalWrite(LICK_IND1_PIN, LOW);
  pinMode(MP3_TRIG_PIN, OUTPUT);
  pinMode(ENCODER_A_PIN, INPUT_PULLUP);
  pinMode(ENCODER_B_PIN, INPUT_PULLUP);
  // disableMillis();
  startTimer1(PUMP_TTL_WIDTH);
  pauseTimer1();
  startTimer5(PUMP_TTL1_WIDTH);
  pauseTimer5();
  startTime3_Long(lPre_Resp);
  pauseTimer3();
  startTimer4(SPEED_COUNT_PEROID);
//  attachInterrupt(digitalPinToInterrupt(LICK_INPUT_PIN), PumpAction, CHANGE);
//  attachInterrupt(digitalPinToInterrupt(LICK_INPUT1_PIN), PumpAction1, CHANGE); // "PumpAction" was not declared  in  this scope  
  attachInterrupt(digitalPinToInterrupt(LICK_INPUT_PIN), PumpAction2, CHANGE);
  attachInterrupt(digitalPinToInterrupt(ACQ_S_PIN), StartTrg, RISING);
  attachInterrupt(digitalPinToInterrupt(ENCODER_A_PIN), EncoderCal, RISING);
  digitalWrite(MP3_TRIG_PIN, HIGH);
  Serial.begin(9600);
  Serial1.begin(9600);
  MtMsg[1] = 1;
  Serial1.write(MtMsg, 6);
}


void loop(){

  if ( bStateChanged)
  {
	bStateChanged = false;
	switch (emState)
	{
  	case TRIAL_START:
    	{
      	startTime3_Long(lPre_Resp);
    	}
    	break;

  	case RESP:
    	{
      	startTime3_Long(lRespTime);
      	MtMsg[1] = 18;
      	Serial1.write(MtMsg, 6);
     	 
    	}
    	break;

  	case TRIAL_END:
    	{
      	MtMsg[1] = 1;
      	Serial1.write(MtMsg, 6);
    	}
    	break;

  	default:
    	break;
	}
  }
}

void PumpAction() //PUMP0
{
  // bAction = true;
  int iLickVal = digitalRead(LICK_INPUT_PIN);
  int BLOCKVal = digitalRead(BLOCK_PIN);
  digitalWrite(LICK_IND_PIN, iLickVal);
  if (iLickVal == HIGH)
  {
	Serial.print("Lick:");
  Serial.println(iLickAftPump);
   if (digitalRead(PumpTTL_PIN) != PUMP_START && iLickAftPump == 0 && BLOCKVal == HIGH)
   {
  	digitalWrite(PumpTTL_PIN, PUMP_START);
  	resetTimer1();
  	resumeTimer1();
  	lFeed++;
  	Serial.print("Feed:");
  	Serial.println(lFeed);
	}
    
	iLickAftPump++;
  }
  if (iLickAftPump >= iConsumption)
  {
	iLickAftPump = 0;
  }
  //  Serial.print("Lick:");
  //  Serial.println(iLickAftPump);
}

void PumpAction1()  //PUMP1
{
  // bAction = true;
  int iLickVal1 = digitalRead(LICK_INPUT1_PIN);
  int BLOCKVal = digitalRead(BLOCK_PIN);
  digitalWrite(LICK_IND1_PIN, iLickVal1);
  if (iLickVal1 == HIGH)  // additional code for PUMP1
  {
	Serial.print("Lick1:");
  Serial.println(iLickAftPump);
	if (digitalRead(PumpTTL1_PIN) != PUMP_START1 && iLickAftPump == 0 && BLOCKVal == LOW)
	{
  	digitalWrite(PumpTTL1_PIN, PUMP_START1);
  	resetTimer5();
  	resumeTimer5();
  	lFeed1++;
  	Serial.print("Feed1:");
  	Serial.println(lFeed1);
	}
	iLickAftPump++;
  }
  if (iLickAftPump >= iConsumption)
  {
	iLickAftPump = 0;
  }
  //  Serial.print("Lick:");
  //  Serial.println(iLickAftPump);
}

void PumpAction2()  //PUMP1
{
  // bAction = true;
  int iLickVal = digitalRead(LICK_INPUT_PIN);
  int BLOCKVal = digitalRead(BLOCK_PIN);
  digitalWrite(LICK_IND_PIN, iLickVal);
  if (iLickVal == HIGH)
  {
    
   Serial.print("Lick1:");
   Serial.println(iLickAftPump);
   if (digitalRead(PumpTTL_PIN) != PUMP_START && iLickAftPump == 0 && BLOCKVal == LOW)
   {
    digitalWrite(PumpTTL_PIN, PUMP_START);
    resetTimer1();
    resumeTimer1();
    lFeed1++;
    Serial.print("Feed1:");
    Serial.println(lFeed1);
    }
  else if (digitalRead(PumpTTL1_PIN) != PUMP_START && iLickAftPump == 0 && BLOCKVal == HIGH)
   {
    digitalWrite(PumpTTL1_PIN, PUMP_START1);
    resetTimer5();
    resumeTimer5();
    lFeed1++;
    Serial.print("Feed1:");
    Serial.println(lFeed1);
   }
  iLickAftPump++;
  }
  
  if (iLickAftPump >= iConsumption)
  {
  iLickAftPump = 0;
  }
  //  Serial.print("Lick:");
  //  Serial.println(iLickAftPump);
}

void StartTrg()
{
  lTimer = 0;
  bStateChanged = true;
  emState = TRIAL_START;
}

void EncoderCal()
{
  lDist_Abs++;
  if (digitalRead(ENCODER_B_PIN) == HIGH)
  {
	lDist_Rel++;
  }
  else
  {
	lDist_Rel--;
  }
}
// Define the function which will handle the notifications
ISR(timer1Event)
{
  if (iPumpTime < iAutoPump)
  {
	if (iPumpTime % 2 == 0)
	{
  	digitalWrite(PumpTTL_PIN, PUMP_START);
	}
	else
	{
  	digitalWrite(PumpTTL_PIN, !PUMP_START);
	}
	iPumpTime++;
  }
  else
  {
	pauseTimer1();
	digitalWrite(PumpTTL_PIN, !PUMP_START);
  }
}

// Define the function which will handle the notifications PUMP1
ISR(timer5Event)
{
  if (iPumpTime1 < iAutoPump)
  {
	if (iPumpTime1 % 2 == 0)
	{
  	digitalWrite(PumpTTL1_PIN, PUMP_START1);
	}
	else
	{
  	digitalWrite(PumpTTL1_PIN, !PUMP_START1);
	}
	iPumpTime1++;
  }
  else
  {
	pauseTimer5();
	digitalWrite(PumpTTL1_PIN, !PUMP_START1);
  }
}
   
ISR(timer3Event)
{
  lTimer++;
  if (lTimer < lTimerLoops)
  {
	resetTimer3();
	resumeTimer3();
  }
  else
  {
	pauseTimer3();
	if (lTimer == lTimerLoops)
	{
  	startTimer3(lTimerResidual);
	}
	else
	{
  	switch (emState)
  	{
    	case TRIAL_START:
      	{
        	emState = RESP;
      	}
      	break;

    	case RESP:
      	{
        	emState = TRIAL_END;
      	}
      	break;

    	default:
      	break;
  	}

  	bStateChanged = true;
	}
  }
}

ISR(timer4Event)
{
  resetTimer4();
  lSpeed_Abs = lDist_Abs - lDist_Abs_Pre;
  if (lSpeed_Abs)
  {
	Serial.print("Dist_Abs:");
	Serial.print(lDist_Abs);
	Serial.print(",Dist_Rel:");
	Serial.print(lDist_Rel);
	Serial.print(",Speed_Abs:");
	Serial.println(lSpeed_Abs);
	lDist_Rel = 0;
	lDist_Abs_Pre = lDist_Abs;
  }
}

void serialEvent()//PUMP0
{
  char inChar = (char)Serial.read();

  switch (inChar)
  {
	case 'V':
	case 'v':
  	{
    	Serial.println("Behav_PUMP_2p");
  	}
  	break;

	case 'D':
	case 'd':
  	{
    	detachInterrupt(digitalPinToInterrupt(LICK_INPUT_PIN));
    	Serial.println("Pump function detached!");
  	}
  	break;

	case 'A':
	case 'a':
  	{
    	attachInterrupt(digitalPinToInterrupt(LICK_INPUT_PIN), PumpAction, CHANGE);
    	attachInterrupt(digitalPinToInterrupt(LICK_INPUT1_PIN), PumpAction1, CHANGE);
    	Serial.println("Pump function attached!");
  	}
  	break;

	case 'T':
	case 't':
  	{
    	attachInterrupt(digitalPinToInterrupt(ACQ_S_PIN), StartTrg, RISING);
    	Serial.println("Mount start trigger!");
  	}
  	break;

	case 'U':
	case 'u':
  	{
    	detachInterrupt(digitalPinToInterrupt(ACQ_S_PIN));
    	Serial.println("Unmount start trigger!");
  	}
  	break;

	case 'R':
	case 'r':
  	{
    	lFeed = 0;
    	iLickAftPump = 0;
    	lDist_Abs_Pre = 0;
    	lDist_Abs = 0;
    	Serial.println("Reset");
  	}
  	break;

	case 'P':
	case 'p':
  	{
    	iPumpTime = 0;
    	resetTimer1();
    	resumeTimer1();
    	resetTimer5();
    	resumeTimer5();
  	}
  	break;

	case 'E':
	case 'e':
  	{
    	MtMsg[1] = 1;
    	Serial1.write(MtMsg, 6);
  	}
  	break;

	case 'X':
	case 'x':
  	{
    	MtMsg[1] = 18;
    	Serial1.write(MtMsg, 6);
  	}
  	break;

	default:
  	break;
  }

  while (Serial.available() > 0)
  {
	Serial.read();
  }
}
