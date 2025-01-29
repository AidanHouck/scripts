#!/usr/bin/env nix-shell
#! nix-shell -i runhaskell
#! nix-shell -p ghc

main = do
  putStrLn "Enter a word: "
  word <- getLine
  putStrLn ("You entered " ++ word ++ "!")

