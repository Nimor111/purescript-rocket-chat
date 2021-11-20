module Web.RocketChat.Api.Auth where

import Prelude

import Affjax (post, printError)
import Affjax.RequestBody as RB
import Affjax.ResponseFormat as RF
import Data.Argonaut (decodeJson, encodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class.Console (log)
import Web.RocketChat.Types (ApiCredentials, Env)


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
