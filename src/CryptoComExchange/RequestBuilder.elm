module CryptoComExchange.RequestBuilder exposing (RequestBuilder, build, buildFullPath, get, post, withBodyParameter, withBodyParameterDict, withDecoder, withOptionalQueryParameter, withPath, withQueryParameter)

import CryptoComExchange.Configuration as Configuration
import CryptoComExchange.Encoder exposing (bodyEncoder)
import Dict exposing (Dict)
import Http
import HttpBuilder
import Json.Decode as Decode exposing (Decoder)
import Maybe.Extra
import Time


type RequestBuilder returnType
    = RequestBuilder (Internal returnType)


type HttpMethod
    = Get
    | Post Configuration.PrivateConfiguration


type alias Internal returnType =
    { endpoint : String
    , path : String
    , queryParameters : Dict String String
    , bodyParameters : Dict String String
    , decoder : Decoder returnType
    , method : HttpMethod
    , body : Maybe (Dict String String)
    }


get : Configuration.Configuration -> RequestBuilder ()
get configuration =
    RequestBuilder
        { endpoint = Configuration.endpoint configuration
        , path = ""
        , queryParameters = Dict.empty
        , bodyParameters = Dict.empty
        , decoder = Decode.succeed ()
        , method = Get
        , body = Nothing
        }


post : Configuration.PrivateConfiguration -> RequestBuilder ()
post configuration =
    RequestBuilder
        { endpoint = configuration.endpoint
        , path = ""
        , queryParameters = Dict.empty
        , bodyParameters = Dict.empty
        , decoder = Decode.succeed ()
        , method = Post configuration
        , body = Nothing
        }


withPath : String -> RequestBuilder a -> RequestBuilder a
withPath path (RequestBuilder builder) =
    RequestBuilder { builder | path = path }


withBodyParameter : String -> String -> RequestBuilder a -> RequestBuilder a
withBodyParameter key value (RequestBuilder builder) =
    RequestBuilder { builder | bodyParameters = builder.bodyParameters |> Dict.insert (String.trim key) value }


withBodyParameterDict : Dict String String -> RequestBuilder a -> RequestBuilder a
withBodyParameterDict dict builder =
    Dict.toList dict
        |> List.foldl (\( key, value ) res -> withBodyParameter key value res) builder


withQueryParameter : String -> String -> RequestBuilder a -> RequestBuilder a
withQueryParameter key value (RequestBuilder builder) =
    RequestBuilder { builder | queryParameters = builder.queryParameters |> Dict.insert (String.trim key) value }


withOptionalQueryParameter : String -> Maybe String -> RequestBuilder a -> RequestBuilder a
withOptionalQueryParameter key value (RequestBuilder builder) =
    RequestBuilder
        { builder
            | queryParameters =
                value
                    |> Maybe.map (\v -> Dict.insert key v builder.queryParameters)
                    |> Maybe.withDefault (Dict.remove key builder.queryParameters)
        }


withDecoder : Decoder b -> RequestBuilder a -> RequestBuilder b
withDecoder decoder (RequestBuilder builder) =
    RequestBuilder
        { path = builder.path
        , queryParameters = builder.queryParameters
        , bodyParameters = builder.bodyParameters
        , decoder = decoder
        , method = builder.method
        , body = builder.body
        , endpoint = builder.endpoint
        }


build : RequestBuilder a -> (Result Http.Error a -> msg) -> Cmd msg
build (RequestBuilder builder) handler =
    case builder.method of
        Get ->
            HttpBuilder.get
                (buildFullPath (RequestBuilder builder))
                |> HttpBuilder.withExpect (Http.expectJson handler builder.decoder)
                |> HttpBuilder.request

        Post env ->
            HttpBuilder.post
                (buildFullPath (RequestBuilder builder))
                |> HttpBuilder.withExpect (Http.expectJson handler builder.decoder)
                |> HttpBuilder.withJsonBody (bodyEncoder env.apiKey env.secretKey builder.bodyParameters builder.path (Time.posixToMillis env.timestamp))
                |> HttpBuilder.request


buildFullPath : RequestBuilder a -> String
buildFullPath (RequestBuilder builder) =
    builder.endpoint
        ++ builder.path
        ++ queryParametersToString builder.queryParameters


queryParametersToString : Dict String String -> String
queryParametersToString parameters =
    parameters
        |> Dict.toList
        |> List.map (\( key, value ) -> key ++ "=" ++ value)
        |> String.join "&"
        |> Just
        |> Maybe.Extra.filter (not << String.isEmpty)
        |> Maybe.map ((++) "?")
        |> Maybe.withDefault ""
