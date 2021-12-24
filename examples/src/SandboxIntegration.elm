module SandboxIntegration exposing (..)

import Browser
import CryptoComExchange exposing (Candlestick, Instrument, InstrumentName(..), Interval(..), Ticker, Trade)
import CryptoComExchange.Api as Api
import CryptoComExchange.Environment exposing (createSandbox)
import Html exposing (Html, text)
import Http



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Failure
    | TestsRunning Int
    | AllTestsDone Int


init : () -> ( Model, Cmd Msg )
init _ =
    ( TestsRunning 0
    , Api.getInstruments createSandbox GotInstrumentList
    )



-- UPDATE


type Msg
    = GotInstrumentList (Result Http.Error (List Instrument))
    | GotTickerList (Result Http.Error (List Ticker))
    | GotTicker (Result Http.Error Ticker)
    | GotTradeList (Result Http.Error (List Trade))
    | GotTradeListWithInstrument (Result Http.Error (List Trade))
    | GotCandlestickList (Result Http.Error Candlestick)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        testCountDone =
            case model of
                TestsRunning counter ->
                    counter

                _ ->
                    0
    in
    case msg of
        GotInstrumentList (Ok _) ->
            ( TestsRunning (testCountDone + 1)
            , Api.getTickerList createSandbox GotTickerList
            )

        GotTickerList (Ok _) ->
            ( TestsRunning (testCountDone + 1)
            , Api.getTicker createSandbox (InstrumentName "CRO_USDT") GotTicker
            )

        GotTicker (Ok _) ->
            ( TestsRunning (testCountDone + 1)
            , Api.getTradeList createSandbox Nothing GotTradeList
            )

        GotTradeList (Ok _) ->
            ( TestsRunning (testCountDone + 1)
            , Api.getTradeList createSandbox (Just (InstrumentName "CRO_USDT")) GotTradeListWithInstrument
            )

        GotTradeListWithInstrument (Ok _) ->
            ( TestsRunning (testCountDone + 1)
            , Api.getCandlestick createSandbox (InstrumentName "CRO_USDT") (Interval "5m") GotCandlestickList
            )

        GotCandlestickList (Ok _) ->
            ( AllTestsDone (testCountDone + 1)
            , Cmd.none
            )

        GotInstrumentList (Err _) ->
            ( Failure, Cmd.none )

        GotTickerList (Err _) ->
            ( Failure, Cmd.none )

        GotTicker (Err _) ->
            ( Failure, Cmd.none )

        GotTradeList (Err _) ->
            ( Failure, Cmd.none )

        GotTradeListWithInstrument (Err _) ->
            ( Failure, Cmd.none )

        GotCandlestickList (Err _) ->
            ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Failure ->
            text "Failed to run all tests"

        TestsRunning testsDone ->
            text ("Running test " ++ String.fromInt testsDone)

        AllTestsDone testsDone ->
            text ("Done running all tests " ++ String.fromInt testsDone)
