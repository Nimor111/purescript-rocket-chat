module Web.RocketChat
  ( module Web.RocketChat.Types
  , module Web.RocketChat.Api.Auth
  , module Web.RocketChat.Api.Channels
  , module Web.RocketChat.Api.Groups
  , fetchConfig
  ) where

import Prelude

import Data.Either (Either(..))
import Dotenv as Dotenv
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Node.Process (getEnv)
import Type.Proxy (Proxy(..))
import TypedEnv (envErrorMessage, fromEnv)
import Web.RocketChat.Api.Auth (fetchCredentials)
import Web.RocketChat.Api.Channels (fetchUserJoinedPublicChannels)
import Web.RocketChat.Api.Groups (fetchUserPrivateGroups)
import Web.RocketChat.Types (ApiCredentials, ChannelsResponse, Env, PrivateGroupsResponse, Config)

-- TODO Sensible errors
fetchConfig :: Aff Env
fetchConfig = do
  _ <- Dotenv.loadFile
  eitherConfig <- liftEffect $ fromEnv (Proxy :: Proxy Config) <$> getEnv
  case eitherConfig of
    Left err -> do
      log $ "Typedenv environment error: " <> envErrorMessage err
      liftEffect $ throw "Error reading environment - specify ROCKET_USERNAME, ROCKET_PASSWORD and ROCKET_API_URL in your .env file"
    Right env -> pure env
