/*
 * File: uno_blink.c
 *
 * Code generated for Simulink model 'uno_blink'.
 *
 * Model version                  : 1.1
 * Simulink Coder version         : 25.2 (R2025b) 28-Jul-2025
 * C/C++ source code generated on : Sun Sep 20 15:32:35 2026
 *
 * Target selection: piofrtos.tlc
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "uno_blink.h"
#include "rtwtypes.h"

/* Block states (default storage) */
DW_uno_blink_T uno_blink_DW;

/* Real-time model */
static RT_MODEL_uno_blink_T uno_blink_M_;
RT_MODEL_uno_blink_T *const uno_blink_M = &uno_blink_M_;

/* Model step function */
void uno_blink_step(void)
{
  int32_T rtb_Pulse;

  /* DiscretePulseGenerator: '<Root>/Pulse' */
  rtb_Pulse = ((uno_blink_DW.clockTickCounter < 5) &&
               (uno_blink_DW.clockTickCounter >= 0));
  if (uno_blink_DW.clockTickCounter >= 9) {
    uno_blink_DW.clockTickCounter = 0;
  } else {
    uno_blink_DW.clockTickCounter++;
  }

  /* End of DiscretePulseGenerator: '<Root>/Pulse' */

  /* MATLABSystem: '<Root>/Digital Output' */
  if (rtb_Pulse != 0) {
    digitalWrite(13, HIGH);
  } else {
    digitalWrite(13, LOW);
  }

  /* End of MATLABSystem: '<Root>/Digital Output' */
}

/* Model initialize function */
void uno_blink_initialize(void)
{
  /* Start for MATLABSystem: '<Root>/Digital Output' */
  pinMode(13, OUTPUT);
}

/* Model terminate function */
void uno_blink_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
