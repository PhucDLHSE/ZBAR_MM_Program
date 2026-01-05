*&---------------------------------------------------------------------*
*& Report ZSF_RS_PROGRAM_181
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSF_RS_PROGRAM_181.

INCLUDE zsf_rs_top_181.
INCLUDE zsf_rs_ss_181.
INCLUDE zsf_rs_form_181.


START-OF-SELECTION.

  PERFORM get_data.
  PERFORM process_data.
