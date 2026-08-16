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
  validarQuiralidadeQuinas cubo
  validarOrientacaoQuinas cubo

validarQuiralidadeQuinas :: SomeCubo -> Either String ()
validarQuiralidadeQuinas (SomeCubo cubo) =
  case filter (not . ehQuinaFisica . snd) quinasComSinais of
    [] -> Right ()
    (idx, (SomeQuina (Quina c1 c2 c3), _)) : _ ->
      Left
        ( "Linha "
            ++ show idx
            ++ " ("
            ++ nomeSlot idx
            ++ "): quina espelhada / ordem das cores incorreta ('"
            ++ corParaString c1
            ++ " "
            ++ corParaString c2
            ++ " "
            ++ corParaString c3
            ++ "' possui quiralidade 3D invertida e nao existe em um cubo real)."
        )
  where
    quinasComSinais :: [(Int, (SomeQuina, Int))]
    quinasComSinais =
      [ (1, (esqTrasCima cubo, 1)),
        (2, (dirTrasCima cubo, -1)),
        (3, (esqFrenteCima cubo, -1)),
        (4, (dirFrenteCima cubo, 1)),
        (5, (esqTrasBaixo cubo, -1)),
        (6, (dirTrasBaixo cubo, 1)),
        (7, (esqFrenteBaixo cubo, 1)),
        (8, (dirFrenteBaixo cubo, -1))
      ]

ehQuinaFisica :: (SomeQuina, Int) -> Bool
ehQuinaFisica (SomeQuina (Quina cor1 cor2 cor3), sinal) =
  let c1 = corDoSingular cor1
      c2 = corDoSingular cor2
      c3 = corDoSingular cor3
      ordem = if sinal > 0 then [c1, c3, c2] else [c1, c2, c3]
   in ordemCiclicaPadrao ordem `elem` quinasFisicasValidas

ordemCiclicaPadrao :: [Cor] -> [Cor]
ordemCiclicaPadrao [a, b, c]
  | a `elem` [Branco, Amarelo] = [a, b, c]
  | b `elem` [Branco, Amarelo] = [b, c, a]
  | otherwise = [c, a, b]
ordemCiclicaPadrao xs = xs

quinasFisicasValidas :: [[Cor]]
quinasFisicasValidas =
  [ [Branco, Azul, Laranja],
    [Branco, Vermelho, Azul],
    [Branco, Verde, Vermelho],
    [Branco, Laranja, Verde],
    [Amarelo, Laranja, Azul],
    [Amarelo, Azul, Vermelho],
    [Amarelo, Vermelho, Verde],
    [Amarelo, Verde, Laranja]
  ]

validarConjuntoQuinas :: SomeCubo -> Either String ()
validarConjuntoQuinas (SomeCubo cubo) =
  if sort quinasAtuaisCanonicas == sort quinasEsperadasCanonicas
    then Right ()
    else Left "O cubo possui quinas repetidas ou conjunto incompleto (nao contem exatamente as 8 quinas unicas do cubo 2x2)."
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
        else
          Left
            ( "O cubo possui quina(s) rotacionada(s) ilegalmente em seu proprio eixo (orientacao global/twist invalido: soma = "
                ++ show somaOrientacoes
                ++ " mod 3 = "
                ++ show (somaOrientacoes `mod` 3)
                ++ " != 0)."
            )
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

nomeSlot :: Int -> String
nomeSlot 1 = "esqTrasCima"
nomeSlot 2 = "dirTrasCima"
nomeSlot 3 = "esqFrenteCima"
nomeSlot 4 = "dirFrenteCima"
nomeSlot 5 = "esqTrasBaixo"
nomeSlot 6 = "dirTrasBaixo"
nomeSlot 7 = "esqFrenteBaixo"
nomeSlot 8 = "dirFrenteBaixo"
nomeSlot _ = "slot desconhecido"
