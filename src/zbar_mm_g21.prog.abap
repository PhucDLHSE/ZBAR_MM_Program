*&---------------------------------------------------------------------*
*& Report ZBAR_G21
*&---------------------------------------------------------------------*
*& Main Menu Screen for Barcode Goods Movement
*&---------------------------------------------------------------------*
REPORT zbar_mm_g21.

INCLUDE zbar_mm_g21_t01.
INCLUDE zbar_mm_g21_pbo.
INCLUDE zbar_mm_g21_pai.
INCLUDE zbar_mm_g21_f01.

START-OF-SELECTION.
  CALL SCREEN 0100.
