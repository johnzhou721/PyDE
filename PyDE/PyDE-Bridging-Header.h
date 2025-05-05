//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Python/Python.h>
PyObject* call_method_noargs(PyObject* obj, const char* method);
void InitInterp(void);
