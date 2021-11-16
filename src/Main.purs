module Main where

import Prelude

import Affjax (defaultRequest, post, printError, request)
import Affjax.RequestBody as RB
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as RF
import Data.Argonaut (decodeJson, encodeJson)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Dotenv as Dotenv
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Process (getEnv)
import Type.Proxy (Proxy(..))
import TypedEnv (type (<:), envErrorMessage, fromEnv)


type Environment =
  ( username :: String <: "ROCKET_USERNAME"
  , password :: String <: "ROCKET_PASSWORD"
  , apiUrl   :: String <: "ROCKET_API_URL"
  )

type ApiCredentials =
  { data ::
      { authToken :: String
      , userId :: String
      }
  }

type ChannelResponse =
  { channels ::
      Array
        { name :: String
        }
  }

type PrivateGroupsResponse =
  { groups ::
      Array
        { name :: String
        }
  }

main :: Effect Unit
main = do
  launchAff_
    $ do
        _ <- Dotenv.loadFile
        eitherConfig <- liftEffect $ fromEnv (Proxy :: Proxy Environment) <$> getEnv
        case eitherConfig of
          Left err -> do
            log $ "Typedenv environment error: " <> envErrorMessage err
          Right { username, password, apiUrl } -> do
            res <- post RF.json (apiUrl <> "/login") (Just (RB.json (encodeJson $ { username , password })))
            case res of
              Left err -> do
                log $ "GET /api response failed to decode: " <> printError err
              Right apiCredentialsResponse -> do
                case (decodeJson apiCredentialsResponse.body) of
                  Right (apiCreds :: ApiCredentials) -> do
                    let token = apiCreds.data.authToken
                    let userId = apiCreds.data.userId
                    log $ "Auth token is: " <> show token
                    log $ "User id is: " <> show userId

                    let
                      req = defaultRequest
                        {
                          --url = apiUrl <> "/channels.list.joined"
                          url = apiUrl <> "/groups.list"
                        , method = Left GET
                        , responseFormat = RF.json
                        , headers =
                            [ RequestHeader "X-Auth-Token" token
                            , RequestHeader "X-User-Id" userId
                            ]
                        }

                    groupsResp <- request req

                    case groupsResp of
                      Left e -> do
                        log $ "Can't parse JSON for group req. " <> printError e
                      Right r -> do
                        case (decodeJson r.body) of
                          Left e ->
                            log $ "Can't decode JSON" <> show e
                          Right (groups :: PrivateGroupsResponse) -> do
                            log $ show groups
                  Left e -> do
                    log $ "Can't parse JSON for auth req. " <> show e
