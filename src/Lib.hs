module Lib (greet, iniciar) where

import Cubo.Leitura (lerCubo)

greet :: String
greet = "haskell-cube-solver"

iniciar :: IO ()
iniciar = do
  resultado <- lerCubo "cubo.txt"
  case resultado of
    Left erro -> putStrLn ("Falha ao ler cubo.txt: " ++ erro)
    Right _ -> putStrLn "Cubo carregado com sucesso. Base inicial pronta."
