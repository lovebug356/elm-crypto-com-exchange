module Encoder exposing (..)

import CryptoComExchange exposing (InstrumentName(..), LimitOrderRequest, OrderSide(..))
import CryptoComExchange.Encoder as Encoder
import Dict
import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CryptoExchange.Encoder.LimitOrderRequest"
        [ test
            "Encode should include instrument_name"
            (\_ ->
                LimitOrderRequest (InstrumentName "BTC_USDT") Buy "1" "10"
                    |> Encoder.limitOrderRequestEncoder
                    |> expectDictionaryContains "instrument_name" "BTC_USDT"
            )
        , test "Encode should include buy side"
            (\_ ->
                LimitOrderRequest (InstrumentName "BTC_USDT") Buy "1" "10"
                    |> Encoder.limitOrderRequestEncoder
                    |> expectDictionaryContains "side" "BUY"
            )
        , test "Encode should include sell side"
            (\_ ->
                LimitOrderRequest (InstrumentName "BTC_USDT") Sell "1" "10"
                    |> Encoder.limitOrderRequestEncoder
                    |> expectDictionaryContains "side" "SELL"
            )
        , test "Encode should include side"
            (\_ ->
                LimitOrderRequest (InstrumentName "BTC_USDT") Sell "1" "10"
                    |> Encoder.limitOrderRequestEncoder
                    |> expectDictionaryContains "type" "LIMIT"
            )
        , test "Encode should include price"
            (\_ ->
                LimitOrderRequest (InstrumentName "BTC_USDT") Sell "1" "10"
                    |> Encoder.limitOrderRequestEncoder
                    |> expectDictionaryContains "price" "1"
            )
        , test "Encode should include quantity"
            (\_ ->
                LimitOrderRequest (InstrumentName "BTC_USDT") Sell "1" "10"
                    |> Encoder.limitOrderRequestEncoder
                    |> expectDictionaryContains "quantity" "10"
            )
        ]


expectDictionaryContains : String -> String -> Dict.Dict String String -> Expect.Expectation
expectDictionaryContains key value dict =
    Dict.get key dict
        |> Expect.equal (Just value)


exampleResponse : String
exampleResponse =
    """
{
    "id": 11,
    "method": "private/get-account-summary",
    "code": 0,
    "result": {
        "accounts": [
            {
                "balance": 99999999.905000000000000000,
                "available": 99999996.905000000000000000,
                "order": 3.000000000000000000,
                "stake": 0,
                "currency": "CRO"
            }
        ]
    }
}
    """
