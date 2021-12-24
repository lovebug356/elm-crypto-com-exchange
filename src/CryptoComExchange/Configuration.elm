module CryptoComExchange.Configuration exposing
    ( Configuration, PrivateConfiguration, PublicConfiguration, ApiKey(..), SecretKey(..)
    , createSandbox, createProduction, createPrivateConfiguration, withTimestamp, withApiKey, endpoint
    )

{-| This module allows to define your custom configuration on how to use the API.


# Definition

@docs Configuration, PrivateConfiguration, PublicConfiguration, ApiKey, SecretKey


# Helpers

@docs createSandbox, createProduction, createPrivateConfiguration, withTimestamp, withApiKey, endpoint

-}

import Time


{-| A configuration that can be used for all public APis.
-}
type Configuration
    = Public PublicConfiguration
    | Private PrivateConfiguration


{-| A configuration without authentication information.
-}
type alias PublicConfiguration =
    { endpoint : String
    }


{-| A configuration with authentication information.
-}
type alias PrivateConfiguration =
    { endpoint : String
    , apiKey : ApiKey
    , secretKey : SecretKey
    , timestamp : Time.Posix
    }


{-| Randomly generated API key.
-}
type ApiKey
    = ApiKey String


{-| Randomly generated secret key.
-}
type SecretKey
    = SecretKey String


{-| Get the endpoint of a configuration.
-}
endpoint : Configuration -> String
endpoint configuration =
    case configuration of
        Public public ->
            public.endpoint

        Private private ->
            private.endpoint


{-| Create a configuration for the sandbox environment.
-}
createSandbox : Configuration
createSandbox =
    Public
        { endpoint =
            "https://uat-api.3ona.co/v2/"
        }


{-| Create a configuration for the production environment.
-}
createProduction : Configuration
createProduction =
    Public
        { endpoint =
            "https://api.crypto.com/v2/"
        }


{-| Create a Configuration from a PrivateConfiguration
-}
createPrivateConfiguration : PrivateConfiguration -> Configuration
createPrivateConfiguration configuration =
    Private configuration


{-| Add ApiKey and SecretKey to a configuration.

More information about generating an API key can be found here.
<https://exchange-docs.crypto.com/spot/index.html#generating-the-api-key>

-}
withApiKey : ApiKey -> SecretKey -> Configuration -> PrivateConfiguration
withApiKey apiKey secretKey configuration =
    case configuration of
        Public config ->
            PrivateConfiguration config.endpoint apiKey secretKey (Time.millisToPosix 0)

        Private config ->
            PrivateConfiguration config.endpoint apiKey secretKey config.timestamp


{-| Add a new timestamp to the PrivateConfiguration.
-}
withTimestamp : Time.Posix -> PrivateConfiguration -> PrivateConfiguration
withTimestamp timestamp environment =
    { environment | timestamp = timestamp }
