FUNCTION z5026_fm_idoc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_KUNNR) TYPE  KUNNR
*"  EXPORTING
*"     REFERENCE(ES_RETURN) TYPE  Z5026_S_IDOC
*"----------------------------------------------------------------------

  IF iv_kunnr IS NOT INITIAL.


    DATA: lt_edidd TYPE TABLE OF edidd,
          lt_edidc TYPE TABLE OF edidc.

    CLEAR : lt_edidc, lt_edidd.

    SELECT SINGLE
      name1,
      ort02,
      stras,
      ort01,
      regio,
      land1
      FROM kna1
      INTO CORRESPONDING FIELDS OF @es_return
      WHERE kunnr EQ @iv_kunnr.

    IF sy-subrc EQ 0.

      DATA(ls_edidc) = VALUE edidc( mestyp = 'Z5026_IDOCTS'
                                    doctyp = 'Z5026_IDOC'
                                    rcvprn = 'S4HCLNT500'
                                    rcvprt = 'LS' ).

      APPEND INITIAL LINE TO lt_edidd ASSIGNING FIELD-SYMBOL(<fs_edidd>).
      <fs_edidd>-segnam = 'Z5026_IDOC'.
      <fs_edidd>-sdata  = |{ es_return-land1 }{ es_return-name1 }{ es_return-ort02 }{ es_return-stras }{ es_return-ort01 }{ es_return-regio }|.


      CALL FUNCTION 'MASTER_IDOC_DISTRIBUTE'
        EXPORTING
          master_idoc_control            = ls_edidc
        TABLES
          communication_idoc_control     = lt_edidc
          master_idoc_data               = lt_edidd
        EXCEPTIONS
          error_in_idoc_control          = 1
          error_writing_idoc_status      = 2
          error_in_idoc_data             = 3
          sending_logical_system_unknown = 4
          OTHERS                         = 5.

      IF sy-subrc EQ 0.
        CALL FUNCTION 'DB_COMMIT'.
        CALL FUNCTION 'DEQUEUE_ALL'.
        COMMIT WORK.

      ENDIF.
    ENDIF.



  ENDIF.





ENDFUNCTION.
