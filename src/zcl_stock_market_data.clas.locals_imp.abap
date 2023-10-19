CLASS lcl_stocks DEFINITION CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES ty_ticker_info  TYPE STANDARD TABLE OF zatickerinf WITH EMPTY KEY.
    TYPES ty_ticker_price TYPE STANDARD TABLE OF zatickerpr WITH EMPTY KEY.

    CLASS-METHODS create_instance
      RETURNING VALUE(ro_stocks) TYPE REF TO lcl_stocks.

    METHODS save_ticker_into_db
      IMPORTING lt_tickers       TYPE STANDARD TABLE
      RETURNING VALUE(rv_status) TYPE string
      RAISING   cx_static_check.

    METHODS create_client
      IMPORTING url           TYPE string
      RETURNING VALUE(result) TYPE REF TO if_web_http_client
      RAISING   cx_static_check.

    METHODS get_ticker_name
      RETURNING VALUE(rt_ticker) TYPE  string_table
      RAISING   cx_static_check.

    METHODS get_ticker_data
      IMPORTING lv_ticker             TYPE string
      RETURNING VALUE(rt_ticker_info) TYPE ty_ticker_info
      RAISING   cx_static_check.

    METHODS save_ticker_info_into_db
      IMPORTING lt_tickers       TYPE STANDARD TABLE
      RETURNING VALUE(rv_status) TYPE string
      RAISING   cx_static_check.

    METHODS get_ticker_price
      IMPORTING lv_ticker              TYPE string
                lv_start_date          TYPE d
      RETURNING VALUE(rt_ticker_price) TYPE ty_ticker_price
      RAISING   cx_static_check.

    METHODS save_ticker_price_into_db
      IMPORTING lt_tickers          TYPE STANDARD TABLE
      RETURNING VALUE(rv_tp_status) TYPE string
      RAISING   cx_static_check.

    METHODS update_ticker_price_into_db
      IMPORTING lt_tickers          TYPE STANDARD TABLE
      RETURNING VALUE(rv_tp_status) TYPE string
      RAISING   cx_static_check.

  PRIVATE SECTION.
    CLASS-DATA lo_stocks TYPE REF TO lcl_stocks.

    CONSTANTS base_url_get_info  TYPE string VALUE 'https://api.polygon.io/v3/reference/tickers/'.
    CONSTANTS base_url_get_price TYPE string VALUE 'https://api.polygon.io/v2/aggs/ticker/'.
    CONSTANTS content_type       TYPE string VALUE 'Content-type'.
    CONSTANTS json_content       TYPE string VALUE 'application/json; charset=UTF-8'.
    CONSTANTS co_apikey          TYPE string VALUE 'fdiO0J9lKjWfyY37dAYLJWZsz9QW9NpQ'.
ENDCLASS.


