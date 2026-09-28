/*
 * File: uno_blink.h
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

#ifndef uno_blink_h_
#define uno_blink_h_
#ifndef uno_blink_COMMON_INCLUDES_
#define uno_blink_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "math.h"
#include "arduinopio_arduino.h"
#endif                                 /* uno_blink_COMMON_INCLUDES_ */

#include "uno_blink_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

/* Block states (default storage) for system '<Root>' */
typedef struct {
  int32_T clockTickCounter;            /* '<Root>/Pulse' */
} DW_uno_blink_T;

/* Real-time Model Data Structure */
struct tag_RTM_uno_blink_T {
  const char_T * volatile errorStatus;
};

/* Block states (default storage) */
extern DW_uno_blink_T uno_blink_DW;

/* Model entry point functions */
extern void uno_blink_initialize(void);
extern void uno_blink_step(void);
extern void uno_blink_terminate(void);

/* Real-time Model object */
extern RT_MODEL_uno_blink_T *const uno_blink_M;

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'uno_blink'
 */
#endif                                 /* uno_blink_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
