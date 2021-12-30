module CryptoComExchange.Decoder exposing
    ( decodeAccountSummaryResponse
    , decodeCandlestickResponse
    , decodeInstrumentListResponse
    , decodeTickerListResponse
    , decodeTickerResponse
    , decodeTradeListResponse
    , decodeUnitResponse
    , orderReferenceResponse
    )

import CryptoComExchange exposing (Account, Candle, Candlestick, Instrument, InstrumentName(..), OrderId(..), OrderReference, Ticker, Trade)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)
import Time


decodeInstrumentListResponse : Decode.Decoder (List Instrument)
decodeInstrumentListResponse =
    Decode.field "instruments" (Decode.list decodeInstrument)
        |> decodeCryptoResponse
        |> Decode.map (\response -> response.result)


decodeInstrument : Decode.Decoder Instrument
decodeInstrument =
    Decode.succeed Instrument
        |> required "instrument_name" decodeInstrumentNameDecoder
        |> required "base_currency" Decode.string
        |> required "quote_currency" Decode.string
        |> required "price_decimals" Decode.int
        |> required "quantity_decimals" Decode.int
        |> required "margin_trading_enabled" Decode.bool


decodeTickerListResponse : Decode.Decoder (List Ticker)
decodeTickerListResponse =
    Decode.field "data" (Decode.list decodeTicker)
        |> decodeCryptoResponse
        |> Decode.map (\response -> response.result)


decodeTickerResponse : Decode.Decoder Ticker
decodeTickerResponse =
    Decode.field "data" decodeTicker
        |> decodeCryptoResponse
        |> Decode.map (\response -> response.result)


decodeTicker : Decode.Decoder Ticker
decodeTicker =
    Decode.succeed Ticker
        |> required "i" decodeInstrumentNameDecoder
        |> required "b" Decode.float
        |> required "k" Decode.float
        |> required "a" Decode.float
        |> required "t" Decode.int
        |> required "v" Decode.float
        |> required "h" Decode.float
        |> required "l" Decode.float
        |> required "c" Decode.float


decodeInstrumentNameDecoder : Decode.Decoder InstrumentName
decodeInstrumentNameDecoder =
    Decode.map InstrumentName Decode.string


decodeCandlestickResponse : Decode.Decoder Candlestick
decodeCandlestickResponse =
    decodeCandlestick
        |> decodeCryptoResponse
        |> Decode.map (\response -> response.result)


decodeCandlestick : Decode.Decoder Candlestick
decodeCandlestick =
    Decode.succeed Candlestick
        |> required "instrument_name" Decode.string
        |> required "interval" Decode.string
        |> required "data" (Decode.list decodeCandle)


decodeCandle : Decode.Decoder Candle
decodeCandle =
    Decode.succeed Candle
        |> required "t" Decode.int
        |> required "o" Decode.float
        |> required "h" Decode.float
        |> required "l" Decode.float
        |> required "c" Decode.float
        |> required "v" Decode.float


decodeTradeListResponse : Decode.Decoder (List Trade)
decodeTradeListResponse =
    Decode.field "data" (Decode.list decodeTrade)
        |> decodeCryptoResponse
        |> Decode.map .result


decodeTrade : Decode.Decoder Trade
decodeTrade =
    Decode.succeed Trade
        |> required "i" Decode.string
        |> required "p" Decode.float
        |> required "q" Decode.float
        |> required "s" Decode.string
        |> required "d" Decode.int
        |> required "t" decodeTimeInMillis


decodeTimeInMillis : Decode.Decoder Time.Posix
decodeTimeInMillis =
    Decode.int
        |> Decode.map Time.millisToPosix


decodeAccountSummaryResponse : Decode.Decoder (List Account)
decodeAccountSummaryResponse =
    decodeAccount
        |> Decode.list
        |> Decode.field "accounts"
        |> decodeCryptoResponse
        |> Decode.map .result


decodeAccount : Decode.Decoder Account
decodeAccount =
    Decode.succeed Account
        |> required "balance" Decode.float
        |> required "available" Decode.float
        |> required "order" Decode.float
        |> required "stake" Decode.float
        |> required "currency" Decode.string


decodeUnitResponse : Decode.Decoder ()
decodeUnitResponse =
    Decode.succeed ()
        |> decodeCryptoResponse
        |> Decode.map .result


orderReferenceResponse : Decode.Decoder OrderReference
orderReferenceResponse =
    decodeOrderReference
        |> decodeCryptoResponse
        |> Decode.map .result


decodeOrderReference : Decode.Decoder OrderReference
decodeOrderReference =
    Decode.succeed OrderReference
        |> required "order_id" decodeOrderId
        |> required "client_oid" Decode.string


decodeOrderId : Decode.Decoder OrderId
decodeOrderId =
    Decode.map OrderId Decode.string


type alias CryptoResponse result =
    { method : String
    , code : Int
    , result : result
    }


decodeCryptoResponse : Decode.Decoder result -> Decode.Decoder (CryptoResponse result)
decodeCryptoResponse decoder =
    Decode.succeed CryptoResponse
        |> required "method" Decode.string
        |> required "code" Decode.int
        |> required "result" decoder
