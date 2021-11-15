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
  , "prelude"
  , "psci-support"
  , "node-process"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
