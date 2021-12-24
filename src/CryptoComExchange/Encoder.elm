module CryptoComExchange.Encoder exposing (bodyEncoder, limitOrderRequestEncoder, signRequest)

import Crypto.HMAC exposing (digest, sha256)
import CryptoComExchange exposing (InstrumentName(..), LimitOrderRequest, OrderSide(..))
import CryptoComExchange.Configuration exposing (ApiKey(..), SecretKey(..))
import Dict exposing (Dict)
import Json.Encode as Encode


bodyEncoder : ApiKey -> SecretKey -> Dict String String -> String -> Int -> Encode.Value
bodyEncoder (ApiKey apiKey) apiSecret parameters method time =
    Encode.object
        [ ( "id", Encode.int 0 )
        , ( "method", Encode.string method )
        , ( "api_key", Encode.string apiKey )
        , ( "params", buildParameters parameters )
        , ( "sig", Encode.string (signRequest (ApiKey apiKey) apiSecret method parameters time) )
        , ( "nonce", Encode.int time )
        ]


signRequest : ApiKey -> SecretKey -> String -> Dict String String -> Int -> String
signRequest (ApiKey apiKey) (SecretKey apiSecret) method params time =
    let
        parameterString =
            Dict.keys params
                |> List.sort
                |> List.foldl (addKeyValueToResult params) ""

        sigPayload =
            method
                ++ "0"
                ++ apiKey
                ++ parameterString
                ++ String.fromInt time
    in
    digest sha256 apiSecret sigPayload


addKeyValueToResult : Dict String String -> String -> String -> String
addKeyValueToResult params key result =
    result ++ key ++ parameterValue params key


parameterValue : Dict comparable String -> comparable -> String
parameterValue params key =
    Dict.get key params
        |> Maybe.withDefault ""


buildParameters : Dict String String -> Encode.Value
buildParameters parameters =
    parameters
        |> Dict.keys
        |> List.map (encodeKey parameters)
        |> Encode.object


encodeKey : Dict comparable String -> comparable -> ( comparable, Encode.Value )
encodeKey parameters key =
    ( key, Encode.string (Dict.get key parameters |> Maybe.withDefault "") )


limitOrderRequestEncoder : LimitOrderRequest -> Dict String String
limitOrderRequestEncoder request =
    Dict.empty
        |> Dict.insert "instrument_name" (instrumentNameEncoder request.instrumentName)
        |> Dict.insert "side" (sideEncoder request.side)
        |> Dict.insert "type" "LIMIT"
        |> Dict.insert "price" request.price
        |> Dict.insert "quantity" request.quantity


instrumentNameEncoder : InstrumentName -> String
instrumentNameEncoder (InstrumentName name) =
    name


sideEncoder : OrderSide -> String
sideEncoder side =
    case side of
        Buy ->
            "BUY"

        Sell ->
            "SELL"
