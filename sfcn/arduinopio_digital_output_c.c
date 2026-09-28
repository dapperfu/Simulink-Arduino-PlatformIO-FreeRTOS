/*
 * arduinopio_digital_output_c.c
 * Level-2 C S-function for pinMode / digitalWrite.
 *
 * Host simulation is a no-op and requires this file to be mexed
 * (buildArduinoPioSFunctions). Code generation writes Pin through mdlRTW
 * for the matching TLC.
 */

#define S_FUNCTION_NAME  arduinopio_digital_output_c
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

enum {
    PIN_IDX = 0,
    SAMPLE_TIME_IDX,
    NUM_PARAMS
};

#define PIN_ARG    (ssGetSFcnParam(S, PIN_IDX))
#define SAMPLE_ARG (ssGetSFcnParam(S, SAMPLE_TIME_IDX))

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
    int paramIndex;

    for (paramIndex = 0; paramIndex < NUM_PARAMS; ++paramIndex) {
        if (!isRealScalar(ssGetSFcnParam(S, paramIndex))) {
            ssSetErrorStatus(S, "Pin and SampleTime must be real scalars.");
            return;
        }
    }

    pin = mxGetScalar(PIN_ARG);
    if (!(mxIsFinite(pin) && (pin >= 0.0) && (pin <= 255.0))) {
        ssSetErrorStatus(S, "Pin must be a finite value in 0..255.");
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

    if (!ssSetNumInputPorts(S, 1)) {
        return;
    }
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDataType(S, 0, SS_DOUBLE);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 0)) {
        return;
    }

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
    InputRealPtrsType uPtrs;

    UNUSED_ARG(tid);
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    /* Host simulation has no Arduino hardware. Code generation inlines a write. */
    (void)(*uPtrs[0]);
}

static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S);
}

#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    real_T pin = mxGetScalar(PIN_ARG);

    if (!ssWriteRTWParamSettings(S, 1, SSWRITE_VALUE_NUM, "Pin", pin)) {
        return;
    }
}

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
