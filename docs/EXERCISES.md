# Exercise-to-File Map

Every mandatory exercise of the FAU "Praktikum IVC" lab manual
(`report/Prakt_IVC_2022.pdf`) for Lab Experiments 2-6, the file(s) that
implement it, and how it was validated.

Validation legend:

- **Harness** — passes the course's own `verify_*.m` test harness, executed
  under GNU Octave 11.3.0.
- **Pipeline** — no standalone harness exists; exercised end-to-end by the
  encoder/decoder round trip and the benchmark suite, which reconstruct real
  sequences at measured PSNR/SSIM.
- **Equivalence** — asserted identical to an already-validated reference
  implementation by a purpose-written test.
- **Review** — checked against the manual's specification by hand only.

Status legend: **OK** as found · **Fixed** (was present but broken) ·
**Written** (was missing entirely).

---

## Lab Experiment 2 — Entropy Coding (Exercises 2.1–2.11)

| Ex. | Deliverable | File | Status | Validation |
|-----|-------------|------|--------|------------|
| 2.1 | Load input signal, symbol probabilities | `create_huffman_table_from_signal.m` | Fixed | Pipeline |
| 2.2 | Huffman table from probability matrix | `create_huffman_table_from_probability.m` | OK | Pipeline |
| 2.3 | Huffman table cell array | `create_huffman_table_from_probability.m` | OK | Pipeline |
| 2.4 | Huffman tree cell array | `create_huffman_table_from_probability.m` | OK | Pipeline |
| 2.5 | Main tree-merging loop | `create_huffman_table_from_probability.m` | OK | Pipeline |
| 2.6 | Verify against stored table | `huffman_table.mat` | OK | Harness |
| 2.7 | Huffman look-up table | `encode_signal_to_huffman_bitstream.m` | Fixed | Harness |
| 2.8 | Encode symbols into bitstream | `encode_signal_to_huffman_bitstream.m` | Fixed | Harness |
| 2.9 | Decoder initialisation | `decode_signal_from_huffman_bitstream.m` | Fixed | Harness |
| 2.10 | Decode symbols from bitstream | `decode_signal_from_huffman_bitstream.m` | Fixed | Harness |
| 2.11 | Compare bit counts before/after | `bitstream_get_length.m` (course-provided) | OK | Pipeline |

**2.1 fix.** Symbol probabilities were divided by the hard-coded constant `11`
— the length of the manual's 11-symbol worked example — instead of the actual
signal length, so the function only produced meaningful probabilities for that
one example.

**2.7/2.8 fix.** `huffman_table_lookup` is a numeric matrix (it comes out of
`cell2mat`), but was indexed with cell braces `{}`, which is a type error. The
manual's own text for Exercise 2.8 uses parentheses.

**2.9/2.10 fix.** The decoder could not decode anything as saved:
`min_bits`/`max_bits` were assigned the whole code-length *vector* instead of
its minimum and maximum; an undefined variable `value` was tested; an
unconditional `break` sat before the code-word matching loop so the loop was
never reached; and `current_nr_of_bits=+1` assigns 1 rather than incrementing.
Rewritten to follow the manual's Exercise 2.9/2.10 algorithm exactly. Now
reproduces the course's stored reference bitstream `[24 0 24 12880738]` and
round-trips the reference signal losslessly.

## Lab Experiment 3 — Quantization (Exercises 3.1–3.14)

| Ex. | Deliverable | File | Status | Validation |
|-----|-------------|------|--------|------------|
| 3.1 | MSE of a frame | `mse_of_frame.m` | OK | Harness |
| 3.2 | PSNR of a frame | `psnr_of_frame.m` | OK | Harness |
| 3.3 | D(R) curve program | `Exercise_3_6.m`, `benchmark_codec.m` | OK | Pipeline |
| 3.4 | Simple quantizer | `simple_quantizer.m` | OK | Review |
| 3.5 | Simple dequantizer | `simple_dequantizer.m` | OK | Review |
| 3.6 | Quantize/dequantize a frame | `Exercise_3_6.m` | Fixed | Review |
| 3.7 | Scalar quantizer with matrix | `scalar_quantizer.m` | OK | Harness |
| 3.8 | Scalar dequantizer with matrix | `scalar_dequantizer.m` | OK | Harness |
| 3.9 | Quantize with a quantization matrix | `design_quantizer_matrix.m` | OK | Review |
| 3.10 | Segment-wise quantizer matrix | `design_quantizer_matrix.m` | OK | Review |
| 3.11 | Reuse MSE/PSNR functions | `mse_of_frame.m`, `psnr_of_frame.m` | OK | Harness |
| 3.12 | Distorted-image comparison | `Exercise_3_6.m` | Fixed | Review |
| 3.13 | SNR discussion | (analysis exercise) | — | — |
| 3.14 | JPEG rate-distortion comparison | `distortion_jpg.m`, `benchmark_jpeg_baseline.m` | OK | Pipeline |
| — | Block-based quantizer to levels | `blockbased_quantizer_to_levels.m` | **Written** | Harness |
| — | Block-based dequantizer from levels | `blockbased_dequantizer_from_levels.m` | **Written** | Harness |

