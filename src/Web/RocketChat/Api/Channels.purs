module Web.RocketChat.Api.Channels where

import Prelude

import Affjax (defaultRequest, printError, request)
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as RF
import Data.Argonaut (decodeJson)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Effect.Aff (Aff)
import Effect.Class.Console (log)
import Web.RocketChat.Types (ApiCredentials, ChannelsResponse, Env)


-- TODO Sensible errors
fetchUserJoinedPublicChannels :: Env -> ApiCredentials -> Aff (Either Unit ChannelsResponse)
fetchUserJoinedPublicChannels { apiUrl } apiCreds = do
  let
    req = defaultRequest
      {
        url = apiUrl <> "/channels.list.joined"
      , method = Left GET
      , responseFormat = RF.json
      , headers =
          [ RequestHeader "X-Auth-Token" apiCreds.data.authToken
          , RequestHeader "X-User-Id" apiCreds.data.userId
          ]
      }

  channelsResp <- request req

  case channelsResp of
    Left e -> do
      Left <$> (log $ "Can't parse JSON for group req. " <> printError e)
    Right r -> do
      case (decodeJson r.body) of
        Left e ->
          Left <$> (log $ "Can't decode JSON" <> show e)
        Right (channels :: ChannelsResponse) -> do
          pure $ Right channels
