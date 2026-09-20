#ifndef ARDUINOPIO_LOCK_H
#define ARDUINOPIO_LOCK_H

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioLockInit(void);
void arduinopioLock(void);
void arduinopioUnlock(void);

#ifdef __cplusplus
}
#endif

#endif
