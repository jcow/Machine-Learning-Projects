George Lesica
Graduate student

Version space looks like this (for sample in slides):

   [['sunny', 'warm', '?', '?', '?', '?'], ['sunny', '?', '?', 'strong', '?',
   '?'], ['?', 'warm', '?', 'strong', '?', '?']] 

I used Python this time. Just do `python elimination.py`.

I basically just implemented it as one big function and made some assumptions
(like the fact that S is always one element.

The results are that it is right 100% of the time, which seems fishy, but
whatever. The version space comes out weird in some cases, but it seems to work
on test cases, so I have no idea why that is happening.
