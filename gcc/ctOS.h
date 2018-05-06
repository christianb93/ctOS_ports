
/* 
 * Tell GCC which files to add during linking - in this order!
 */
#undef STARTFILE_SPEC
#define STARTFILE_SPEC "crt0.o%s crti.o%s crtbegin.o%s"

#undef ENDFILE_SPEC
#define ENDFILE_SPEC "crtend.o%s crtn.o%s"


/*
 * Tell GCC which libraries we want to add as defaults
 */
#undef LIB_SPEC
#define LIB_SPEC "-lc"
