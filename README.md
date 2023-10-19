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
   
2. Create a table of stock tickers. 
3. Create an instance of class.
4. Insert tickers into from table into db (zaticker).
5. Get business info of tickers and save it into db (zatickerinf). 
6. Get ticker's price and save it into db (zatickerpr).
7. Periodicaly update ticker's price and save it into db (zatickerpr).

