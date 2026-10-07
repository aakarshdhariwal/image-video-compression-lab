# Third-Party Code Notice

This directory holds code that was present in the original lab course working
folder but was **not written by Aakarsh Dhariwal**. It is kept separate from the
rest of `code/` for clarity and honest attribution.

Neither file below is used by the codec. The run-level coding actually used by
the encoder and decoder is the course's own scheme, implemented in
`encoding_to_runlevel_representation.m` /
`decoding_from_runlevel_representation.m` (and their block-based wrappers),
which is a different representation entirely: it codes *runs of zeros followed
by a non-zero level*, as JPEG/MPEG-style coefficient coding requires, rather
than the *value + repeat-count* pairs these two general-purpose run-length
utilities produce. Both appear to be reference material collected while
exploring run-length coding for Lab Experiment 5, and neither is called from
anywhere in the codebase.

## `my_RLE.m`

The file's own header reads:

```
% This function performs Run Length Encoding to a strem of data x.
% [d,c]=rl_enc(x) returns the element values in d and their number of
% apperance in c. All number formats are accepted for the elements of x.
% This function is built by Abdulrahman Ikram Siddiq in Oct-1st-2011 5:15pm.
```

Attributed in the file itself to **Abdulrahman Ikram Siddiq** (October 2011). A
widely circulated MATLAB File Exchange style run-length encoding helper. Note
that the file as it stands does not parse — its declaration line
`function =my_RLE(x);` is missing an output variable name — which is further
evidence it was never actually called. It is preserved verbatim rather than
repaired, since it is not this project's code.

## `rle.m`

Despite having no author name at the top, this file carries an attribution
block at the **bottom**:

```
% Function of RLE (Run Length Encoding) was used on program of gray level image compression .
% Authors : Said Bourezg  - Derbel Abd Elhak
% Electronics Engineer  option:communication .
% Date : 05.26.2009
% ...
% This function is part of my undergraduate project in M'sila university, Algeria.
```

Attributed to **Said Bourezg** and **Derbel Abd Elhak** (M'sila University,
Algeria, May 2009). Preserved verbatim.

## A note on the fast motion search functions

`get_motion_vector_for_block_3stepsearch.m` and
`get_motion_vector_for_block_logsearch.m` are **not** in this directory, but
their history deserves recording.

As originally saved, both files contained near-identical code carrying the
variable naming (`imgP`, `imgI`, `mbSize`, `costFuncMAD`, `minCost`,
`computations`) and comment style — including a comment signed
"`Arohs thought:`" — of **Aroh Barjatya's** widely circulated academic reference
package *"Block Matching Algorithms for Motion Estimation"*. That origin is
inferred from this internal evidence rather than from an explicit credit line,
but the signed comment makes it hard to read any other way.

Neither draft was functional: they still contained the original package's
whole-frame loop rather than this course's per-block interface, called helper
functions (`costFuncMAD`, `minCost`) that were never copied across, referenced
an undefined `img_P`, and returned an average computation count instead of a
motion vector. They could not have run.

Both were therefore **rewritten from the lab manual's own algorithm
descriptions** (Sec. 4.4.1, Figures 4.4 and 4.5) against the interface
`get_motion_vector_for_block.m` defines, using this project's own
`calculate_sad.m` as the cost function. The current files are that rewrite, and
their headers credit the step-halving search approach's origin. They are not
copies of the third-party code, but they would not exist in this form without
it.

## License / usage

No license file accompanied either piece of code in the original project. Both
are included here for non-commercial, academic, and portfolio purposes only,
with attribution to their original authors. If you intend to reuse them, obtain
them from their original sources.
