module RequestBuilder exposing (..)

import CryptoComExchange.Configuration as Environment
import CryptoComExchange.RequestBuilder as RequestBuilder
import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CryptoExchange.RequestBuilder"
        [ test
            "build path without parameters"
            (\_ ->
                Environment.createProduction
                    |> RequestBuilder.get
                    |> RequestBuilder.withPath "get-ticker-list"
                    |> RequestBuilder.buildFullPath
                    |> Expect.equal "https://api.crypto.com/v2/get-ticker-list"
            )
        , test "build path with single parameters"
            (\_ ->
                Environment.createProduction
                    |> RequestBuilder.get
                    |> RequestBuilder.withPath "get-ticker-list"
                    |> RequestBuilder.withQueryParameter "instrument_name" "BTC_USDT"
                    |> RequestBuilder.buildFullPath
                    |> Expect.equal "https://api.crypto.com/v2/get-ticker-list?instrument_name=BTC_USDT"
            )
        , test "should trim key before using it"
            (\_ ->
                Environment.createProduction
                    |> RequestBuilder.get
                    |> RequestBuilder.withPath "get-ticker-list"
                    |> RequestBuilder.withQueryParameter "instrument_name " "BTC_USDT"
                    |> RequestBuilder.buildFullPath
                    |> Expect.equal "https://api.crypto.com/v2/get-ticker-list?instrument_name=BTC_USDT"
            )
        , test "build path with double parameters"
            (\_ ->
                Environment.createProduction
                    |> RequestBuilder.get
                    |> RequestBuilder.withPath "get-ticker-list"
                    |> RequestBuilder.withQueryParameter "instrument_name " "BTC_USDT"
                    |> RequestBuilder.withQueryParameter "quote" "BTC"
                    |> RequestBuilder.buildFullPath
                    |> Expect.equal "https://api.crypto.com/v2/get-ticker-list?instrument_name=BTC_USDT&quote=BTC"
            )
        ]
