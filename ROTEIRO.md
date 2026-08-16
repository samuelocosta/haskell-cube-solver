# Roteiro de Apresentação em Vídeo: haskell-cube-solver

- **Tempo Alvo:** ~2 minutos e 30 segundos (Limite do professor: <= 3 minutos / 180s)
- **Tom de Voz:** Natural, confiante e técnico na medida certa (postura de um estudante de graduação apresentando seu projeto final).

---

## ⏱️ Cronograma Geral

| Bloco | Tempo Estimado | Tema Principal |
| :--- | :---: | :--- |
| **Bloco 1** | 0:00 - 0:25 (~25s) | Introdução, Contexto e Objetivo do Projeto |
| **Bloco 2** | 0:25 - 1:00 (~35s) | Modelagem no Sistema de Tipos (GADTs, DataKinds, Existenciais) |
| **Bloco 3** | 1:00 - 1:35 (~35s) | Geometria 3D e Validações Físicas/Matemáticas |
| **Bloco 4** | 1:35 - 2:05 (~30s) | Motor de Movimentos e Solver BFS Bidirecional |
| **Bloco 5** | 2:05 - 2:30 (~25s) | Demonstração Prática (Stack CLI, Testes) e Encerramento |

---

## Bloco 1: Introdução e Objetivo (0:00 - 0:25)

### 🎙️ Fala:
> "Olá professor e colegas! Hoje vou apresentar o **haskell-cube-solver**, o projeto final que desenvolvi para a disciplina de **Desenvolvimento Guiado por Tipos**.
>
> O objetivo do projeto foi construir um motor formal e solucionador para o **Cubo Mágico 2x2**. Mais do que apenas encontrar os movimentos de resolução, a ideia central foi usar os recursos avançados de tipos do Haskell para modelar a física do cubo, garantindo que estados impossíveis sejam barrados antes mesmo do algoritmo de busca começar."

### 🎬 Sugestões Visuais para o Vídeo:
- **0:00 - 0:10:** Slide inicial limpo com o título do projeto, seu nome, nome da disciplina e data.
- **0:10 - 0:25:** Imagem do cubo 2x2 renderizado em 3D (gerada pelo `cube_viewer.py`) ou um pequeno vídeo/animação do cubo girando.

---

## Bloco 2: A Modelagem no Sistema de Tipos (0:25 - 1:00)

### 🎙️ Fala:
> "Para garantir essa segurança, apliquei diretamente os conceitos vistos em aula:
>
> Primeiro, usei **DataKinds** para promover as seis cores a tipos e criei uma **Type Family fechada** para mapear faces opostas.
>
> Cada quina é representada por um **GADT** com *smart constructors*. Isso significa que é impossível criar uma peça com cores repetidas ou com faces opostas juntas, como branco e amarelo na mesma quina.
>
> E como o estado inicial do cubo é lido de um arquivo de texto em tempo de execução, usei **Tipos Existenciais** com *Singletons* para fazer a transição segura do mundo não tipado do `IO` para o nosso motor estritamente tipado."

### 🎬 Sugestões Visuais para o Vídeo:
- **0:25 - 0:40:** Print do código de `src/Cubo/Cor.hs` destacando a `type family Oposto (cor :: Cor) :: Cor`.
- **0:40 - 1:00:** Print do código de `src/Cubo/Quina.hs` mostrando o GADT `data Quina c1 c2 c3` e a função `validarCriacaoQuina`, com caixas ou setas destacando a segurança dos tipos.

---

## Bloco 3: Geometria Espacial e Validações Matemáticas (1:00 - 1:35)

### 🎙️ Fala:
> "No espaço tridimensional, o cubo é representado por oito gavetas ou slots fixos nos eixos X, Y e Z.
>
> Antes de disparar o solver, o módulo de validação executa três verificações matemáticas fundamentais:
>
> 1. Checa se temos exatamente as oito quinas canônicas reais, sem repetições;
> 2. Valida a **quiralidade 3D**, impedindo quinas espelhadas que não existem no mundo real;
> 3. E checa a lei de conservação de rotação das peças: a soma dos *twists* das quinas módulo 3 precisa ser zero. Se alguém girar uma quina à mão no próprio eixo, o sistema detecta e recusa na hora com uma mensagem explicativa."

### 🎬 Sugestões Visuais para o Vídeo:
- **1:00 - 1:15:** Diagrama esquemático dos 8 slots espaciais (`esqTrasCima`, `dirTrasCima`, etc.) com os eixos X (Esquerda/Direita), Y (Frente/Trás) e Z (Cima/Baixo).
- **1:15 - 1:35:** Slide ou trecho de `src/Cubo/Validacao.hs` com os 3 tópicos de validação: *Conjunto*, *Quiralidade 3D* e *Twist ($\sum \equiv 0 \pmod 3$)*.

---

## Bloco 4: Teoria dos Movimentos e Solver Bidirecional (1:35 - 2:05)

### 🎙️ Fala:
> "Para movimentar o cubo, fixamos uma das quinas de base como referência. Com isso, qualquer estado pode ser resolvido combinando apenas três rotações de faces: **U** (cima), **R** (direita) e **F** (frente), além de suas versões anti-horárias.
>
> Para encontrar a solução, implementei uma **Busca em Largura Bidirecional (BFS Bidirecional)**. O algoritmo expande a busca simultaneamente a partir do cubo embaralhado e a partir do cubo montado.
>
> No instante em que as duas fronteiras se cruzam, os caminhos são unidos e normalizados, garantindo a menor sequência de passos em fração de segundo."

### 🎬 Sugestões Visuais para o Vídeo:
- **1:35 - 1:50:** Ilustração simples dos movimentos $U$, $R$ e $F$ atuando sobre o cubo.
- **1:50 - 2:05:** Esquema gráfico de **BFS Bidirecional** (duas árvores de busca crescendo uma em direção à outra até o ponto de encontro) + print da função `buscaBfsBidirecional` em `src/Cubo/Solver.hs`.

---

## Bloco 5: Demonstração Prática e Conclusão (2:05 - 2:30)

### 🎙️ Fala:
> "Para finalizar, vamos ver o programa funcionando na prática:
>
> Rodando `stack run` passando o arquivo de um cubo embaralhado, o solver encontra a solução instantaneamente e exibe a sequência de rotações e o estado final.
>
> E executando `stack test`, rodamos a bateria automatizada de testes que cobre tanto a resolução de casos válidos quanto a rejeição correta de cada caso de erro físico ou matemático.
>
> Esse foi o projeto! Muito obrigado pela atenção."

### 🎬 Sugestões Visuais para o Vídeo:
- **2:05 - 2:18:** Gravação de tela do terminal executando `stack run -- cubos/cubo_1.txt` com a saída formatada do solver.
- **2:18 - 2:28:** Gravação de tela rodando `stack test` mostrando todos os testes passando em verde.
- **2:28 - 2:30:** Slide de encerramento com agradecimento e link do repositório no GitHub.

---

## 📌 Dicas Práticas para a Gravação

1. **Ritmo de Fala:** Mantenha um ritmo natural e pausado. As marcações de tempo já deixam uma margem segura de ~30 segundos para o limite de 3 minutos.
2. **Software Recomendado:** OBS Studio para gravação de tela com webcam no canto, ou gravação de voz separada editada sobre os slides e prints (usando CapCut, Shotcut ou DaVinci Resolve).
3. **Configuração no YouTube:** Ao subir o vídeo, marque a privacidade obrigatoriamente como **Não listado** (*Unlisted*) e cole o link no seu relatório de entrega conforme exigido pelo professor.