**3.6 fix.** The script quantized an undefined variable `input_image`; the image
it loaded was called `image`, and was never normalised to the `[0,1]` range the
rest of the codebase (and `psnr_of_frame`) assumes.

**The two written functions.** `blockbased_quantizer_to_levels` and
`blockbased_dequantizer_from_levels` did not exist anywhere in the original
folder, yet are called by every encoder and decoder in the project — the single
confirmed hard blocker on the whole pipeline. Written to the interface and
numeric behaviour that the course's own `verify_blk_quant.m` harness specifies
(tile the quantizer matrix across the image, then apply the already-verified
`scalar_quantizer`/`scalar_dequantizer`); both now pass that harness.

## Lab Experiment 4 — Motion Estimation and Compensation (Exercises 4.1–4.7)

| Ex. | Deliverable | File | Status | Validation |
|-----|-------------|------|--------|------------|
| 4.1 | SAD of two blocks | `calculate_sad.m` | OK | Pipeline |
| 4.2 | Full-search motion vector for a block | `get_motion_vector_for_block.m` | OK | Pipeline |
| 4.3 | Motion search over a whole frame | `blockbased_motion_search.m` | OK | Pipeline |
| 4.4 | Motion compensation | `blockbased_motion_compensation.m` | OK | Pipeline |
| 4.5 | Logarithmic search | `get_motion_vector_for_block_logsearch.m`, `blockbased_motion_search_logsearch.m` | **Rewritten** | Pipeline |
| 4.6 | 3-step (multi-step) search | `get_motion_vector_for_block_3stepsearch.m`, `blockbased_motion_search_3stepsearch.m` | **Rewritten** | Pipeline |
| 4.7 | Octagonal search | *not implemented* | — | — |

**4.5/4.6 rewrite.** Both files as saved were non-functional partial copies of a
third-party reference implementation — they kept that package's whole-frame loop
instead of this course's per-block interface, called two helper functions that
were never copied across, referenced an undefined variable, and returned an
average computation count rather than a motion vector. Rewritten from the
manual's algorithm descriptions (Sec. 4.4.1, Figs. 4.4/4.5) against the
interface `get_motion_vector_for_block.m` defines. See
`code/third_party/NOTICE.md` for the provenance record.

**4.7** (octagonal search) is not implemented; the two faster searches the lab
asks for are.

## Lab Experiment 5 — Transform Coding and Intra Coding (Exercises 5.1–5.15)

| Ex. | Deliverable | File | Status | Validation |
|-----|-------------|------|--------|------------|
| 5.1 | Block-based 2-D DCT | `blockbased_dct_on_image.m`, `dct_matrix.m` | Fixed | Harness |
| 5.2 | Block-based 2-D IDCT | `blockbased_idct_on_image.m` | Fixed | Harness |
| 5.3 | Zigzag permutation matrix | `generate_zigzag_permutation_matrix.m` | OK | Harness |
| 5.4 | Zigzag scan of one block | `encoding_to_zigzag_scanned.m` | OK | Harness |
| 5.5 | Inverse zigzag scan of one block | `decoding_from_zigzag_scanned.m` | OK | Harness |
| 5.6 | Block-based zigzag scan | `blockbased_encoding_to_zigzag_scanned.m` | Fixed | Harness |
| 5.7 | Block-based inverse zigzag scan | `blockbased_decoding_from_zigzag_scanned.m` | Fixed | Harness |
| 5.8 | Run-level encoding of a vector | `encoding_to_runlevel_representation.m` | OK | Harness |
| 5.9 | Run-level decoding of a vector | `decoding_from_runlevel_representation.m` | OK | Harness |
| 5.10 | Block-based run-level encoding | `blockbased_encoding_to_runlevel_representation.m` | OK | Harness |
| 5.11 | Block-based run-level decoding | `blockbased_decoding_from_runlevel_representation.m` | OK | Harness |
| 5.12 | Intra encoder | `encode_intra.m` | OK | Pipeline |
| 5.13 | Intra decoder | `decode_intra.m` | OK | Pipeline |
| 5.14 | DC coefficient prediction | `optional_dc_prediction.m` | OK | Review |
| 5.15 | Inverse DC prediction | `optional_dc_prediction_inverse.m` | OK | Review |

