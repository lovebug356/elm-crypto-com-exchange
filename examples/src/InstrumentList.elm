module InstrumentList exposing (..)

import Browser
import CryptoComExchange exposing (Instrument)
import CryptoComExchange.Api as Api
import CryptoComExchange.Environment exposing (createSandbox)
import Element as E
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
    | Success (List Instrument)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Api.getInstruments createSandbox GotInstrumentList
    )



-- UPDATE


type Msg
    = GotInstrumentList (Result Http.Error (List Instrument))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotInstrumentList result ->
            case result of
                Ok instrumentList ->
                    ( Success instrumentList, Cmd.none )

                Err _ ->
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
            text "I was unable to get the instrument list."

        Loading ->
            text "Loading..."

        Success instrumentList ->
            E.table []
                { data = instrumentList
                , columns =
                    [ { header = E.text "Instrument Name"
                      , width = E.fill
                      , view =
                            \instrument ->
                                E.text instrument.instrumentName
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
