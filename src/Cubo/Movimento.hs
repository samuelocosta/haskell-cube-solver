{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}

module Cubo.Movimento
  ( Movimento (..),
    aplicarMovimento,
    aplicarMovimentoSome,
    aplicarMovimentoInverso,
    aplicarMovimentoInversoSome,
    aplicarMovimentos,
    aplicarMovimentosSome,
  )
where

import Cubo.Cubo
import Cubo.Quina

data Movimento
  = U
  | R
  | F
  deriving (Eq, Ord, Show, Enum, Bounded)

aplicarMovimento :: Movimento -> Cubo estado -> Cubo estado
aplicarMovimento U = moverU
aplicarMovimento R = moverR
aplicarMovimento F = moverF

aplicarMovimentoSome :: Movimento -> SomeCubo -> SomeCubo
aplicarMovimentoSome mov (SomeCubo cubo) = SomeCubo (aplicarMovimento mov cubo)

aplicarMovimentoInverso :: Movimento -> Cubo estado -> Cubo estado
aplicarMovimentoInverso U = moverU . moverU . moverU
aplicarMovimentoInverso R = moverR . moverR . moverR
aplicarMovimentoInverso F = moverF . moverF . moverF

aplicarMovimentoInversoSome :: Movimento -> SomeCubo -> SomeCubo
aplicarMovimentoInversoSome mov (SomeCubo cubo) = SomeCubo (aplicarMovimentoInverso mov cubo)

aplicarMovimentos :: [Movimento] -> Cubo estado -> Cubo estado
aplicarMovimentos movimentos cubo = foldl (flip aplicarMovimento) cubo movimentos

aplicarMovimentosSome :: [Movimento] -> SomeCubo -> SomeCubo
aplicarMovimentosSome movimentos (SomeCubo cubo) = SomeCubo (aplicarMovimentos movimentos cubo)

moverU :: Cubo estado -> Cubo estado
moverU cubo =
  cubo
    { dirTrasCima = girarU (esqTrasCima cubo),
      dirFrenteCima = girarU (dirTrasCima cubo),
      esqFrenteCima = girarU (dirFrenteCima cubo),
      esqTrasCima = girarU (esqFrenteCima cubo)
    }

moverR :: Cubo estado -> Cubo estado
moverR cubo =
  cubo
    { dirTrasCima = girarR (dirFrenteCima cubo),
      dirTrasBaixo = girarR (dirTrasCima cubo),
      dirFrenteBaixo = girarR (dirTrasBaixo cubo),
      dirFrenteCima = girarR (dirFrenteBaixo cubo)
    }

moverF :: Cubo estado -> Cubo estado
moverF cubo =
  cubo
    { dirFrenteCima = girarF (esqFrenteCima cubo),
      dirFrenteBaixo = girarF (dirFrenteCima cubo),
      esqFrenteBaixo = girarF (dirFrenteBaixo cubo),
      esqFrenteCima = girarF (esqFrenteBaixo cubo)
    }

girarU :: SomeQuina -> SomeQuina
girarU (SomeQuina (Quina cor1 cor2 cor3)) =
  case criarSomeQuina cor2 cor1 cor3 of
    Just quina -> quina
    Nothing -> SomeQuina (Quina cor2 cor1 cor3)

girarR :: SomeQuina -> SomeQuina
girarR (SomeQuina (Quina cor1 cor2 cor3)) =
  case criarSomeQuina cor1 cor3 cor2 of
    Just quina -> quina
    Nothing -> SomeQuina (Quina cor1 cor3 cor2)

girarF :: SomeQuina -> SomeQuina
girarF (SomeQuina (Quina cor1 cor2 cor3)) =
  case criarSomeQuina cor3 cor2 cor1 of
    Just quina -> quina
    Nothing -> SomeQuina (Quina cor3 cor2 cor1)