module CryptoComExchange.Decoder exposing
    ( accountSummaryResponse
    , candlestickResponse
    , instrumentListResponse
    , orderReferenceResponse
    , tickerListResponse
    , tickerResponse
    , tradeListResponse
    , unitResponse
    )

import CryptoComExchange exposing (Account, Candle, Candlestick, Instrument, OrderId(..), OrderReference, Ticker, Trade)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)
import Time


instrumentListResponse : Decode.Decoder (List Instrument)
instrumentListResponse =
    Decode.field "instruments" (Decode.list instrument)
        |> cryptoResponse
        |> Decode.map (\response -> response.result)


instrument : Decode.Decoder Instrument
instrument =
    Decode.succeed Instrument
        |> required "instrument_name" Decode.string
        |> required "quote_currency" Decode.string
        |> required "base_currency" Decode.string
        |> required "price_decimals" Decode.int
        |> required "quantity_decimals" Decode.int
        |> required "margin_trading_enabled" Decode.bool


tickerListResponse : Decode.Decoder (List Ticker)
tickerListResponse =
    Decode.field "data" (Decode.list ticker)
        |> cryptoResponse
        |> Decode.map (\response -> response.result)


tickerResponse : Decode.Decoder Ticker
tickerResponse =
    Decode.field "data" ticker
        |> cryptoResponse
        |> Decode.map (\response -> response.result)


ticker : Decode.Decoder Ticker
ticker =
    Decode.succeed Ticker
        |> required "i" Decode.string
        |> required "b" Decode.float
        |> required "k" Decode.float
        |> required "a" Decode.float
        |> required "t" Decode.int
        |> required "v" Decode.float
        |> required "h" Decode.float
        |> required "l" Decode.float
        |> required "c" Decode.float


candlestickResponse : Decode.Decoder Candlestick
candlestickResponse =
    candlestick
        |> cryptoResponse
        |> Decode.map (\response -> response.result)


candlestick : Decode.Decoder Candlestick
candlestick =
    Decode.succeed Candlestick
        |> required "instrument_name" Decode.string
        |> required "interval" Decode.string
        |> required "data" (Decode.list candle)


candle : Decode.Decoder Candle
candle =
    Decode.succeed Candle
        |> required "t" Decode.int
        |> required "o" Decode.float
        |> required "h" Decode.float
        |> required "l" Decode.float
        |> required "c" Decode.float
        |> required "v" Decode.float


tradeListResponse : Decode.Decoder (List Trade)
tradeListResponse =
    Decode.field "data" (Decode.list trade)
        |> cryptoResponse
        |> Decode.map .result


trade : Decode.Decoder Trade
trade =
    Decode.succeed Trade
        |> required "i" Decode.string
        |> required "p" Decode.float
        |> required "q" Decode.float
        |> required "s" Decode.string
        |> required "d" Decode.int
        |> required "t" timeInMillis


timeInMillis : Decode.Decoder Time.Posix
timeInMillis =
    Decode.int
        |> Decode.map Time.millisToPosix


accountSummaryResponse : Decode.Decoder (List Account)
accountSummaryResponse =
    account
        |> Decode.list
        |> Decode.field "accounts"
        |> cryptoResponse
        |> Decode.map .result


account : Decode.Decoder Account
account =
    Decode.succeed Account
        |> required "balance" Decode.float
        |> required "available" Decode.float
        |> required "order" Decode.float
        |> required "stake" Decode.float
        |> required "currency" Decode.string


unitResponse : Decode.Decoder ()
unitResponse =
    Decode.succeed ()
        |> cryptoResponse
        |> Decode.map .result


orderReferenceResponse : Decode.Decoder OrderReference
orderReferenceResponse =
    orderReference
        |> cryptoResponse
        |> Decode.map .result


orderReference : Decode.Decoder OrderReference
orderReference =
    Decode.succeed OrderReference
        |> required "order_id" orderId
        |> required "client_oid" Decode.string


orderId : Decode.Decoder OrderId
orderId =
    Decode.map OrderId Decode.string


type alias CryptoResponse result =
    { method : String
    , code : Int
    , result : result
    }


cryptoResponse : Decode.Decoder result -> Decode.Decoder (CryptoResponse result)
cryptoResponse decoder =
    Decode.succeed CryptoResponse
        |> required "method" Decode.string
        |> required "code" Decode.int
        |> required "result" decoder
