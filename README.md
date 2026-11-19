# ConVeo - Controle de Veículo

Aplicativo mobile **ConVeo** (Controle de Veículo) para controle de gastos com combustível, desenvolvido em **Flutter** como atividade acadêmica da disciplina **Programação para Dispositivos Móveis II**.

## Funcionalidades

- **Cadastro de veículo**: registro de marca, modelo, ano e cilindrada, com consulta à BrasilAPI para seleção de marca e modelo.
- **Registro de abastecimentos**: tipo de combustível (etanol, gasolina, diesel), preço por litro, quilometragem e quantidade de litros.
- **Dashboard**: indicadores de consumo (km/L), custo por quilômetro (R$/km), total gasto e gráficos de evolução.
- **Histórico**: lista cronológica de abastecimentos com opção de exclusão.
- **Persistência local**: dados armazenados em SQLite no dispositivo.

## API Utilizada

- **BrasilAPI** (gratuita, sem API key)
  - Endpoint de marcas: `GET https://brasilapi.com.br/api/fipe/marcas/v1/carros`
  - Endpoint de modelos: `GET https://brasilapi.com.br/api/fipe/veiculos/v1/{codigoMarca}`

## Bibliotecas Utilizadas

| Pacote | Versão | Finalidade |
|--------|--------|------------|
| `sqflite` | ^2.4.2 | Banco de dados SQLite local |
| `path` | ^1.8.3 | Caminho do banco de dados |
| `path_provider` | ^2.1.4 | Diretório do aplicativo |
| `http` | ^1.2.2 | Requisições HTTP para a BrasilAPI |
| `fl_chart` | ^0.69.0 | Gráficos de consumo e custo/km |
| `provider` | ^6.1.2 | Gerenciamento de estado |

## Estrutura do Projeto

```
lib/
  main.dart                    # Ponto de entrada e configuração dos providers
  models/
    vehicle.dart               # Modelo do veículo
    fueling.dart               # Modelo do abastecimento
  services/
    fipe_service.dart          # Consulta à BrasilAPI (marcas/modelos)
  repositories/
    vehicle_repository.dart    # CRUD do veículo
    fueling_repository.dart    # CRUD dos abastecimentos
  database/
    database_helper.dart       # Configuração do SQLite
  providers/
    vehicle_provider.dart      # Estado do veículo (ChangeNotifier)
    fueling_provider.dart      # Estado dos abastecimentos (ChangeNotifier)
  screens/
    dashboard_screen.dart      # Dashboard com indicadores e gráficos
    vehicle_screen.dart        # Cadastro/visualização do veículo
    fueling_screen.dart        # Cadastro de abastecimento
    history_screen.dart        # Histórico de abastecimentos
  widgets/
    main_navigation.dart       # Navegação inferior (NavigationBar)
    fueling_card.dart          # Card do abastecimento no histórico
    consumption_chart.dart     # Gráfico de consumo (km/L)
    cost_chart.dart            # Gráfico de custo (R$/km)
  utils/
    calculations.dart          # Fórmulas de consumo e custo
    validators.dart            # Validações de campos
    constants.dart             # Constantes (tipos de combustível, URLs)
```

## Como Executar

### Pré-requisitos

- **Flutter 3.47+** (stable)
- **Dart 3.13+**
- **IntelliJ IDEA** ou VS Code com plugin Flutter

### Passos

1. Clone o repositório:
   ```bash
   git clone <url-do-repositorio>
   cd conveo
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Execute o aplicativo:
   ```bash
   flutter run
   ```

## Fórmulas Utilizadas

- **Valor total**: `preço por litro × quantidade de litros`
- **Distância percorrida**: `quilometragem atual - quilometragem anterior`
- **Consumo (km/L)**: `distância percorrida / litros do abastecimento atual`
- **Custo por quilômetro (R$/km)**: `valor total do abastecimento / distância percorrida`

> O primeiro abastecimento serve apenas como referência e não apresenta indicadores.

## Autor

Desenvolvido como atividade acadêmica individual.
