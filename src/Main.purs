module Main where

import Prelude

import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class.Console (log)
import Web.RocketChat (fetchConfig, fetchCredentials, fetchUserJoinedPublicChannels, fetchUserPrivateGroups)

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