**5.1/5.2 fix.** Neither function was block based: both computed a single DCT
over the *whole* image (and passed the output size arguments in the wrong
order), so no 8×8 transform ever took place. Rewritten as a true per-block
transform. The DCT is now built from an explicit orthonormal DCT-II basis
(`dct_matrix.m`) rather than `dct2`/`idct2` — this matches `dct2` exactly for a
square block while removing the toolbox dependency, which also matters because
Octave's `image` package declares `dct2`/`idct2` but does not implement them.
Both now match the course harness's expected coefficients to all printed digits.

**5.6/5.7 fix.** Both files had literal syntax errors and could not even be
parsed: the scan function ended a statement with `:` instead of `;`, used
undefined `height`/`width`, and indexed blocks as `i:blocksize-1` instead of
`i:i+blocksize-1`; the inverse-scan function was missing an array name and an
opening parenthesis. Rewritten with matching block traversal order on both
sides.

## Lab Experiment 6 — Video Codec (Exercises 6.1–6.15)

| Ex. | Deliverable | File | Status | Validation |
|-----|-------------|------|--------|------------|
| 6.1 | Intra encoder/decoder as `*_basic_intra` | `encoder_basic_intra.m`, `decoder_basic_intra.m` | Fixed | Pipeline |
| 6.2 | Make decoded frame available to P-frames | `encoder_basic.m` | Fixed | Pipeline |
| 6.3 | Clip reconstruction to [0,1] | `encoder_basic.m`, `decoder_basic.m` | OK | Pipeline |
| 6.4 | Multi-frame intra encoder | `encoder_basic_intra.m` | OK | Pipeline |
| 6.5 | Multi-frame intra decoder | `decoder_basic_intra.m` | Fixed | Pipeline |
| 6.6 | Intra D(R) curve | `get_dr_result_intra.m` (course-provided), `run_all_benchmarks.m` | OK | Pipeline |
| 6.7 | `encoder_basic` / `decoder_basic` | `encoder_basic.m`, `decoder_basic.m` | Fixed | Pipeline |
| 6.8 | P-frame encoding | `encoder_basic.m` | Fixed | Pipeline |
| 6.9 | P-frame decoding | `decoder_basic.m` | Fixed | Pipeline |
| 6.10 | Encoder/decoder interoperate | `encoder_basic.m` + `decoder_basic.m` | Fixed | Pipeline |
| 6.11 | Hybrid D(R) curve | `run_all_benchmarks.m` | OK | Pipeline |
| 6.12 | Compare across sequences | `run_all_benchmarks.m` (`sequences` stage) | OK | Pipeline |
| 6.13 | Compare ME block sizes | `benchmark_codec.m` (`me_blocksize` argument) | OK | Pipeline |
| 6.14 | Compare ME strategies | `run_all_benchmarks.m` (`me` stage) | OK | Pipeline |
| 6.15 | `final_encoder` / `final_decoder` | `final_encoder.m`, `final_decoder.m` | **Written** | Pipeline |

**6.1/6.5 fix — naming.** The intra decoder was saved as `decode_basic_intra.m`
while the function declared *inside* it was `decoder_basic_intra`. MATLAB and
Octave resolve a call by *file* name, so the function could never be invoked
under the name the manual specifies. Both the file and the declaration are now
`decoder_basic_intra`. The same mismatch applied to the hybrid decoder, which
the manual (Exercise 6.7) and `get_dr_result.m`'s own documented example both
call `decoder_basic` but which was saved as `decode_basic.m`.

