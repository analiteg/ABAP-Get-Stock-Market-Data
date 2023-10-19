# Stock Market Data Model For ABAP Cloud
This data model has been created for educational purposes. All code is valid for ABAP Cloud (BTP ABAP Environment). 

Before using this model, register a FREE API KEY on https://polygon.io/  and put it on local class at line 57.

Model consists of 3 tables and 1 class. 
1. ZATICKER contains stock tickers.
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
                          ( tic1ker = 'TSLA' )
                          ( ticker = 'NVDA' )
                          ( ticker = 'META' )
                          ( ticker = 'NFLX' )
                          ( ticker = 'GOOGL' ) ).
```
2. Create an instance of class.
```abap
DATA(mo_stocks) = lcl_stocks=>create_instance( ).
```
3. Insert tickers into from table into db (zaticker).
4. Get business info of tickers and save it into db (zatickerinf). 
5. Get ticker's price and save it into db (zatickerpr).
6. Periodicaly update ticker's price and save it into db (zatickerpr).

