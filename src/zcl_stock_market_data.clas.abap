CLASS zcl_stock_market_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_stock_market_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Step 1 - Create Table Of Stock Tickers
    DATA lt_tickers TYPE STANDARD TABLE OF zaticker.

    lt_tickers = VALUE #( ( ticker = 'AAPL' )
                          ( ticker = 'MSFT' )
                          ( ticker = 'TSLA' )
                          ( ticker = 'NVDA' )
                          ( ticker = 'META' )
                          ( ticker = 'NFLX' )
                          ( ticker = 'GOOGL' ) ).

    " Step 2 - Create instance (singleton)
    DATA(mo_stocks) = lcl_stocks=>create_instance( ).

    " Step 3 - Insert Tickers Into DB
*    TRY.
*        out->write( mo_stocks->insert_tickers( lt_tickers ) ).
*      CATCH cx_root INTO DATA(exc).
*        out->write( exc->get_text( ) ).
*    ENDTRY.

    " Step 4 - Save Tickers Info Into DB
*    TRY.
*        out->write( mo_stocks->save_tickers_info_to_db( lt_tickers = mo_stocks->get_tickers_name( ) ) ).
*      CATCH cx_root INTO DATA(exc).
*        out->write( exc->get_text( ) ).
*    ENDTRY.

    " Step 5 - Save Tickers Prices Into DB
*    TRY.
*        out->write( mo_stocks->save_ticker_price_into_db( lt_tickers = mo_stocks->get_ticker_name( ) ) ).
*      CATCH cx_root INTO DATA(exc).
*        out->write( exc->get_text( ) ).
*    ENDTRY.

    " Step 6 - Update Ticker Prices Into DB
    TRY.
        out->write( mo_stocks->update_ticker_price_into_db( lt_tickers = mo_stocks->get_ticker_name( ) ) ).
      CATCH cx_root INTO DATA(exc).
        out->write( exc->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