**6.5 fix — frame slicing.** The intra decoder extracted each frame's run-level
data with a fixed-width window `signal(i:i+2*n_blocks-1,:)`, which corresponds
to no real frame boundary, since the number of run-level rows per block varies.
It now locates frame boundaries by counting `n_blocks` end-of-block `(-1,-1)`
markers, the same way the hybrid decoder does.

**6.7/6.9 fix — hybrid decoder.** As saved it referenced an undefined variable
`signal`, had no `else` branch (so frame 1 was decoded once as an I-frame and
then *again* as a P-frame in the same iteration), and indexed the motion vector
array with run-level row counters, which do not correspond to motion vector
rows at all.

**6.8 fix — hybrid encoder.** Three defects that each on their own break
encoder/decoder agreement: motion compensation was performed on the *current*
frame instead of the reconstructed reference frame; the reference stored for the
next frame was the decoded *residual* rather than the reconstruction
(residual + prediction); and the per-frame MSE was measured between the residual
and the reconstruction instead of between the original frame and its
reconstruction.

**6.15.** `final_encoder.m` / `final_decoder.m` did not exist, although
`get_final_result.m` (course-provided) calls them by name. Written as the
specified fixed-parameter wrappers around `encoder_basic`/`decoder_basic`.

**6.16–6.17** are deliberately out of scope: they concern submitting the codec
to a university server path (`/HOMES/mmkgrpXX`) for a cross-group comparison
that has no meaning outside the live course.

---

## Extensions beyond the lab requirements

These are not lab exercises. They were added to push the codec past the
coursework baseline, and each is benchmarked against the baseline in isolation.

| Extension | File(s) | Validation |
|-----------|---------|------------|
| Half-pel (sub-pixel) motion estimation and compensation | `blockbased_motion_search_subpel.m`, `blockbased_motion_compensation_subpel.m`, `upsample_half_pel.m` | Pipeline |
| Rate-distortion optimized block decisions | `rdo_zero_blocks.m` | Pipeline |
| In-loop deblocking filter | `deblock_frame.m` | Pipeline |
| SSIM quality metric | `ssim_of_frame.m`, `get_ssim_for_sequence.m` | Pipeline |
| Configurable optimized codec | `encoder_opt.m`, `decoder_opt.m` | Pipeline |
| Vectorized Huffman codec | `encode_signal_to_huffman_bitstream_fast.m`, `decode_signal_from_huffman_bitstream_fast.m` | Equivalence (`verify_fast_huffman_equivalence.m`) |
| Vectorized zigzag scan | `blockbased_encoding_to_zigzag_scanned_fast.m`, `blockbased_decoding_from_zigzag_scanned_fast.m` | Equivalence (`verify_fast_transform_equivalence.m`) |
| Benchmark suite | `benchmark_codec.m`, `benchmark_jpeg_baseline.m`, `run_all_benchmarks.m` | — |

The sub-pixel extension corresponds to the manual's own optional Exercises
4.9–4.12; the others are not in the manual.

---

## Files kept but not part of the working codec

These are genuine artifacts of how the project was developed and are kept for
transparency rather than presented as finished deliverables. None is called by
the codec.

| File | What it is |
|------|------------|
| `zigsc.m` | An earlier attempt at the zigzag permutation matrix. Declares a function name that does not match its file name and references undefined `num_rows`/`num_cols`; superseded by `generate_zigzag_permutation_matrix.m`, which passes the course harness. |
| `zigzag.m` | A second, independent zigzag-order experiment with a different interface. Not used. |
| `runleveldecoder.m` | A scratch script (not a function) prototyping run-level decoding on a hard-coded vector; superseded by `decoding_from_runlevel_representation.m`. |
| `blockwise_processing.m` | A course-provided Lab Experiment 1 tutorial skeleton with `% TODO` blanks left in place. Chapter 1 is an interactive MATLAB tutorial, not a graded deliverable, and nothing in the codec calls this function. |
| `third_party/my_RLE.m`, `third_party/rle.m` | Third-party run-length coding utilities, unused. See `code/third_party/NOTICE.md`. |
| `mfile_bitstream_read_bits.m` | The course's portable bitstream reader, kept under its original name. A copy named `bitstream_read_bits.m` was added so that callers resolve on platforms where the supplied Linux `.mexa64`/`.mexglx` binaries cannot load. |
| `loops_example.m`, `plot_myfun.m`, `diag_mask.m` | Lab Experiment 1 MATLAB tutorial artifacts. |
