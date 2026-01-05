*&---------------------------------------------------------------------*
*& Include          ZG21_INB_INPUT_SEL
*&---------------------------------------------------------------------*

* A. selection screen
INITIALIZATION.
*  nase-kappl = appl.

  SELECTION-SCREEN BEGIN OF BLOCK delivery WITH FRAME TITLE TEXT-002.
    SELECT-OPTIONS:
* Inbound Delivery (LIKP-VBELN)
      rg_vbeln FOR likp-vbeln, " MEMORY ID VLM MATCHCODE OBJECT VMVM,
* Supplier (LIKP-LIFNR)
      rg_lifnr FOR likp-lifnr, " MEMORY ID LIF,
* Delivery Date (LIKP-LFDAT)
      rg_lfdat FOR likp-lfdat,
* Shipping Point / Receiving Plant (LIKP-VSTEL)
      rg_vstel FOR likp-vstel.
  SELECTION-SCREEN END OF BLOCK delivery.

  SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF BLOCK printmode WITH FRAME TITLE TEXT-003.
    PARAMETERS: p_prev RADIOBUTTON GROUP pm DEFAULT 'X',
                p_prnt RADIOBUTTON GROUP pm.
  SELECTION-SCREEN END OF BLOCK printmode.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR rg_vbeln-low.
  PERFORM f4_vbeln.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR rg_vbeln-high.
  PERFORM f4_vbeln.
