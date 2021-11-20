module Web.RocketChat.Api.Groups where

import Prelude

import Affjax (defaultRequest, printError, request)
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as RF
import Data.Argonaut (decodeJson)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Effect.Aff (Aff)
import Effect.Class.Console (log)
import Web.RocketChat.Types (ApiCredentials, Env, PrivateGroupsResponse)

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
