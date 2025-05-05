Proof of Concept for embedding Python in a visionOS app.

A textbox is presented to enter Python code, and a button executes it, and the
stdout appears below. ``stdin`` is not supported yet. No code highlighting.
This is meant to be completely minimal, though I might add stuff to it.

The Python.xcframework should be obtained from a build of beeware/Python-Apple-Support.

Note, as of now, this does not work yet; after my latest PR there which fixes the
modulemap problem, this will begin working.
