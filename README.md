# Stock Market Data Model For ABAP Cloud
This data model has been created for educational purposes. All code is valid for ABAP Cloud (BTP ABAP Environment). 

Before using this model, register a FREE API KEY on https://polygon.io/  and put it on local class at line 57.

Model consists of 3 tables and 1 class. 
1. ZATICKER contains stock tickers.
![zatickeralt text](https://github.com/analiteg/stock_market_data/blob/main/img/zaticker.png)
2. ZATICKERINF contains information about tickers from table 1.
3. ZATICKERPR contains price and volume information for tickers from table 1.
   
  All methods for data manipulation are stored in local class. Global class contains commented code snippets for data gathering.

## How to use.

   Download this model via AbapGit to your package and open global class in Eclipse.
   
1. Create a table of stock tickers.
```abap
    DATA lt_tickers TYPE STANDARD TABLE OF zaticker.
    lt_tickers = VALUE #( ( ticker = 'AAPL' )
                          ( ticker = 'MSFT' )
                          ( tic1ker = 'TSLA')
                          ( ticker = 'NVDA' )
                          ( ticker = 'META' )
                          ( ticker = 'NFLX' )
                          ( ticker = 'GOOGL' ) ).
```
2. Create an instance of class.
```abap
DATA(mo_stocks) = lcl_stocks=>create_instance( ).
```
3. Insert tickers from table into db (zaticker).
```abap
    TRY.
        out->write( mo_stocks->insert_tickers( lt_tickers ) ).
      CATCH cx_root INTO DATA(exc).
        out->write( exc->get_text( ) ).
    ENDTRY.
```
4. Get business info of tickers and save it into db (zatickerinf).
```abap
    TRY.
        out->write( mo_stocks->save_tickers_info_to_db( lt_tickers = mo_stocks->get_tickers_name( ) ) ).
      CATCH cx_root INTO DATA(exc).
        out->write( exc->get_text( ) ).
    ENDTRY.
```
5. Get ticker's price and save it into db (zatickerpr).
```abap   
    TRY.
        out->write( mo_stocks->save_ticker_price_into_db( lt_tickers = mo_stocks->get_ticker_name( ) ) ).
      CATCH cx_root INTO DATA(exc).
        out->write( exc->get_text( ) ).
    ENDTRY.
```
6. Periodicaly update ticker's price and save it into db (zatickerpr).
```abap
    TRY.
        out->write( mo_stocks->update_ticker_price_into_db( lt_tickers = mo_stocks->get_ticker_name( ) ) ).
      CATCH cx_root INTO DATA(exc).
        out->write( exc->get_text( ) ).
    ENDTRY.
```
