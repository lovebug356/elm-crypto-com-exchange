module Api.Decoder.TradeList exposing (..)

import CryptoComExchange
import CryptoComExchange.Decoder as Decoder
import Expect
import Json.Decode exposing (decodeString)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CryptoExchange.Api.Decoder.TradeList"
        [ test
            "Decode Get Ticker List"
            (\_ ->
                exampleResponseTradeList
                    |> decodeString Decoder.tradeListResponse
                    |> expectFirstInstrumentName "ICX_CRO"
            )
        , test
            "Decode example from real server"
            (\_ ->
                exampleFromRealServer
                    |> decodeString Decoder.tradeListResponse
                    |> Expect.ok
            )
        ]


expectFirstInstrumentName : String -> Result Json.Decode.Error (List CryptoComExchange.Trade) -> Expect.Expectation
expectFirstInstrumentName name result =
    result
        |> Result.mapError (always "failed to code trade list")
        |> Result.map List.head
        |> Result.andThen (Result.fromMaybe "no empty trade list expected")
        |> Result.map .instrumentName
        |> Expect.equal (Ok name)


exampleResponseTradeList : String
exampleResponseTradeList =
    """{
  "code":0,
  "method":"public/get-trades",
  "result": {
      "data": [
    {"dataTime":1591710781947,"d":465533583799589409,"s":"BUY","p":2.96,"q":16.0,"t":1591710781946,"i":"ICX_CRO"},
    {"dataTime":1591707701899,"d":465430234542863152,"s":"BUY","p":0.007749,"q":115.0,"t":1591707701898,"i":"VET_USDT"},
    {"dataTime":1591710786155,"d":465533724976458209,"s":"SELL","p":25.676,"q":0.55,"t":1591710786154,"i":"XTZ_CRO"},
    {"dataTime":1591710783300,"d":465533629172286576,"s":"SELL","p":2.9016,"q":0.6,"t":1591710783298,"i":"XTZ_USDT"},
    {"dataTime":1591710784499,"d":465533669425626384,"s":"SELL","p":2.7662,"q":0.58,"t":1591710784498,"i":"EOS_USDT"},
    {"dataTime":1591710784700,"d":465533676120104336,"s":"SELL","p":243.21,"q":0.01647,"t":1591710784698,"i":"ETH_USDT"},
    {"dataTime":1591710786600,"d":465533739878620208,"s":"SELL","p":253.06,"q":0.00516,"t":1591710786598,"i":"BCH_USDT"},
    {"dataTime":1591710786900,"d":465533749959572464,"s":"BUY","p":0.9999,"q":0.2,"t":1591710786898,"i":"USDC_USDT"},
    {"dataTime":1591710787500,"d":465533770081010000,"s":"BUY","p":3.159,"q":1.65,"t":1591710787498,"i":"ATOM_USDT"}
      ]
  }
}"""


exampleFromRealServer : String
exampleFromRealServer =
    """{"code":0,"method":"public/get-trades","result":{"data": 
    [
         {"dataTime":1640445411311,"d":2100796390820962149,"s":"SELL","p":0.17458,"q":8.9,"t":1640445411310,"i":"BRZ_USDT"}
    ] }}"""
