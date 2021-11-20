module Main where

import Prelude

import Data.Either (Either(..))
import Dotenv as Dotenv
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Process (getEnv)
import Type.Proxy (Proxy(..))
import TypedEnv (envErrorMessage, fromEnv)
import Web.RocketChat (fetchCredentials, fetchUserJoinedPublicChannels)
import Web.RocketChat.Types (Config)


main :: Effect Unit
main = do
  launchAff_
    $ do
        _ <- Dotenv.loadFile
        eitherConfig <- liftEffect $ fromEnv (Proxy :: Proxy Config) <$> getEnv
        case eitherConfig of
          Left err -> do
            log $ "Typedenv environment error: " <> envErrorMessage err
          Right env -> do
            creds <- fetchCredentials env
            case creds of
              Left e -> pure e
              Right apiCreds -> do
                -- groups <- fetchUserPrivateGroups env apiCreds
                -- log $ show groups
                channels <- fetchUserJoinedPublicChannels env apiCreds
                log $ show channels
