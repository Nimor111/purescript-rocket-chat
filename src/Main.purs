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
import Dotenv (loadFile) as Dotenv
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Process (lookupEnv)


type AuthRequest = {
  username :: String,
  password :: String
}

type ApiCredentials = {
  data :: {
    authToken :: String,
    userId :: String
  }
}

type ChannelResponse = {
  channels :: Array {
     name :: String
  }
}

type PrivateGroupsResponse = {
  groups :: Array {
     name :: String
  }
}

main :: Effect Unit
main = do
  launchAff_
    $ do
      _ <- Dotenv.loadFile
      username <- liftEffect $ lookupEnv "ROCKET_USERNAME"
      password <- liftEffect $ lookupEnv "ROCKET_PASSWORD"
      maybeApiUrl   <- liftEffect $ lookupEnv "ROCKET_API_URL"
      case maybeApiUrl of
        Nothing -> log "No API Url provided"
        Just apiUrl -> do
          res <- post RF.json (apiUrl <> "/login") (Just (RB.json (encodeJson $ { username, password })))
          case res of
            Left err -> do
              log $ "GET /api response failed to decode: " <> printError err
            Right response -> do
              case (decodeJson response.body) of
                Right (apiCreds :: ApiCredentials) -> do
                  let token = apiCreds.data.authToken
                  let userId = apiCreds.data.userId
                  log $ "Auth token is: " <> show token
                  log $ "User id is: " <> show userId

                  let req = defaultRequest {
                    --url = apiUrl <> "/channels.list.joined"
                    url = apiUrl <> "/groups.list"
                  , method = Left GET
                  , responseFormat = RF.json
                  , headers = [
                      RequestHeader "X-Auth-Token" token
                    , RequestHeader "X-User-Id" userId
                    ]
                  }

                  resp <- request req

                  case resp of
                    Left e -> do
                      log $ "Can't parse JSON for group req. " <> printError e
                    Right response -> do
                      case (decodeJson response.body) of
                        Left e ->
                          log $ "Can't decode JSON" <> show e
                        Right (r :: PrivateGroupsResponse) -> do
                          log $ show r
                Left e -> do
                  log $ "Can't parse JSON for auth req. " <> show e
