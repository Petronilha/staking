# ERC1155 NFT Staking System

![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.29-363636?style=flat-square&logo=solidity)
![Foundry](https://img.shields.io/badge/Foundry-Framework-orange?style=flat-square&logo=ethereum)
![License](https://img.shields.io/badge/License-Unlicensed-red?style=flat-square)

Um sistema de Staking de NFTs (ERC1155) robusto desenvolvido em Solidity utilizando o framework **Foundry**. Este contrato permite que usuários depositem seus NFTs e ganhem recompensas em tokens ERC20 baseadas na duração do staking (tempo de permanência).

## 📋 Funcionalidades

- **Staking de ERC1155:** Usuários podem depositar seus NFTs no contrato inteligente de forma segura.
- **Recompensas em ERC20:** Integração com tokens ERC20 para pagamento de recompensas automáticas.
- **Lógica Temporal:** O cálculo de recompensas é baseado estritamente no `block.timestamp`.
- **Sistema de Níveis de Recompensa:**
  - **Elegibilidade Mínima:** O stake deve durar pelo menos 30 segundos.
  - **Recompensa Padrão:** Para stakes com duração entre 30 segundos e 30 dias.
  - **Recompensa Premium:** Recompensa dobrada se o stake durar mais de 30 dias.
- **Segurança:** Utiliza a biblioteca OpenZeppelin para padrões de tokens (ERC20/ERC1155) e transferências seguras.

## 🛠 Tecnologias Utilizadas

- **Solidity** (>=0.8.29)
- **Foundry** (Forge, Cast, Anvil)
- **OpenZeppelin Contracts**

## ⚙️ Instalação e Configuração

Para rodar este projeto localmente, certifique-se de ter o [Foundry](https://book.getfoundry.sh/getting-started/installation) instalado em sua máquina.

1. **Clone o repositório:**
   ```bash
   git clone git@github.com:Petronilha/staking.git
   cd staking

```

2. **Instale as dependências:**
```bash
forge install
forge install OpenZeppelin/openzeppelin-contracts --no-commit

```


3. **Compile os contratos:**
```bash
forge build

```



## 🧪 Testes

O projeto conta com uma suíte de testes completa utilizando `forge-std`. Os testes cobrem cenários de staking, unstaking, manipulação de tempo (Time Warp) e cálculo de recompensas.

Para rodar todos os testes:

```bash
forge test

```

Para rodar com logs detalhados (útil para visualizar traces e eventos):

```bash
forge test -vvvv

```

### Cobertura dos Cenários de Teste:

| Teste | Descrição |
| --- | --- |
| `testInitialStakingTime` | Verifica se o tempo inicial de staking de um novo usuário é zero. |
| `testStake` | Garante que o NFT é transferido corretamente para o contrato e o timestamp é registrado. |
| `testUnstake` | Valida a devolução do NFT ao usuário e a atualização do acumulador de tempo total. |
| `testRewardMinusMonth` | Simula o avanço do tempo (Time Warp) para **menos de 30 dias** e verifica o pagamento de 10 Tokens. |
| `testRewardPlusMonth` | Simula o avanço do tempo para **mais de 30 dias** e verifica o pagamento de 20 Tokens. |

## 📐 Regras de Negócio (Smart Contract)

O contrato `staking.sol` implementa as seguintes lógicas principais:

### 1. Stake (`stake`)

* Exige `setApprovalForAll` prévio no contrato do NFT.
* Transfere o NFT do usuário para o cofre do contrato.
* Armazena o `block.timestamp` do início do depósito.

### 2. Unstake (`unstake`)

* Verifica se há um stake ativo.
* Calcula a duração (`now - timestamp inicial`) e adiciona ao histórico do usuário.
* Devolve o NFT ao dono original.
* Reseta os dados do stake atual.

### 3. Recompensa (`reward`)

A função de recompensa verifica o tempo decorrido desde o depósito:

* **< 30 Segundos:** Reverte (Sem recompensa).
* **>= 30 Segundos E < 30 Dias:** Paga **10 Tokens** (10 * 10^18).
* **>= 30 Dias:** Paga **20 Tokens** (20 * 10^18).

## 📂 Estrutura de Pastas Sugerida

```text
.
├── lib/
│   ├── forge-std/
│   └── openzeppelin-contracts/
├── src/
│   └── staking.sol       # Lógica do Contrato
├── test/
│   └── staking.t.sol       # Testes Unitários e Mocks
├── foundry.toml
└── README.md

```

## 👤 Autor

**Daniel Petronilha**

* Blockchain Developer

---

*Este código é desenvolvido para fins educacionais e de portfólio.*