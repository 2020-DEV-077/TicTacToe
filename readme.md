Just open .pbxproj and run

I coded without commiting intermediate steps, but can explain them if needed, although the project was pretty straight forward. The main change from the initial design was to stop using Ints for the board cell indices and use enums. The code is more clear and there's no need for bounds checking. 
