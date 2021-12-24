module AccountSummary exposing (..)

import Browser
import CryptoComExchange exposing (Account)
import CryptoComExchange.Api as Api
import CryptoComExchange.Environment as Environment exposing (ApiKey(..), SecretKey(..))
import Element as E
import Html exposing (Html, text)
import Http
import Task
import Time



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
    | Success (List Account)


environment : Environment.PrivateEnvironment
environment =
    Environment.createProduction
        |> Environment.withApiKey (ApiKey "") (SecretKey "")


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , request
    )



-- UPDATE


type Msg
    = GotAccountSummary (Result Http.Error (List Account))
    | RunInternalCommand (Cmd Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RunInternalCommand cmd ->
            ( model, cmd )

        GotAccountSummary result ->
            case result of
                Ok instrumentList ->
                    ( Success instrumentList, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )


request : Cmd Msg
request =
    Time.now
        |> Task.map (\time -> Environment.withTimestamp time environment)
        |> Task.map (\env -> Api.getAccountSummary env GotAccountSummary)
        |> Task.perform RunInternalCommand



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

        Success accountList ->
            E.table []
                { data =
                    accountList
                        |> List.sortBy .balance
                        |> List.reverse
                , columns =
                    [ { header = E.text "Currency"
                      , width = E.fill
                      , view =
                            \account ->
                                E.text account.currency
                      }
                    , { header = E.text "Balance"
                      , width = E.fill
                      , view =
                            \account ->
                                E.text (String.fromFloat account.balance)
                      }
                    ]
                }
                |> E.layout []
