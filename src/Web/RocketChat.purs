module Web.RocketChat where

import Prelude

import Affjax (defaultRequest, post, printError, request)
import Affjax.RequestBody as RB
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as RF
import Data.Argonaut (decodeJson, encodeJson)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class.Console (log)
import Web.RocketChat.Types (ApiCredentials, Env, PrivateGroupsResponse, ChannelsResponse)


-- TODO Sensible errors
fetchCredentials :: Env -> Aff (Either Unit ApiCredentials)
fetchCredentials { username, password, apiUrl } = do
  res <- post RF.json (apiUrl <> "/login") (Just (RB.json (encodeJson $ { username , password })))
  case res of
    Left err ->
      Left <$> (log $ "GET /api response failed to decode: " <> printError err)
    Right apiCredentialsResponse -> do
      case (decodeJson apiCredentialsResponse.body) of
        Right (apiCreds :: ApiCredentials) ->
          pure $ Right apiCreds
        Left err ->
          Left <$> (log $ "Can't parse JSON for auth req. " <> show err)

-- TODO Sensible errors
fetchUserPrivateGroups :: Env -> ApiCredentials -> Aff (Either Unit PrivateGroupsResponse)
fetchUserPrivateGroups { apiUrl } apiCreds = do
  let
    req = defaultRequest
      {
        --url = apiUrl <> "/channels.list.joined"
        url = apiUrl <> "/groups.list"
      , method = Left GET
      , responseFormat = RF.json
      , headers =
          [ RequestHeader "X-Auth-Token" apiCreds.data.authToken
          , RequestHeader "X-User-Id" apiCreds.data.userId
          ]
      }

  groupsResp <- request req

  case groupsResp of
    Left e -> do
      Left <$> (log $ "Can't parse JSON for group req. " <> printError e)
    Right r -> do
      case (decodeJson r.body) of
        Left e ->
          Left <$> (log $ "Can't decode JSON" <> show e)
        Right (groups :: PrivateGroupsResponse) -> do
          pure $ Right groups

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
