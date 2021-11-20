module Web.RocketChat.Config where

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
import Web.RocketChat.Types (Env, Config)


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
