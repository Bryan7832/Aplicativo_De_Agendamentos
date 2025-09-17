# BarbeariaPI - Aplicativo de Agendamento para Barbearias
<img width="500" height="500" alt="image" src="https://github.com/user-attachments/assets/fd4d052d-e0fb-483e-994f-63b72dca6f76" />

📋 Sobre o Projeto
---
BarbeariaPI é um aplicativo móvel desenvolvido em Flutter para gerenciamento de barbearias. A plataforma permite que administradores gerenciem seus estabelecimentos e colaboradores, enquanto os clientes podem agendar seus serviços facilmente.

Funcionalidades Principais
 .Autenticação de usuários : Sistema de login e cadastro
 .Dois perfis de usuário : Administrador e Colaborador
 .Gestão de barbearias : Cadastro de horários e dias de funcionamento
 .Gerenciamento de colaboradores : Adicionar funcionários com horários específicos
 .Agendamento de clientes : Interface intuitiva para marcação de horários
 .Visualização de agenda : Calendário para visualizar todos os agendamentos

🛠️ Tecnologias Utilizadas
---
.Flutter : Framework UI para desenvolvimento multiplataforma
.Riverpod : Gerenciamento de estado
.Dio : Cliente HTTP para chamadas de API
.Json Rest Server : Backend simulado para desenvolvimento
.AsyncState : Gerenciamento de estados assíncronos
.Preferências Compartilhadas : Armazenamento local de dados

📐 Arquitetura
---
O projeto utiliza uma arquitetura baseada em:

 .Recursos : Organização por funcionalidades
 .Padrão de Repositório : Para acessar dados
 .Camada de Serviço : Para lógica de negócios
 .View-Model : Para gerenciamento de estado da UI
 .Qualquer Padrão : Para tratamento de erros

🚀 Como Executar o Projeto
---
 .Pré-requisitos
 .Flutter SDK (versão ≥ 3.7.2)
 .Dart SDK (versão compatível com Flutter)
 .Android Studio / VSCode
 .Emulador ou dispositivo físico Android/iOS
 .Git

Instalação
Clone ou repositório:

git clone https://github.com/Vitor1s/barbeariaPI.git
cd barbeariaPI
Instalar as dependências:

flutter pub get
Configurar o Backend (Servidor JSON REST):

# Instale o Json Rest Server (necessário apenas uma vez)
dart pub global activate json_rest_server

# Navegue até a pasta da API
cd api

# Inicie o servidor na porta 8080
json_rest_server run
Configurar o IP do servidor:

Abra o arquivo lib/src/core/rest_client/rest_client.darte ajuste a URL base para o IP da sua máquina:

baseUrl: 'http://SEU_IP_AQUI:8080',
Para descobrir seu IP, use:

Linux/Mac :ifconfig | grep "inet "
Janelas :ipconfig
Execute o aplicativo:

flutter run
Configuração para dispositivos físicos
Para testar em um dispositivo físico, verifique se:

Ambos o dispositivo e o computador estão na mesma rede Wi-Fi
O firewall do computador permite conexões na porta 8080
O arquivo de configuração da API ( api/config.yaml) está configurado comhost: 0.0.0.0
📱 Usando o Aplicativo
Acesso Inicial
O aplicativo possui usuários de teste pré-configurados:

Administrador:

E-mail: felipe@gmail.com
Senha: 123123
Colaborador:

E-mail: tito@gmail.com
Senha: 123456
Fluxo de Utilização:
Faça login com uma conta existente ou crie uma nova
Como administrador:
Cadastre sua barbearia (dias e horários de funcionamento)
Gerência colaboradores
Visualizar agendamentos
Como colaborador:
Visualize sua agenda
Receba notificações de novos agendamentos
🔄 Gestão de Estado
O projeto utiliza Riverpod para gerenciamento de estado, seguindo estas práticas:

AsyncValue para estados assíncronos
StateNotifierProvider para estados mutáveis
Provedor para estados imutáveis/dependências
🔧 Resolução de Problemas Comuns
Erro de conexão com a API
Para encontrar erros de tempo limite:
