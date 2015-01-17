#ifndef __xsi_fcurve_h
#define __xsi_fcurve_h

#define FCURVE_INTERPOLATION_DEFAULT 0
#define FCURVE_INTERPOLATION_CONSTANT 1
#define FCURVE_INTERPOLATION_LINEAR 2
#define FCURVE_INTERPOLATION_CUBIC 3

#define FCURVE_DECLARE(c) float c[]
#define FCURVE_DECLARE_OUTPUT(c) output float c[]
#define FCURVE_ASSIGN(t, s) t = s
#define FCURVE_USE(c) c

#define FCURVE_KEY_SIZE 8

#define FCURVE_NB_KEYS(c) floor(arraylength(c) / FCURVE_KEY_SIZE)
#define FCURVE_VALUE_X(c, k) c[(k)*FCURVE_KEY_SIZE]
#define FCURVE_PRE_VALUE_Y(c, k) c[(k)*FCURVE_KEY_SIZE+1]
#define FCURVE_POST_VALUE_Y(c, k) c[(k)*FCURVE_KEY_SIZE+2]
#define FCURVE_PRE_TANGENT_X(c, k) c[(k)*FCURVE_KEY_SIZE+3]
#define FCURVE_PRE_TANGENT_Y(c, k) c[(k)*FCURVE_KEY_SIZE+4]
#define FCURVE_POST_TANGENT_X(c, k) c[(k)*FCURVE_KEY_SIZE+5]
#define FCURVE_POST_TANGENT_Y(c, k) c[(k)*FCURVE_KEY_SIZE+6]
#define FCURVE_INTERPOLATION(c, k) c[(k)*FCURVE_KEY_SIZE+7]

#endif
