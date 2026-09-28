/*
 * arduinopio_hwint_avr.c
 * Function-call generator for AVR hardware interrupts.
 */

#define S_FUNCTION_NAME  arduinopio_hwint_avr
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

enum {SOURCE_ARGC, NUM_ARGS};

#define SOURCE_ARG (ssGetSFcnParam(S, SOURCE_ARGC))

#ifndef MATLAB_MEX_FILE
# error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif

static boolean_T isRealScalar(const mxArray *value)
{
    return (boolean_T)(mxIsNumeric(value) && mxIsDouble(value) && !mxIsComplex(value) &&
        (mxGetNumberOfElements(value) == 1));
}

#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    if (!isRealScalar(SOURCE_ARG)) {
        ssSetErrorStatus(S, "SourceId must be a real scalar.");
        return;
    }
}

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return;
    }
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) {
        return;
    }

    for (i = 0; i < NUM_ARGS; ++i) {
        ssSetSFcnParamNotTunable(S, i);
    }

    if (!ssSetNumInputPorts(S, 1)) {
        return;
    }
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDataType(S, 0, SS_BOOLEAN);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) {
        return;
    }
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortDataType(S, 0, SS_FCN_CALL);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, (SS_OPTION_EXCEPTION_FREE_CODE |
                     SS_OPTION_WORKS_WITH_CODE_REUSE |
                     SS_OPTION_USE_TLC_WITH_ACCELERATOR));
    ssSetExplicitFCSSCtrl(S, 1);
    ssSetRuntimeThreadSafetyCompliance(S, RUNTIME_THREAD_SAFETY_COMPLIANCE_TRUE);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetCallSystemOutput(S, 0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputBooleanPtrsType uPtrs = (InputBooleanPtrsType)ssGetInputPortSignalPtrs(S, 0);

    if ((*uPtrs[0]) != 0) {
        if (!ssCallSystemWithTid(S, 0, tid)) {
            return;
        }
    }
}

static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S);
}

#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    real_T sourceId = mxGetScalar(SOURCE_ARG);

    if (!ssWriteRTWParamSettings(S, 1, SSWRITE_VALUE_NUM, "SourceId", sourceId)) {
        return;
    }
}

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
