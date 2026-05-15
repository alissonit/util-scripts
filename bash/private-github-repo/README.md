# GitHub Repo Manager

Gerencia repositórios do GitHub via API - torna repos privados/públicos e remove forks.

## O que faz

- **Set Privacy**: Muda a visibilidade dos repositórios (privado ou público)
- **Remove Forks**: Deleta repositórios que são forks
- **Filtro Protegido**: Exclui repos com `fiap` ou nomeado `alissonit` por padrão

## Instalação

### Pré-requisitos
```bash
# macOS
brew install curl jq

# Linux (Ubuntu/Debian)
sudo apt-get install curl jq

# Linux (Fedora/RHEL)
sudo dnf install curl jq
```

## Configuração

1. Crie um Personal Access Token em: https://github.com/settings/tokens
   - Selecione escopos: `repo`, `delete_repo`

2. Configure a variável de ambiente:
```bash
export GITHUB_TOKEN="ghp_seu_token_aqui"
```

## Como usar

### Tornar todos os repos privados (exceto protegidos)
```bash
./script.sh --action set-privacy --mode private
```

### Tornar todos os repos públicos (exceto protegidos)
```bash
./script.sh --action set-privacy --mode public
```

### Deletar todos os forks (exceto protegidos)
```bash
./script.sh --action remove-forks
```

### Processar apenas repos protegidos
```bash
# Tornar repos "fiap" e "alissonit" privados
./script.sh --action set-privacy --mode private --protect-only

# Deletar forks apenas dos repos protegidos
./script.sh --action remove-forks --protect-only
```

### Usar outro username
```bash
./script.sh --action set-privacy --mode private --user outro-usuario
```

## Repos Protegidos

Por padrão, repos são protegidos se:
- Contêm `fiap` no nome (ex: `fiap-project`, `my-fiap-repo`)
- São nomeados exatamente `alissonit` (não afeta `alissonit-project`)

## Exemplos Práticos

```bash
# Scenario 1: Deixar tudo privado, exceto fiap e alissonit
export GITHUB_TOKEN="seu_token"
./script.sh --action set-privacy --mode private

# Scenario 2: Depois, tornar os repos fiap públicos novamente
./script.sh --action set-privacy --mode public --protect-only

# Scenario 3: Limpar forks que não são protegidos
./script.sh --action remove-forks
```

## Flags

| Flag | Descrição |
|------|-----------|
| `--action` | `remove-forks` ou `set-privacy` (obrigatório) |
| `--mode` | `private` ou `public` (obrigatório para set-privacy) |
| `--protect-only` | Processa apenas repos protegidos |
| `--user` | Username do GitHub (padrão: alissonit) |

## Avisos

⚠️ **CUIDADO**: 
- `remove-forks` deleta permanentemente os repositórios
- Não reverta com Ctrl+C durante a execução
- Teste com `--protect-only` primeiro
