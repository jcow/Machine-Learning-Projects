George Lesica
Grad student

My network, given the default ordering (the order that was in the data file) is:

- Storms
- BusTourGroup
- Lightning
    - Storms
- Campfire
    - BusTourGroup
    - Storms
- Thunder
    - Lightning

To run the program just do:

    $ julia BayesNetTest.jl

All you need is Julia installed.

Basically, I implemented it pretty close to the math. I have a g(..) function,
etc. I attempted to use some of the nifty features of Julia, like maps using
anonymous function blocks. For example, you will see some code like this:

L = map(1:10) do x
    x * x
end

This would result in L containing a vector of the first 10 squares.

Results from one run of the test program (it uses a random permutation each
time, so the results change):

Accuracy for group 0: 0.99
Accuracy for group 1: 1.0
Accuracy for group 2: 1.0
Accuracy for group 3: 1.0
Accuracy for group 4: 1.0
Accuracy for group 5: 0.99
Accuracy for group 6: 0.99
Accuracy for group 7: 1.0
Accuracy for group 8: 0.98
Accuracy for group 9: 0.98

The confusion matrix is below, it is the summation of all 10 group matrices.

   Predicted
 A  -   +
 c  - 993  0
 t  +   7  0

The confusion matrix seems to indicate a problem since I apparently get all the
positives wrong. I've been over the code dozens of times and can't find an
error, so I guess either that's how it is or I made an error I can't find.

I also implemented the first extra credit (I think). You'll notice that each
group runs 10 times, each of these runs uses a different network, chosen at
random from the set of possible networks.
