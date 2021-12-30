module Api.Decoder.InstrumentList exposing (suite)

import CryptoComExchange.Decoder as Decoder
import Expect
import Json.Decode exposing (decodeString)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CryptoExchange.Api.Decoder.InstrumentList"
        [ test
            "decode instrument list"
            (\_ ->
                exampleResponseList
                    |> decodeString Decoder.decodeInstrumentListResponse
                    |> Expect.ok
            )
        , test
            "decode base currency in instrument list"
            (\_ ->
                exampleResponseList
                    |> decodeString Decoder.decodeInstrumentListResponse
                    |> Result.mapError (always "failed to decode")
                    |> Result.map List.head
                    |> Result.andThen (Result.fromMaybe "no instrument found")
                    |> Result.map (\instrument -> instrument.baseCurrency)
                    |> Expect.equal (Ok "USDT")
            )
        ]


exampleResponseList : String
exampleResponseList =
    """{
   "id": 11,
   "method": "public/get-instruments",
   "code": 0,
   "result": {
     "instruments": [
       {
         "instrument_name": "BTC_USDT",
         "quote_currency": "BTC",
         "base_currency": "USDT",
         "price_decimals": 2,
         "quantity_decimals": 6,
         "margin_trading_enabled": true

       },
       {
         "instrument_name": "CRO_BTC",
         "quote_currency": "BTC",
         "base_currency": "CRO",
         "price_decimals": 8,
         "quantity_decimals": 2,
         "margin_trading_enabled": false
       }
     ]
   }
}"""
