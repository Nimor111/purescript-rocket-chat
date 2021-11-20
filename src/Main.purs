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
import Web.RocketChat (Config, fetchCredentials, fetchUserJoinedPublicChannels, fetchUserPrivateGroups, fetchConfig)

main :: Effect Unit
main = do
  launchAff_
    $ do
        env <- fetchConfig
        creds <- fetchCredentials env
        case creds of
          Left e -> pure e
          Right apiCreds -> do
            groups <- fetchUserPrivateGroups env apiCreds
            log $ show groups
            channels <- fetchUserJoinedPublicChannels env apiCreds
            log $ show channels
