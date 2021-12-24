module TradeList exposing (..)

import Browser
import CryptoComExchange exposing (InstrumentName(..), Trade)
import CryptoComExchange.Api as Api
import CryptoComExchange.Environment exposing (createSandbox)
import Element as E
import Element.Input as EI
import Html exposing (Html, text)
import Http
import Iso8601



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
    | Success (List Trade)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Api.getTradeList createSandbox Nothing GotTradeList
    )



-- UPDATE


type Msg
    = GotTradeList (Result Http.Error (List Trade))
    | TradeListRequested String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTradeList result ->
            case result of
                Ok tradeList ->
                    ( Success tradeList, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        TradeListRequested instrumentName ->
            ( model, Api.getTradeList createSandbox (Just (InstrumentName instrumentName)) GotTradeList )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Failure ->
            text "I was unable to get the trade list."

        Loading ->
            text "Loading..."

        Success tradeList ->
            E.table []
                { data = tradeList
                , columns =
                    [ { header = E.text "Instrument Name"
                      , width = E.fill
                      , view =
                            \trade ->
                                EI.button
                                    []
                                    { onPress = Just (TradeListRequested trade.instrumentName)
                                    , label = E.text trade.instrumentName
                                    }
                      }
                    , { header = E.text "Price"
                      , width = E.fill
                      , view =
                            \trade ->
                                E.text (String.fromFloat trade.price)
                      }
                    , { header = E.text "Timestamp"
                      , width = E.fill
                      , view =
                            \trade ->
                                E.text (Iso8601.fromTime trade.timestamp)
                      }
                    ]
                }
                |> E.layout []
