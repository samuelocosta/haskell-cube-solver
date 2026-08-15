module Lib (greet, iniciar) where

import Cubo.Leitura (lerCubo)
import Cubo.Solver (Solucao (..), resolverCuboComLog)
import System.Environment (getArgs)

greet :: String
greet = "haskell-cube-solver"

iniciar :: IO ()
iniciar = do
  argumentos <- getArgs
  let caminho = case argumentos of
        [] -> "cubo.txt"
        x : _ -> x
  resultado <- lerCubo caminho
  case resultado of
    Left erro -> putStrLn ("Falha ao ler " ++ caminho ++ ": " ++ erro)
    Right cubo -> do
      putStrLn ("Cubo carregado de " ++ caminho ++ ".")
      solucaoOuErro <- resolverCuboComLog cubo
      case solucaoOuErro of
        Left erro -> putStrLn ("Falha ao resolver: " ++ erro)
        Right solucao -> do
          putStrLn ("Movimentos encontrados: " ++ show (length (movimentosSolucao solucao)))
          putStrLn ("Sequencia: " ++ show (movimentosSolucao solucao))
          putStrLn ("Estado final: " ++ show (cuboFinalSolucao solucao))
