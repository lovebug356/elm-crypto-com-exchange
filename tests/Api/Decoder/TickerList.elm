module Api.Decoder.TickerList exposing (..)

import CryptoComExchange.Decoder as Decoder
import Expect
import Json.Decode exposing (decodeString)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CryptoExchange.Api.Decoder.TickerList"
        [ test
            "decode ticker list"
            (\_ ->
                exampleResponseTickerList
                    |> decodeString Decoder.decodeTickerListResponse
                    |> Expect.ok
            )
        , test
            "decode ticker"
            (\_ ->
                exampleResponseTicker
                    |> decodeString Decoder.decodeTickerResponse
                    |> Expect.ok
            )
        ]


exampleResponseTickerList : String
exampleResponseTickerList =
    """{
  "code":0,
  "method":"public/get-ticker",
  "result":{
    "data": [
      {"i":"CRO_BTC","b":0.00000890,"k":0.00001179,"a":0.00001042,"t":1591770793901,"v":14905879.59,"h":0.00,"l":0.00,"c":0.00},
      {"i":"EOS_USDT","b":2.7676,"k":2.7776,"a":2.7693,"t":1591770798500,"v":774.51,"h":0.05,"l":0.05,"c":0.00},
      {"i":"BCH_USDT","b":247.49,"k":251.73,"a":251.67,"t":1591770797601,"v":1.01693,"h":0.01292,"l":0.01231,"c":-0.00047},
      {"i":"ETH_USDT","b":239.92,"k":242.59,"a":240.30,"t":1591770798701,"v":0.97575,"h":0.01236,"l":0.01199,"c":-0.00018},
      {"i":"ETH_CRO","b":2693.11,"k":2699.84,"a":2699.55,"t":1591770795053,"v":95.680,"h":8.218,"l":7.853,"c":-0.050}
    ]
  }
}"""


exampleResponseTicker : String
exampleResponseTicker =
    """{
  "code":0,
  "method":"public/get-ticker",
  "result":{
    "data": {
      "i":"CRO_BTC",
      "b":0.00000890,
      "k":0.00001179,
      "a":0.00001042,
      "t":1591770793901,
      "v":14905879.59,
      "h":0.00,
      "l":0.00,
      "c":0.00
    }
  }
}"""
