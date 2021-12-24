module TickerList exposing (..)

import Browser
import CryptoComExchange exposing (InstrumentName(..), Ticker)
import CryptoComExchange.Api as Api
import CryptoComExchange.Environment exposing (createSandbox)
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
    = Failure
    | Loading
    | Success (List Ticker)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Api.getTickerList createSandbox GotTickerList
    )



-- UPDATE


type Msg
    = GotTickerList (Result Http.Error (List Ticker))
    | GotTicker (Result Http.Error Ticker)
    | TickerUpdateRequested String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTickerList result ->
            case result of
                Ok tickerList ->
                    ( Success tickerList, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        GotTicker result ->
            case result of
                Ok ticker ->
                    ( Success [ ticker ], Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        TickerUpdateRequested instrumentName ->
            ( model, Api.getTicker createSandbox (InstrumentName instrumentName) GotTicker )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Failure ->
            text "I was unable to get the ticker list."

        Loading ->
            text "Loading..."

        Success tickerList ->
            E.table []
                { data = tickerList
                , columns =
                    [ { header = E.text "Instrument Name"
                      , width = E.fill
                      , view =
                            \instrument ->
                                EI.button
                                    []
                                    { onPress = Just (TickerUpdateRequested instrument.instrumentName)
                                    , label = E.text instrument.instrumentName
                                    }
                      }
                    , { header = E.text "Last Price"
                      , width = E.fill
                      , view =
                            \instrument ->
                                E.text (String.fromFloat instrument.priceOfLatestTrade)
                      }
                    ]
                }
                |> E.layout []
