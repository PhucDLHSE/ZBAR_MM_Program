CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
  EXPORTING
    input          = ls_lips-meins
    language       = sy-langu
  IMPORTING
    output         = ls_lips-meins
  EXCEPTIONS
    unit_not_found = 1
    OTHERS         = 2.
























