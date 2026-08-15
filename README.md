# haskell-cube-solver: Motor e Solver Tipado para Cubo Mágico 2x2

O sistema será dividido em 5 fases lógicas, onde cada fase implementa uma exigência específica da ementa de Desenvolvimento Orientado a Tipos, mantendo o escopo focado em nota máxima com menor esforço.

## Fase 1: Entrada de Dados Espacial (A Fronteira)
O programa lerá o estado inicial do cubo a partir de um arquivo `cubo.txt`. Em vez de usar tipos dinâmicos hiper-complexos, usaremos a ordem das linhas para inferir a geometria 3D.

**Regra de Leitura:** O arquivo terá exatamente 8 linhas, lidas na ordem estrita dos eixos X, Z e Y (Esquerda->Direita, Trás->Frente, Cima->Baixo). Cada linha contém as cores de uma quina separadas por espaço.

**Exemplo do formato esperado no TXT (Cubo Resolvido):**
```text
Laranja Azul Branco
Vermelho Azul Branco
Laranja Verde Branco
Vermelho Verde Branco
Laranja Azul Amarelo
Vermelho Azul Amarelo
Laranja Verde Amarelo
Vermelho Verde Amarelo
```

**Exemplo de orientação no TXT (descritivo das posições):**
```text
peça 1: esqTrasCima: corEsquerda=Laranja corTrás=Azul corCima=Branco
peça 2: dirTrasCima: corDireita=Vermelho corTrás=Azul corCima=Branco
peça 3: esqFrenteCima: corEsquerda=Laranja corFrente=Verde corCima=Branco
peça 4: dirFrenteCima: corDireita=Vermelho corFrente=Verde corCima=Branco
peça 5: esqTrasBaixo: corEsquerda=Laranja corTrás=Azul corBaixo=Amarelo
peça 6: dirTrasBaixo: corDireita=Vermelho corTrás=Azul corBaixo=Amarelo
peça 7: esqFrenteBaixo: corEsquerda=Laranja corFrente=Verde corBaixo=Amarelo
peça 8: dirFrenteBaixo: corDireita=Vermelho corFrente=Verde corBaixo=Amarelo
```

**Aplicação da Ementa:**
* **Tipos Existenciais:** Como o estado exato lido do TXT só é descoberto em tempo de execução, a leitura retorna um tipo empacotado que transita os dados do mundo inseguro (TXT) para o motor tipado.
* **Singletons / Smart Constructors:** Uma função que recebe a `String` (ex: "Branco") e tenta promovê-la para o tipo estrito da cor.

---

## Fase 2: Modelagem Física da Peça (O Coração Tipado)
Vermelho Verde Amarelo
```

**Aplicação da Ementa:**
* **Tipos Existenciais:** Como o estado exato lido do TXT só é descoberto em tempo de execução, a leitura retorna um tipo empacotado que transita os dados do mundo inseguro (TXT) para o motor tipado.
* **Singletons / Smart Constructors:** Uma função que recebe a `String` (ex: "Branco") e tenta promovê-la para o tipo estrito da cor.

---

## Fase 2: Modelagem Física da Peça (O Coração Tipado)
A peça individual (Quina) não saberá onde está no espaço, mas será matematicamente impossível instanciar uma peça fisicamente quebrada.

**A Regra:** Uma Quina do cubo de Rubik deve ter 3 cores distintas e não pode conter cores opostas (Branco/Amarelo, Azul/Verde, Vermelho/Laranja).

**Aplicação da Ementa:**
* **Tipos, Kinds, Sorts:** As seis cores do cubo são promovidas a *Kinds* (tipos em si, não apenas valores).
* **Type Families (Closed):** Criação de uma família `Oposto` no nível do tipo que mapeia as cores opostas.
* **GADTs (Generalized Algebraic Data Types):** O construtor seguro da `Quina c1 c2 c3`. Ele usa restrições para forçar o compilador a verificar que `c1` é diferente de `c2` e que `c1` não é o `Oposto` de `c2`.

---

## Fase 3: O Mapa 3D (Estrutura de Slots Fixos)
Para evitar a complexidade de mudar os tipos das posições em tempo de execução, a estrutura espacial do cubo será um registro estático.

**A Regra:** O cubo é uma "caixa" com 8 gavetas nomeadas, que são preenchidas exatamente na ordem da leitura do TXT.

**Aplicação da Ementa:**
* **Tipos de Dados Algébricos (ADTs):** Um *record* com os 8 campos explícitos (`esqTrasCima`, `dirTrasCima`, etc.), cada um guardando uma `Quina` segura.
* **Tipos Fantasma (Phantom Types):** O registro recebe um marcador de estado `Cubo s`. Assim, podemos ter um `Cubo <Embaralhado>` ou um `Cubo <Resolvido>`.

---

## Fase 4: O Motor de Teoria de Grupos (Movimentos)
O sistema terá apenas 3 funções de movimento (U = Cima, R = Direita, F = Frente), já que os outros 3 movimentos de um 2x2 podem ser simulados girando o cubo inteiro.

**A Regra:** O movimento pega as peças dos slots afetados, rotaciona a ordem das cores (simulando a mudança de orientação geométrica) e as coloca nos novos slots correspondentes.

**Aplicação da Ementa:**
* **Polimorfismo Paramétrico e Ad-Hoc:** Classes de tipos padronizando como os movimentos atuam sobre o tipo `Cubo`.
* **Listas Heterogêneas (HList):** Para enfileirar uma série de movimentos matemáticos que formarão a solução, preservando o tipo exato de cada rotação aplicada.

---

## Fase 5: O Algoritmo Solver
O sistema fará uma busca (Busca em Largura - BFS) combinando os movimentos U, R e F até encontrar o estado montado.

**A Regra:** O algoritmo não precisa de validações lógicas (if/elses) para checar se quebrou a estrutura do cubo, pois a compilação do GADT da Fase 2 e o Record da Fase 3 já provaram que os movimentos são estritamente seguros.

**Aplicação da Ementa:**
* **Tipos Dependentes (Simulados via Tipagem de Retorno):** A assinatura da função principal força o compilador a ser o juiz do solver. A função será algo como `resolver :: Cubo <Embaralhado> -> (ListaHeterogenea Movimentos, Cubo <Resolvido>)`. Se a lógica puder acidentalmente retornar um cubo não resolvido, o Haskell recusará compilar.