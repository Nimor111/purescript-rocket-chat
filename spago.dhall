{ name = "rocket-chat"
, dependencies =
  [ "aff"
  , "affjax"
  , "argonaut"
  , "console"
  , "dotenv"
  , "effect"
  , "either"
  , "http-methods"
  , "maybe"
  , "node-process"
  , "prelude"
  , "psci-support"
  , "typedenv"
  , "exceptions"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
