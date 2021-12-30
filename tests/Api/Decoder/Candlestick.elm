module Api.Decoder.Candlestick exposing (..)

import CryptoComExchange.Decoder as Decoder
import Expect
import Json.Decode exposing (decodeString)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CryptoExchange.Api.Decoder.InstrumentList"
        [ test
            "Decode Get Instruments"
            (\_ ->
                exampleResponse
                    |> decodeString Decoder.decodeCandlestickResponse
                    |> Expect.ok
            )
        ]


exampleResponse =
    """{
  "code":0,
  "method":"public/get-candlestick",
  "result":{
    "instrument_name":"BTC_USDT",
    "interval":"5m",
    "data":[
      {"t":1596944700000,"o":11752.38,"h":11754.77,"l":11746.65,"c":11753.64,"v":3.694583},
      {"t":1596945000000,"o":11753.63,"h":11754.77,"l":11739.83,"c":11746.17,"v":2.073019},
      {"t":1596945300000,"o":11746.16,"h":11753.24,"l":11738.1,"c":11740.65,"v":0.867247}
    ]
  }
}"""
