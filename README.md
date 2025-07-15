# 📅 Timetable - iOS Calendar App

Um aplicativo iOS elegante e moderno para visualização e gerenciamento de eventos de calendário, desenvolvido com Clean Architecture e as melhores práticas de desenvolvimento iOS.

## 🚀 Funcionalidades

### ✅ Implementadas
- **Visualização de Eventos**: Lista organizada por mês com eventos do calendário nativo
- **Detalhes do Dia**: Tela detalhada mostrando todos os eventos de um dia específico
- **Modo Escuro/Claro**: Suporte completo aos temas do sistema
- **Animações Suaves**: Transições elegantes entre telas
- **Tratamento de Permissões**: Gerenciamento inteligente de acesso ao calendário
- **Design Responsivo**: Interface adaptada para diferentes tamanhos de tela

## 📋 Lista de Tarefas

### 🔥 Prioridade Alta
- [ ] Corrigir compatibilidade com iOS 18.5 no projeto
- [ ] Implementar funcionalidade de adicionar evento (botão já existe)

### ⚡ Prioridade Média
- [ ] Implementar edição de eventos existentes
- [ ] Adicionar filtros por tipo de evento na lista principal
- [ ] Implementar busca de eventos por título/descrição
- [ ] Melhorar animações e transições entre telas
- [ ] Implementar testes unitários para use cases
- [ ] Otimizar performance de carregamento de eventos

### 🔵 Prioridade Baixa
- [ ] Criar tela de configurações da app
- [ ] Implementar diferentes visualizações (lista, grid, timeline)
- [ ] Adicionar notificações push para eventos
- [ ] Implementar widget para tela inicial
- [ ] Implementar testes de UI automatizados
- [ ] Melhorar acessibilidade (VoiceOver, Dynamic Type)
- [ ] Adicionar suporte a múltiplos calendários

## 🏗️ Arquitetura

O projeto segue os princípios da **Clean Architecture** com separação clara de responsabilidades:

```
📦 Projeto
├── 🎯 Domain/          # Entidades e casos de uso
├── 📊 Data/            # Implementação de repositórios
├── 🎨 Presentation/    # ViewModels e lógica de apresentação  
├── 📱 UI/              # Controllers, Views e Coordinators
└── 🧪 Tests/           # Testes unitários e de UI
```

### Frameworks e Tecnologias

- **UIKit**: Interface nativa iOS
- **EventKit**: Integração com calendário do sistema
- **Resolver**: Injeção de dependências
- **Fastlane**: Automação de build e deploy
- **Clean Architecture**: Padrão arquitetural
- **Coordinator Pattern**: Gerenciamento de navegação
- **MVVM**: Padrão de apresentação

## 📋 Pré-requisitos

- Xcode 15.0+
- iOS 14.0+
- Swift 5.9+
- macOS 13.0+

## 🛠️ Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/timetable.git
   cd timetable
   ```

2. **Abra o projeto no Xcode**
   ```bash
   open timetable.xcodeproj
   ```

3. **Configure o Bundle Identifier**
   - Altere o Bundle Identifier no projeto
   - Configure sua equipe de desenvolvimento

4. **Execute o projeto**
   - Selecione um simulador ou dispositivo
   - Pressione `Cmd + R` para executar

## 🏃‍♂️ Como Usar

### Primeira Execução
1. O app solicitará permissão para acessar o calendário
2. Conceda a permissão para visualizar seus eventos
3. Os eventos serão carregados e organizados por mês

### Navegação
- **Tela Principal**: Lista de eventos agrupados por mês
- **Tap em um dia**: Acesse os detalhes com eventos daquele dia
- **Botão Voltar**: Retorne à tela principal com animação

### Permissões
- Se negar acesso ao calendário, uma tela de erro será exibida
- Use o botão "Permitir Acesso" para abrir as configurações do iOS

## 🧪 Testes

### Executar Testes Unitários
```bash
# Pelo Xcode
Cmd + U

# Pelo terminal
xcodebuild test -scheme timetable_ios -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Executar Testes de UI
```bash
xcodebuild test -scheme UITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📦 Build e Deploy

O projeto usa **Fastlane** para automação:

```bash
# Instalar dependências
bundle install

# Build para desenvolvimento
fastlane build_dev

# Deploy para TestFlight
fastlane deploy_testflight
```

## 🎨 Design System

### Cores
- **Primária**: Vermelho Timetable (`#FF0000`)
- **Texto**: Adaptativo ao modo escuro/claro
- **Background**: Cores do sistema iOS
- **Cinza**: Texto secundário e divisores

### Tipografia
- **Fonte**: Rubik (Regular, Bold, Medium, Light)
- **Tamanhos**: 16pt, 40pt, 64pt, 80pt

### Componentes
- **EventCell**: Célula para lista de eventos
- **DetailEventCell**: Célula para detalhes do dia
- **CustomLaunchScreen**: Tela de carregamento personalizada

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

### Padrões de Código
- Use SwiftLint para formatação
- Siga as convenções de nomenclatura Swift
- Documente funções públicas
- Escreva testes para novas funcionalidades

## 📝 Roadmap

### Versão 2.0
- [ ] Criação e edição de eventos
- [ ] Filtros avançados
- [ ] Busca inteligente
- [ ] Sincronização em tempo real

### Versão 2.1
- [ ] Widget para tela inicial
- [ ] Notificações push
- [ ] Múltiplos calendários
- [ ] Export/Import de eventos

### Versão 2.2
- [ ] Apple Watch companion
- [ ] Siri Shortcuts
- [ ] Compartilhamento de eventos
- [ ] Temas personalizados

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Equipe

**Desenvolvimento**: Hoff Silva
- GitHub: [@hoffsilva](https://github.com/hoffsilva)
- Email: hoff.silva@email.com

**Design**: Lucas Ferreira

---

**Desenvolvido com ❤️ e Swift**