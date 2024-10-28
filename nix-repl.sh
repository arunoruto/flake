#!/usr/bin/env expect

spawn nix repl
expect "Welcome to Nix"
send -- ":lf .\r"
expect "Added"
interact
