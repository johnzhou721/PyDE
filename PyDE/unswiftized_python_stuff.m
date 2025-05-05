// callmethod_wrapper.c
#include <Python/Python.h>
#include <Foundation/Foundation.h>

PyObject* call_method_noargs(PyObject* obj, const char* method) {
    return PyObject_CallMethod(obj, method, NULL);
}

void InitInterp(void){
    PyStatus status;
    PyPreConfig preconfig;
    PyConfig config;
    NSArray *test_args;
    NSString *python_home;
    wchar_t *wtmp_str;

    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    // Set some other common environment indicators to disable color, as the
    // Xcode log can't display color. Stdout will report that it is *not* a
    // TTY.
    setenv("NO_COLOR", "1", true);
    setenv("PYTHON_COLORS", "0", true);

    // Arguments to pass into the test suite runner.
    // argv[0] must identify the process; any subsequent arg
    // will be handled as if it were an argument to `python -m test`
    test_args = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TestArgs"];
    if (test_args == NULL) {
        NSLog(@"Unable to identify test arguments.");
    }

    // Generate an isolated Python configuration.
    NSLog(@"Configuring isolated Python...");
    PyPreConfig_InitIsolatedConfig(&preconfig);
    PyConfig_InitIsolatedConfig(&config);

    // Configure the Python interpreter:
    // Enforce UTF-8 encoding for stderr, stdout, file-system encoding and locale.
    // See https://docs.python.org/3/library/os.html#python-utf-8-mode.
    preconfig.utf8_mode = 1;
    // Use the system logger for stdout/err
    config.use_system_logger = 1;
    // Don't buffer stdio. We want output to appears in the log immediately
    config.buffered_stdio = 0;
    // Don't write bytecode; we can't modify the app bundle
    // after it has been signed.
    config.write_bytecode = 0;
    // Ensure that signal handlers are installed
    config.install_signal_handlers = 1;
    // For debugging - enable verbose mode.
    // config.verbose = 1;

    NSLog(@"Pre-initializing Python runtime...");
    status = Py_PreInitialize(&preconfig);
    if (PyStatus_Exception(status)) {
        PyConfig_Clear(&config);
        return;
    }

    // Set the home for the Python interpreter
    python_home = [NSString stringWithFormat:@"%@/python", resourcePath, nil];
    NSLog(@"PythonHome: %@", python_home);
    wtmp_str = Py_DecodeLocale([python_home UTF8String], NULL);
    status = PyConfig_SetString(&config, &config.home, wtmp_str);
    if (PyStatus_Exception(status)) {
        PyConfig_Clear(&config);
        return;
    }
    PyMem_RawFree(wtmp_str);

    // Read the site config
    status = PyConfig_Read(&config);
    if (PyStatus_Exception(status)) {
        PyConfig_Clear(&config);
        return;
    }
    
    NSLog(@"Initializing Python runtime...");
    status = Py_InitializeFromConfig(&config);
    if (PyStatus_Exception(status)) {
        PyConfig_Clear(&config);
        return;
    }
}
