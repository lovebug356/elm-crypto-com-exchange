module CryptoComExchange.Api exposing
    ( getTradeList, getTickerList, getTicker, getCandlestick, getInstruments
    , getAccountSummary, createOrder, cancelOrder
    )

{-| This module provides a REST API to the crypto.com exchange.


# Public API

@docs getTradeList, getTickerList, getTicker, getCandlestick, getInstruments


# Private API

@docs getAccountSummary, createOrder, cancelOrder

-}

import CryptoComExchange exposing (Account, Candlestick, Instrument, InstrumentName(..), Interval(..), LimitOrderRequest, OrderId(..), OrderReference, Ticker, Trade)
import CryptoComExchange.Configuration exposing (Configuration, PrivateConfiguration)
import CryptoComExchange.Decoder as Decoder
import CryptoComExchange.Encoder exposing (limitOrderRequestEncoder)
import CryptoComExchange.RequestBuilder as RequestBuilder
import Http exposing (Error)


type alias ResponseHandler a msg =
    (Result Error a -> msg) -> Cmd msg


{-| Provides information on all supported instruments (e.g. BTC\_USDT)
-}
getInstruments : Configuration -> ResponseHandler (List Instrument) msg
getInstruments environment =
    RequestBuilder.get environment
        |> RequestBuilder.withPath "public/get-instruments"
        |> RequestBuilder.withDecoder Decoder.decodeInstrumentListResponse
        |> RequestBuilder.build


{-| Fetches the public tickers for all instruments.
-}
getTickerList : Configuration -> ResponseHandler (List Ticker) msg
getTickerList environment =
    RequestBuilder.get environment
        |> RequestBuilder.withPath "public/get-ticker"
        |> RequestBuilder.withDecoder Decoder.decodeTickerListResponse
        |> RequestBuilder.build


{-| Fetches the public tickers for an instrument (e.g. BTC\_USDT).
-}
getTicker : Configuration -> InstrumentName -> ResponseHandler Ticker msg
getTicker environment (InstrumentName instrumentName) =
    RequestBuilder.get environment
        |> RequestBuilder.withPath "public/get-ticker"
        |> RequestBuilder.withQueryParameter "instrument_name" instrumentName
        |> RequestBuilder.withDecoder Decoder.decodeTickerResponse
        |> RequestBuilder.build


{-| Retrieves candlesticks (k-line data history) over a given period for an instrument (e.g. BTC\_USDT)
-}
getCandlestick : Configuration -> InstrumentName -> Interval -> ResponseHandler Candlestick msg
getCandlestick environment (InstrumentName instrumentName) (Interval interval) =
    RequestBuilder.get environment
        |> RequestBuilder.withPath "public/get-candlestick"
        |> RequestBuilder.withQueryParameter "instrument_name" instrumentName
        |> RequestBuilder.withQueryParameter "timeframe" interval
        |> RequestBuilder.withDecoder Decoder.decodeCandlestickResponse
        |> RequestBuilder.build


{-| Fetches the public trades for a particular instrument
-}
getTradeList : Configuration -> Maybe InstrumentName -> ResponseHandler (List Trade) msg
getTradeList environment instrumentName =
    RequestBuilder.get environment
        |> RequestBuilder.withPath "public/get-trades"
        |> RequestBuilder.withOptionalQueryParameter "instrument_name" (instrumentName |> Maybe.map (\(InstrumentName name) -> name))
        |> RequestBuilder.withDecoder Decoder.decodeTradeListResponse
        |> RequestBuilder.build


{-| Returns the account balance of a user for a particular token
-}
getAccountSummary : PrivateConfiguration -> ResponseHandler (List Account) msg
getAccountSummary environment =
    RequestBuilder.post environment
        |> RequestBuilder.withPath "private/get-account-summary"
        |> RequestBuilder.withDecoder Decoder.decodeAccountSummaryResponse
        |> RequestBuilder.build


{-| Cancels an existing order on the Exchange (asynchronous)
-}
cancelOrder : PrivateConfiguration -> InstrumentName -> OrderId -> ResponseHandler () msg
cancelOrder environment (InstrumentName instrumentName) (OrderId orderId) =
    RequestBuilder.post environment
        |> RequestBuilder.withPath "private/cancel-order"
        |> RequestBuilder.withBodyParameter "instrument_name" instrumentName
        |> RequestBuilder.withBodyParameter "order_id" orderId
        |> RequestBuilder.withDecoder Decoder.decodeUnitResponse
        |> RequestBuilder.build


{-| Creates a new BUY or SELL order on the Exchange.
-}
createOrder : PrivateConfiguration -> LimitOrderRequest -> ResponseHandler OrderReference msg
createOrder environment request =
    RequestBuilder.post environment
        |> RequestBuilder.withPath "private/create-order"
        |> RequestBuilder.withBodyParameterDict (limitOrderRequestEncoder request)
        |> RequestBuilder.withDecoder Decoder.orderReferenceResponse
        |> RequestBuilder.build
