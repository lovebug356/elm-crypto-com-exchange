module FullExchange exposing (..)

import Browser
import CryptoComExchange exposing (Instrument, Ticker, Trade)
import CryptoComExchange.Api as Api
import Element as E
import Element.Input as EI
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
    = Loading
    | Failure String
    | InstrumentsAvailable (List Instrument)
    | InstrumentSelected
        { tradeList : List Trade
        , ticker : Ticker
        , instrumentName : String
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Api.getInstruments GotInstrumentList
    )



-- UPDATE


type Msg
    = GotInstrumentList (Result Http.Error (List Instrument))
    | GotTicker (Result Http.Error Ticker)
    | InstrumentRequested String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotInstrumentList result ->
            case result of
                Ok instrumentList ->
                    ( InstrumentsAvailable instrumentList, Cmd.none )

                Err err ->
                    ( Failure (Debug.toString err), Cmd.none )

        InstrumentRequested instrumentName ->
            ( model
            , Cmd.batch
                [ Api.getTicker instrumentName GotTicker
                ]
            )

        GotTicker (Ok ticker) ->
            case model of
                InstrumentSelected imodel ->
                    ( InstrumentSelected { imodel | ticker = ticker }, Cmd.none )

                _ ->
                    ( InstrumentSelected { ticker = ticker, tradeList = [], instrumentName = ticker.instrumentName }
                    , Cmd.none
                    )

        GotTicker (Err err) ->
            ( Failure (Debug.toString err), Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Failure message ->
            text ("I was unable to get the instrument list: " ++ message)

        Loading ->
            text "Loading..."

        InstrumentsAvailable instrumentList ->
            E.table []
                { data = instrumentList
                , columns =
                    [ { header = E.text "Instrument Name"
                      , width = E.fill
                      , view =
                            \instrument ->
                                EI.button
                                    []
                                    { onPress = Just (InstrumentRequested instrument.instrumentName)
                                    , label = E.text instrument.instrumentName
                                    }
                      }
                    , { header = E.text "Base Currency"
                      , width = E.fill
                      , view =
                            \instrument ->
                                E.text instrument.baseCurrency
                      }
                    , { header = E.text "Quote Currency"
                      , width = E.fill
                      , view =
                            \instrument ->
                                E.text instrument.quoteCurrency
                      }
                    ]
                }
                |> E.layout []

        InstrumentSelected instrument ->
            E.text ("Loading..." ++ instrument.instrumentName)
                |> E.layout []
