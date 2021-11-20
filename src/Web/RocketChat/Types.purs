module Web.RocketChat.Types where

import TypedEnv (type (<:))


-- | The `Config` type is used to represent the configuration to be read with `purescript-typedenv`
type Config =
  ( username :: String <: "ROCKET_USERNAME"
  , password :: String <: "ROCKET_PASSWORD"
  , apiUrl   :: String <: "ROCKET_API_URL"
  )

-- | The `Env` type is used to represent configuration needed to interact with the rocket chat API
type Env =
  { username :: String
  , password :: String
  , apiUrl :: String
  }

-- | The `ApiCredentials` type is used to represent credentials to authenticate with the rocket chat API
type ApiCredentials =
  { data ::
      { authToken :: String
      , userId :: String
      }
  }

-- | The `ChannelsResponse` type represents a list of channels fetched from the rocket chat API
type ChannelsResponse =
  { channels ::
      Array
        { name :: String
        }
  }

-- | The `PrivateGroupsResponse` type represents a list of groups fetched from the rocket chat API
type PrivateGroupsResponse =
  { groups ::
      Array
        { name :: String
        }
  }
