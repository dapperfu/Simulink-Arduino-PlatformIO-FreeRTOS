/*
 * arduinopio_digital_input_c.c
 * Level-2 C S-function for pinMode / digitalRead.
 *
 * Host simulation uses the SimValue dialog parameter and requires this file
 * to be mexed (buildArduinoPioSFunctions). Code generation writes Pin and
 * PinPull through mdlRTW for the matching TLC.
 */

#define S_FUNCTION_NAME  arduinopio_digital_input_c
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

enum {
    PIN_IDX = 0,
    PIN_PULL_IDX,
    SAMPLE_TIME_IDX,
    SIM_VALUE_IDX,
    NUM_PARAMS
};

#define PIN_ARG       (ssGetSFcnParam(S, PIN_IDX))
#define PIN_PULL_ARG  (ssGetSFcnParam(S, PIN_PULL_IDX))
#define SAMPLE_ARG    (ssGetSFcnParam(S, SAMPLE_TIME_IDX))
#define SIM_VALUE_ARG (ssGetSFcnParam(S, SIM_VALUE_IDX))

static boolean_T isRealScalar(const mxArray *value)
{
    return (boolean_T)(mxIsNumeric(value) && mxIsDouble(value) && !mxIsComplex(value) &&
        (mxGetNumberOfElements(value) == 1));
}

static void setDiscreteOrInheritedSampleTime(SimStruct *S)
{
    real_T sampleTime;

    sampleTime = mxGetScalar(SAMPLE_ARG);
    if (sampleTime == -1.0) {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    } else if (mxIsFinite(sampleTime) && (sampleTime > 0.0)) {
        ssSetSampleTime(S, 0, sampleTime);
    } else {
        ssSetErrorStatus(S, "SampleTime must be -1 (inherited) or a positive finite scalar.");
        return;
    }
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}

#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    real_T pin;
    real_T pinPull;
    int paramIndex;

    for (paramIndex = 0; paramIndex < NUM_PARAMS; ++paramIndex) {
        if (!isRealScalar(ssGetSFcnParam(S, paramIndex))) {
            ssSetErrorStatus(S, "Pin, PinPull, SampleTime, and SimValue must be real scalars.");
            return;
        }
    }

    pin = mxGetScalar(PIN_ARG);
    pinPull = mxGetScalar(PIN_PULL_ARG);
    if (!(mxIsFinite(pin) && (pin >= 0.0) && (pin <= 255.0))) {
        ssSetErrorStatus(S, "Pin must be a finite value in 0..255.");
        return;
    }
    if ((pinPull != 0.0) && (pinPull != 1.0) && (pinPull != 2.0)) {
        ssSetErrorStatus(S, "PinPull must be 0 (None), 1 (Pull-up), or 2 (Pull-down).");
        return;
    }
}

static void mdlInitializeSizes(SimStruct *S)
{
    int paramIndex;

    ssSetNumSFcnParams(S, NUM_PARAMS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return;
    }
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) {
        return;
    }

    for (paramIndex = 0; paramIndex < NUM_PARAMS; ++paramIndex) {
        ssSetSFcnParamNotTunable(S, paramIndex);
    }

    if (!ssSetNumInputPorts(S, 0)) {
        return;
    }
    if (!ssSetNumOutputPorts(S, 1)) {
        return;
    }
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortDataType(S, 0, SS_BOOLEAN);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, (SS_OPTION_EXCEPTION_FREE_CODE |
                     SS_OPTION_WORKS_WITH_CODE_REUSE |
                     SS_OPTION_USE_TLC_WITH_ACCELERATOR));
    ssSetRuntimeThreadSafetyCompliance(S, RUNTIME_THREAD_SAFETY_COMPLIANCE_TRUE);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    setDiscreteOrInheritedSampleTime(S);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    boolean_T *y;
    real_T simValue;

    UNUSED_ARG(tid);
    y = (boolean_T *)ssGetOutputPortSignal(S, 0);
    simValue = mxGetScalar(SIM_VALUE_ARG);
    y[0] = (simValue != 0.0) ? 1 : 0;
}

static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S);
}

#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    real_T pin = mxGetScalar(PIN_ARG);
    real_T pinPull = mxGetScalar(PIN_PULL_ARG);

    if (!ssWriteRTWParamSettings(S, 2,
            SSWRITE_VALUE_NUM, "Pin", pin,
            SSWRITE_VALUE_NUM, "PinPull", pinPull)) {
        return;
    }
}

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
