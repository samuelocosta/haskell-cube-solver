module Cubo.Validacao
  ( validarSolucionavel,
  )
where

import Cubo.Cor
import Cubo.Cubo
import Cubo.Quina
import Data.List (sort)

validarSolucionavel :: SomeCubo -> Either String ()
validarSolucionavel cubo = do
  validarConjuntoQuinas cubo
  validarOrientacaoQuinas cubo

validarConjuntoQuinas :: SomeCubo -> Either String ()
validarConjuntoQuinas (SomeCubo cubo) =
  if sort quinasAtuaisCanonicas == sort quinasEsperadasCanonicas
    then Right ()
    else Left "O arquivo nao descreve o conjunto correto de quinas do cubo 2x2."
  where
    quinasAtuaisCanonicas =
      [ canonicalQuina (esqTrasCima cubo),
        canonicalQuina (dirTrasCima cubo),
        canonicalQuina (esqFrenteCima cubo),
        canonicalQuina (dirFrenteCima cubo),
        canonicalQuina (esqTrasBaixo cubo),
        canonicalQuina (dirTrasBaixo cubo),
        canonicalQuina (esqFrenteBaixo cubo),
        canonicalQuina (dirFrenteBaixo cubo)
      ]

validarOrientacaoQuinas :: SomeCubo -> Either String ()
validarOrientacaoQuinas (SomeCubo cubo) =
  let somaOrientacoes = sum (map orientacaoQuina quinas)
   in if somaOrientacoes `mod` 3 == 0
        then Right ()
        else Left "O cubo possui quinas giradas de forma impossivel (orientacao invalida)."
  where
    quinas =
      [ esqTrasCima cubo,
        dirTrasCima cubo,
        esqFrenteCima cubo,
        dirFrenteCima cubo,
        esqTrasBaixo cubo,
        dirTrasBaixo cubo,
        esqFrenteBaixo cubo,
        dirFrenteBaixo cubo
      ]

orientacaoQuina :: SomeQuina -> Int
orientacaoQuina (SomeQuina (Quina cor1 cor2 cor3))
  | corDoSingular cor3 `elem` [Branco, Amarelo] = 0
  | corDoSingular cor1 `elem` [Branco, Amarelo] = 1
  | corDoSingular cor2 `elem` [Branco, Amarelo] = 2
  | otherwise = 0

quinasEsperadasCanonicas :: [String]
quinasEsperadasCanonicas =
  [ canonicalTexto [Laranja, Azul, Branco],
    canonicalTexto [Vermelho, Azul, Branco],
    canonicalTexto [Laranja, Verde, Branco],
    canonicalTexto [Vermelho, Verde, Branco],
    canonicalTexto [Laranja, Azul, Amarelo],
    canonicalTexto [Vermelho, Azul, Amarelo],
    canonicalTexto [Laranja, Verde, Amarelo],
    canonicalTexto [Vermelho, Verde, Amarelo]
  ]

canonicalQuina :: SomeQuina -> String
canonicalQuina (SomeQuina (Quina cor1 cor2 cor3)) =
  canonicalTexto [corDoSingular cor1, corDoSingular cor2, corDoSingular cor3]

canonicalTexto :: [Cor] -> String
canonicalTexto cores = show (sort cores)
