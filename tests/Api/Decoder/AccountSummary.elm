module Api.Decoder.AccountSummary exposing (..)

import CryptoComExchange.Decoder as Decoder
import Expect
import Json.Decode exposing (decodeString)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CryptoExchange.Api.Decoder.AccountSummary"
        [ test
            "Decode Get Account Summary"
            (\_ ->
                exampleResponse
                    |> decodeString Decoder.accountSummaryResponse
                    |> Result.map List.length
                    |> Expect.equal (Ok 1)
            )
        ]


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
