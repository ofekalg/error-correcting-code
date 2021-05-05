# error-correcting-code
An implementation of the Reed-Solomon's error correcting code, written as part of an academic course I took during my computer science bachelor degree.
This implementation is based on the book of Madhu Sudan, chapters: 5, 11 and 12. https://cse.buffalo.edu/faculty/atri/courses/coding-theory/book/web-coding-book.pdf 

# Introduction
During transmission of information using unreliable communication channels, noise can be added to the information causing it to be corrupted. In that case, wrong data can be received, or some data can be lost.
Error correcting codes, such as Reed-Solomon’s code, are techniques to enable reliability of the transmitted data, so that the right message is both transmitted and received.
This is done by encoding the original message (changing it and adding information to it), so that in case of any noise or erasures, the right message can be deducted from it.

# Background information
Reed–Solomon codes are a group of error-correcting codes that were introduced by Irving S. Reed and Gustave Solomon in 1960 who were then staff members of MIT Lincoln Laboratory.
The codes are broadly used and today they are mainly used in customer technologies, satellite communication, storage systems and so on.
RS codes are preformed on blocks of data treated as a set of finite field elements. They can detect and correct multiple errors in the data.

I chose the finite field 𝔽257 as my alphabet. I chose this field since the extended 𝐴𝑆𝐶𝐼𝐼 table includes 256 values and 257 is the closest prime number greater than 256.

# How to run the file
1. go to https://cocalc.com/ and upload the file
2. Then you can open the file and click on the run button
3. The result will be at the bottom of the file under the “Output” section