CLASS lcl_stocks IMPLEMENTATION.
  METHOD create_instance.
    ro_stocks = COND #( WHEN lo_stocks IS BOUND
                        THEN lo_stocks
                        ELSE NEW lcl_stocks( )  ).
    lo_stocks = ro_stocks.
  ENDMETHOD.

  METHOD save_ticker_into_db.
    INSERT zaticker FROM TABLE @lt_tickers ACCEPTING DUPLICATE KEYS.
    IF sy-subrc = 0.
      rv_status = | Inserted | & |{ lines( lt_tickers ) }| & | rows|.
    ELSE.
      rv_status = | Error | & |{ sy-subrc }|.
    ENDIF.
  ENDMETHOD.

  METHOD create_client.
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD.

  METHOD get_ticker_name.
    SELECT FROM zaticker
              FIELDS ticker
              INTO  TABLE @DATA(rt_return).
    IF sy-subrc = 0.
      rt_ticker = rt_return.
    ENDIF.
  ENDMETHOD.

  METHOD get_ticker_data.
    DATA(l_url) = |{ base_url_get_info }| & |{ lv_ticker }| & |?apiKey=| & |{ co_apikey }|.
    DATA(client) = create_client( l_url ).
    DATA(response) = client->execute( if_web_http_client=>get )->get_text( ).
    client->close( ).

    DATA lr_data   TYPE REF TO data.
    DATA ls_result TYPE LINE OF ty_ticker_info.
    DATA lt_tbls   TYPE LINE OF ty_ticker_info.
    DATA lv_fname  TYPE string.
    DATA lv_fname2 TYPE string.
    DATA lv_fname3 TYPE string.

    /ui2/cl_json=>deserialize( EXPORTING json         = response
                                         pretty_name  = /ui2/cl_json=>pretty_mode-user
                                         assoc_arrays = abap_true
                               CHANGING  data         = lr_data ).

    ASSIGN lr_data->* TO FIELD-SYMBOL(<fs_data>).
    ASSIGN COMPONENT 'RESULTS' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_all_results>).
    ASSIGN <fs_all_results>->* TO FIELD-SYMBOL(<fs_all_results_value>).

    DO 25 TIMES. " Number of fields
      CLEAR lv_fname.
      CASE sy-index.
        WHEN 1. lv_fname = 'ACTIVE'.
        WHEN 2. lv_fname = 'ADDRESS'.
        WHEN 3. lv_fname = 'BRANDING'.
        WHEN 4. lv_fname = 'CIK'.
        WHEN 5. lv_fname = 'COMPOSITE_FIGI'.
        WHEN 6. lv_fname = 'CURRENCY_NAME'.
        WHEN 7. lv_fname = 'DESCRIPTION'.
        WHEN 8. lv_fname = 'HOMEPAGE_URL'.
        WHEN 9. lv_fname = 'LIST_DATE'.
        WHEN 10. lv_fname = 'LOCALE'.
        WHEN 11. lv_fname = 'MARKET'.
        WHEN 12. lv_fname = 'MARKET_CAP'.
        WHEN 13. lv_fname = 'NAME'.
        WHEN 14. lv_fname = 'PHONE_NUMBER'.
        WHEN 15. lv_fname = 'PRIMARY_EXCHANGE'.
        WHEN 16. lv_fname = 'ROUND_LOT'.
        WHEN 17. lv_fname = 'SHARE_CLASS_FIGI'.
        WHEN 18. lv_fname = 'SHARE_CLASS_SHARES_OUTSTANDING'.
        WHEN 19. lv_fname = 'SIC_CODE'.
        WHEN 20. lv_fname = 'SIC_DESCRIPTION'.
        WHEN 21. lv_fname = 'TICKER'.
        WHEN 22. lv_fname = 'TICKER_ROOT'.
        WHEN 23. lv_fname = 'TOTAL_EMPLOYEES'.
        WHEN 24. lv_fname = 'TYPE'.
        WHEN 25. lv_fname = 'WEIGHTED_SHARES_OUTSTANDINGP'.
      ENDCASE.

      CASE lv_fname.
        WHEN 'ADDRESS'.
          ASSIGN COMPONENT lv_fname OF STRUCTURE <fs_all_results_value> TO FIELD-SYMBOL(<fs_ticker>).

          DO 4 TIMES. " Number of fields
            CASE sy-index.
              WHEN 1. lv_fname2 = 'ADDRESS1'.
              WHEN 2. lv_fname2 = 'CITY'.
              WHEN 3. lv_fname2 = 'POSTAL_CODE'.
              WHEN 4. lv_fname2 = 'STATE'.
            ENDCASE.

            ASSIGN <fs_ticker>->* TO FIELD-SYMBOL(<fs_ticker2>).
            ASSIGN COMPONENT lv_fname2 OF STRUCTURE <fs_ticker2> TO FIELD-SYMBOL(<fs_ticker3>).
            ASSIGN COMPONENT lv_fname2 OF STRUCTURE ls_result TO FIELD-SYMBOL(<fs_ticker_value>).
            ASSIGN <fs_ticker3>->* TO FIELD-SYMBOL(<lfs_row_val>).
            <fs_ticker_value> = <lfs_row_val>.
          ENDDO.

        WHEN 'BRANDING'.

          ASSIGN COMPONENT lv_fname OF STRUCTURE <fs_all_results_value> TO <fs_ticker>.
          DO 2 TIMES. " Number of fields
            CLEAR lv_fname3.
            CASE sy-index.
              WHEN 1. lv_fname3 = 'ICON_URL'.
              WHEN 2.
                lv_fname3 = 'LOGO_URL'.
            ENDCASE.

            ASSIGN <fs_ticker>->* TO FIELD-SYMBOL(<fs_ticker4>).
            ASSIGN COMPONENT lv_fname3 OF STRUCTURE <fs_ticker4> TO FIELD-SYMBOL(<fs_ticker5>).
            ASSIGN COMPONENT lv_fname3 OF STRUCTURE ls_result TO <fs_ticker_value>.
            ASSIGN <fs_ticker5>->* TO <lfs_row_val>.
            <fs_ticker_value> = <lfs_row_val>.
          ENDDO.

        WHEN OTHERS.
          ASSIGN COMPONENT lv_fname OF STRUCTURE <fs_all_results_value> TO <fs_ticker>.
          ASSIGN COMPONENT lv_fname OF STRUCTURE ls_result TO <fs_ticker_value>.
          ASSIGN <fs_ticker>->* TO <lfs_row_val>.
          <fs_ticker_value> = <lfs_row_val>.
      ENDCASE.
    ENDDO.

    ls_result-logo_url = |https://analiteg.github.io/img/| & |{ lv_ticker }| & |.svg|.
    ls_result-icon_url = |https://analiteg.github.io/img/| & |{ lv_ticker }| & |.png|.
    MOVE-CORRESPONDING ls_result TO lt_tbls.
    APPEND lt_tbls TO rt_ticker_info.
  ENDMETHOD.

  METHOD save_ticker_info_into_db.
    DATA lt_info       TYPE ty_ticker_info.
    DATA lt_total_info TYPE ty_ticker_info.

    LOOP AT lt_tickers ASSIGNING FIELD-SYMBOL(<fs_ticker>).
      lt_info = get_ticker_data( lv_ticker = CONV #( <fs_ticker> ) ).
      APPEND LINES OF lt_info TO lt_total_info.
      WAIT UP TO 13 SECONDS.
    ENDLOOP.

    INSERT zatickerinf FROM TABLE @lt_total_info ACCEPTING DUPLICATE KEYS.

    IF sy-subrc <> 0.
      rv_status = 'Error'.
    ELSE.
      rv_status = 'Data inserted'.
    ENDIF.
  ENDMETHOD.

  METHOD get_ticker_price.
    DATA(l_url) = |{ base_url_get_price }| &
                      |{ lv_ticker }| &
                      |/range/1/day/| &
                      |{ lv_start_date  DATE = ISO }/| &
                      |{ cl_abap_context_info=>get_system_date( ) DATE = ISO }/| &
                      |?adjusted=true&sort=asc&limit=50000&apiKey=| &
                      |{ co_apikey }|.

    DATA(client) = create_client( l_url ).
    DATA(response) = client->execute( if_web_http_client=>get )->get_text( ).
    client->close( ).

    DATA lr_data TYPE REF TO data.

    /ui2/cl_json=>deserialize( EXPORTING json         = response
                                         pretty_name  = /ui2/cl_json=>pretty_mode-user
                                         assoc_arrays = abap_true
                               CHANGING  data         = lr_data ).

    " EOD data structure
    TYPES:
      BEGIN OF ty_results,
        c  TYPE p LENGTH 16 DECIMALS 4,
        h  TYPE p LENGTH 16 DECIMALS 4,
        l  TYPE p LENGTH 16 DECIMALS 4,
        n  TYPE i,
        o  TYPE p LENGTH 16 DECIMALS 4,
        t  TYPE timestamp,
        v  TYPE i,
        vw TYPE f,
      END OF ty_results.

    DATA ls_result    TYPE ty_results.
    DATA ls_endresult TYPE LINE OF ty_ticker_price.
    DATA lt_endresult TYPE ty_ticker_price.

    FIELD-SYMBOLS <lfs_table> TYPE ANY TABLE.

    ASSIGN lr_data->* TO FIELD-SYMBOL(<fs_data>).
    ASSIGN COMPONENT 'RESULTS' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_results>).
    ASSIGN <fs_results>->* TO <lfs_table>.

    LOOP AT <lfs_table> ASSIGNING FIELD-SYMBOL(<lfs_row>).
      DO 8 TIMES. " Number of fields
        CASE sy-index.
          WHEN 1. DATA(lv_fname) = 'C'.
          WHEN 2. lv_fname = 'H'.
          WHEN 3. lv_fname = 'L'.
          WHEN 4. lv_fname = 'N'.
          WHEN 5. lv_fname = 'O'.
          WHEN 6. lv_fname = 'T'.
          WHEN 7. lv_fname = 'V'.
          WHEN 8. lv_fname = 'VW'.
        ENDCASE.

        ASSIGN COMPONENT sy-index OF STRUCTURE ls_result TO FIELD-SYMBOL(<result_field>).
        ASSIGN <lfs_row>->* TO FIELD-SYMBOL(<lfs_row_val>).
        ASSIGN COMPONENT lv_fname OF STRUCTURE <lfs_row_val> TO FIELD-SYMBOL(<lfs_ref_value>).
        IF <lfs_ref_value> IS ASSIGNED AND <result_field> IS ASSIGNED.
          ASSIGN <lfs_ref_value>->* TO FIELD-SYMBOL(<lfs_actual_value>).
          IF <lfs_actual_value> IS ASSIGNED.
            <result_field> = <lfs_actual_value>.
          ENDIF.
        ENDIF.
      ENDDO.

      DATA(system_uuid) = cl_uuid_factory=>create_system_uuid( ).
      ls_endresult-ticker = lv_ticker.
      ls_endresult-uuid   = system_uuid->create_uuid_x16( ).
      MOVE-CORRESPONDING ls_result TO ls_endresult.
      APPEND ls_endresult TO lt_endresult.
    ENDLOOP.
    rt_ticker_price = lt_endresult.
  ENDMETHOD.

  METHOD save_ticker_price_into_db.
    DATA lt_prices       TYPE ty_ticker_price.
    DATA lt_total_prices TYPE ty_ticker_price.

    LOOP AT lt_tickers ASSIGNING FIELD-SYMBOL(<fs_ticker>).
      lt_prices = get_ticker_price( lv_ticker = CONV #( <fs_ticker> ) lv_start_date = '20210807'  ).
      APPEND LINES OF lt_prices TO lt_total_prices.
      WAIT UP TO 13 SECONDS.
    ENDLOOP.

    INSERT zatickerpr FROM TABLE @lt_total_prices ACCEPTING DUPLICATE KEYS.

    IF sy-subrc <> 0.
      rv_tp_status = 'Data not inserted'.
    ELSE.
      rv_tp_status = 'Data inserted'.
    ENDIF.
  ENDMETHOD.
  METHOD update_ticker_price_into_db.

    DATA: lv_ustart       TYPE d VALUE '19700101',
          up_date         TYPE d,
          lt_prices       TYPE ty_ticker_price,
          lt_total_prices TYPE ty_ticker_price.

    SELECT FROM zatickerpr
               FIELDS
               dats_add_days( @lv_ustart, CAST( div( div( MAX( t ), 1000 ), 86400 ) AS INT4 ) )
               INTO @DATA(lv_last_date).

    up_date = cl_abap_context_info=>get_system_date( ) - 1.

    IF ( lv_last_date > 0 ) AND ( lv_last_date <  up_date ).

      LOOP AT lt_tickers ASSIGNING FIELD-SYMBOL(<fs_ticker>).
        lt_prices = get_ticker_price( lv_ticker = CONV #( <fs_ticker> ) lv_start_date = lv_last_date  ).
        APPEND LINES OF lt_prices TO lt_total_prices.
        WAIT UP TO 13 SECONDS.
      ENDLOOP.

      MODIFY zatickerpr FROM TABLE @lt_total_prices.

        IF sy-subrc <> 0.
            rv_tp_status = 'Error during insert/update'.
        ELSE.
            rv_tp_status = 'Data inserted'.
        ENDIF.

    ELSE.
      rv_tp_status = 'Data UPDATED'.
    ENDIF.

  ENDMETHOD.


ENDCLASS.
