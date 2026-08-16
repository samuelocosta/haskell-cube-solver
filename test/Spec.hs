module Main (main) where

import Cubo.Leitura (lerCubo)
import Cubo.Solver (Solucao (..), ehResolvido, resolverCubo)
import Data.List (isInfixOf, sort)
import System.Directory (doesDirectoryExist, listDirectory)
import System.Exit (exitFailure, exitSuccess)
import System.FilePath (takeBaseName, takeExtension, (</>))

main :: IO ()
main = do
  putStrLn "=================================================="
  putStrLn "    Bateria de Testes: Diretorio cubos/          "
  putStrLn "=================================================="

  temDiretorio <- doesDirectoryExist "cubos"
  if not temDiretorio
    then do
      putStrLn "Erro: O diretorio 'cubos' nao foi encontrado!"
      exitFailure
    else do
      arquivos <- listDirectory "cubos"
      let arquivosTxt = sort ["cubos" </> f | f <- arquivos, takeExtension f == ".txt"]

      resultados <- mapM testarArquivo arquivosTxt

      let total = length resultados
          sucessos = length (filter id resultados)
          falhas = total - sucessos

      putStrLn "\n--------------------------------------------------"
      putStrLn ("Total de arquivos testados: " ++ show total)
      putStrLn ("Testes bem-sucedidos:       " ++ show sucessos)
      putStrLn ("Testes com falha:           " ++ show falhas)
      putStrLn "--------------------------------------------------"

      if falhas == 0
        then do
          putStrLn "RESULTADO: TODOS OS TESTES PASSARAM COM SUCESSO!"
          exitSuccess
        else do
          putStrLn "RESULTADO: OCORRERAM FALHAS NOS TESTES."
          exitFailure

testarArquivo :: FilePath -> IO Bool
testarArquivo caminho = do
  let nome = takeBaseName caminho
      esperaInvalido =
        "invalid" `isInfixOf` nome
          || "repetida" `isInfixOf` nome
          || "virada" `isInfixOf` nome

  putStrLn ("\n[TESTE] Arquivo: " ++ caminho)
  resultadoLeitura <- lerCubo caminho
  case resultadoLeitura of
    Left erroLeitura ->
      if esperaInvalido
        then do
          putStrLn ("  -> PASSOU (Esperava-se erro e foi rejeitado corretamente)")
          putStrLn ("     Motivo: " ++ erroLeitura)
          pure True
        else do
          putStrLn ("  -> FALHA (Esperava-se cubo valido, mas ocorreu erro de leitura)")
          putStrLn ("     Erro: " ++ erroLeitura)
          pure False
    Right cubo ->
      case resolverCubo cubo of
        Left erroSolver ->
          if esperaInvalido
            then do
              putStrLn ("  -> PASSOU (Esperava-se erro e o solver rejeitou corretamente)")
              putStrLn ("     Motivo: " ++ erroSolver)
              pure True
            else do
              putStrLn ("  -> FALHA (Esperava-se solucao, mas o solver falhou)")
              putStrLn ("     Erro: " ++ erroSolver)
              pure False
        Right solucao ->
          if esperaInvalido
            then do
              putStrLn "  -> FALHA (Esperava-se erro, mas o cubo foi considerado valido e resolvido!)"
              pure False
            else do
              let resolvido = ehResolvido (cuboFinalSolucao solucao)
                  movimentos = movimentosSolucao solucao
              if resolvido
                then do
                  putStrLn "  -> PASSOU (Cubo valido e resolvido com sucesso)"
                  putStrLn ("     Qtd Movimentos: " ++ show (length movimentos))
                  putStrLn ("     Sequencia:      " ++ show movimentos)
                  pure True
                else do
                  putStrLn "  -> FALHA (O solver retornou movimentos, mas o cubo final nao esta monocromatico)"
                  pure False
