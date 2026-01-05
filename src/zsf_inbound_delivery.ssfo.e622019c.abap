IF ls_lips-meins = 'EA' OR ls_lips-meins = 'PC'.
  gv_disp_qty = |{ ls_lips-lfimg DECIMALS = 0 }|.
ELSE.
  gv_disp_qty = |{ ls_lips-lfimg DECIMALS = 3 }|.
ENDIF.
