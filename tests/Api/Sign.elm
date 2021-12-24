module Api.Sign exposing (..)

import CryptoComExchange.Configuration exposing (ApiKey(..), SecretKey(..))
import CryptoComExchange.Encoder exposing (signRequest)
import Dict
import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CryptoExchange.Api.Utils.signRequest"
        [ test
            "Sign request without parameters"
          <|
            \_ ->
                signRequest (ApiKey "key") (SecretKey "secret") "public/tickers" Dict.empty 0
                    |> Expect.equal "b878e1075d79c63ac3e753ed984fec719be0d9f7e792f457e7296475c71268fd"
        , test
            "Sign request with single parameters"
          <|
            \_ ->
                let
                    params =
                        Dict.empty
                            |> Dict.insert "order_id" "qwerty"
                in
                signRequest (ApiKey "key") (SecretKey "secret") "public/tickers" params 0
                    |> Expect.equal "2d7efac1fdfcd2f4370942ec246a0dc36dbb709cabcee1be7640fa17fa400520"
        , test
            "Sign request with multiple string values"
          <|
            \_ ->
                let
                    params =
                        Dict.empty
                            |> Dict.insert "order_id" "qwerty"
                            |> Dict.insert "instrument_name" "ENJ_USDT"
                in
                signRequest (ApiKey "key") (SecretKey "secret") "public/tickers" params 0
                    |> Expect.equal "5f3e3eb952a22e40ce286ffdb9e21ddb151defca0cfc066d76a37dca0bdc3fab"
        ]
