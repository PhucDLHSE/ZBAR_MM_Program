*&---------------------------------------------------------------------*
*& Report ZSF_DRIVER_PROGRAM_181
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsf_in_178.

INCLUDE ZSF_IN_TOP_178.
*INCLUDE zsf_od_top_181.
INCLUDE ZSF_IN_SS_178.
*INCLUDE zsf_od_ss_181.
INCLUDE ZSF_IN_FORM_178.
*INCLUDE zsf_od_form_181.


START-OF-SELECTION.

  PERFORM get_data.
  PERFORM process_data.
