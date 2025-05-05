//
//  ContentView.swift
//  PyDE
//
//  Created by John Zhou on 5/4/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Python

func asyncExecuteImmediately(task: @escaping () -> Void) {
    Task {
        // Execute the task asynchronously
        task()
    }
}

struct ContentView: View {
    @State private var code = ""
    @State private var runButtonText = "Run Code"
    @State private var result = ""
    
    var body: some View {
        VStack {
            Text("Enter some text:")
                            .font(.headline)
                        
            TextEditor(text: $code)
                .padding()
                .border(Color.gray, width: 1)
                .frame(width: 300, height: 200)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.asciiCapable)

            
            Button(action: {
                InitInterp();

                PyRun_SimpleString("import sys\nimport io\nsys.stdout = io.StringIO()\n");

                PyRun_SimpleString(code);

                let sys = PyImport_ImportModule("sys");
                let stdout_obj = PyObject_GetAttrString(sys, "stdout");
                let output = call_method_noargs(stdout_obj, "getvalue");

                result = String(cString: PyUnicode_AsUTF8(output));

                Py_XDECREF(output);
                Py_XDECREF(stdout_obj);
                Py_XDECREF(sys);

                Py_Finalize();
            }) {
                Text(runButtonText)
                    .padding()
                    .cornerRadius(10)
            }
            
            Text(result)
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
