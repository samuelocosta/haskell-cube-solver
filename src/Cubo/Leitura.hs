module Cubo.Leitura
  ( lerCubo,
    parseCubo,
  )
where

import Control.Exception (catch)
import Cubo.Cor
import Cubo.Cubo
import Cubo.Quina
import System.IO.Error (isDoesNotExistError)

lerCubo :: FilePath -> IO (Either String SomeCubo)
lerCubo caminho = do
  resultado <-
    catch
      ( do
          conteudo <- readFile caminho
          pure (parseCubo conteudo)
      )
      tratarErro
  pure resultado
  where
    tratarErro erro
      | isDoesNotExistError erro = pure (Left ("Arquivo nao encontrado: " ++ caminho))
      | otherwise = ioError erro

parseCubo :: String -> Either String SomeCubo
parseCubo texto = do
  let linhasNaoVazias = [l | l <- lines texto, not (null (words l))]
  if length linhasNaoVazias /= 8
    then Left ("O arquivo precisa ter exatamente 8 linhas com quinas, mas encontrou " ++ show (length linhasNaoVazias) ++ " linha(s).")
    else do
      quinas <- mapM (uncurry parseLinha) (zip [1 .. 8] linhasNaoVazias)
      montarCubo quinas

parseLinha :: Int -> String -> Either String SomeQuina
parseLinha idx linha = case words linha of
  [cor1Texto, cor2Texto, cor3Texto] -> do
    SomeCor cor1 <- parseCor idx cor1Texto
    SomeCor cor2 <- parseCor idx cor2Texto
    SomeCor cor3 <- parseCor idx cor3Texto
    case validarCriacaoQuina cor1 cor2 cor3 of
      Right quina -> Right (SomeQuina quina)
      Left motivo -> Left ("Linha " ++ show idx ++ " (" ++ nomeSlot idx ++ "): quina " ++ motivo)
  tokens ->
    Left ("Linha " ++ show idx ++ " (" ++ nomeSlot idx ++ "): esperava exatamente 3 cores, mas encontrou " ++ show (length tokens) ++ " ('" ++ linha ++ "').")

parseCor :: Int -> String -> Either String SomeCor
parseCor idx texto = case corFromString texto of
  Just cor -> Right cor
  Nothing -> Left ("Linha " ++ show idx ++ " (" ++ nomeSlot idx ++ "): cor desconhecida '" ++ texto ++ "'.")

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