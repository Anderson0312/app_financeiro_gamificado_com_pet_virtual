# Personalização de Cores dos Pets

## 📝 Descrição

Esta funcionalidade permite que os usuários personalizem as cores de seus pets virtuais, escolhendo entre presets temáticos ou cores específicas para cada animal. Cada espécie de pet possui suas próprias opções de cores que respeitam as características originais do animal.

## 🎨 Funcionalidades

### Durante o Onboarding
- Após selecionar a espécie do pet, o usuário pode escolher entre diferentes esquemas de cores temáticos
- Presets pré-definidos para cada espécie:
  - **Gato**: Laranja Clássico, Gato Cinza, Gato Preto, Gato Siamês, Gato Tigrado
  - **Cachorro**: Caramelo Clássico, Golden Retriever, Labrador Preto, Beagle, Husky
  - **Dragão**: Dragão Verde, Dragão de Fogo, Dragão de Gelo, Dragão Negro, Dragão Dourado
  - **Capivara**: Capivara Natural, Capivara Clara, Capivara Escura, Capivara Dourada

### Personalização Avançada
- Acesse através do ícone de paleta (🎨) na tela principal do pet
- **Presets Rápidos**: Escolha entre esquemas de cores pré-definidos
- **Personalização Manual**: Customize individualmente:
  - Cor Principal (corpo do animal)
  - Cor Secundária (barriga, detalhes)
  - Cor do Contorno (bordas e definição)
- **Preview em Tempo Real**: Veja as mudanças instantaneamente
- **Restaurar Padrão**: Botão para voltar às cores originais

## 🏗️ Estrutura Técnica

### Novos Arquivos Criados

```
lib/features/pet/domain/models/
  └── pet_colors.dart                    # Modelo de cores do pet

lib/features/pet/presentation/screens/
  └── pet_color_customization_screen.dart # Tela de personalização

lib/features/onboarding/presentation/screens/
  └── pet_color_selection_screen.dart    # Seleção de cores no onboarding
```

### Arquivos Modificados

```
lib/features/pet/domain/models/
  └── pet.dart                           # Adicionado campo customColors

lib/features/pet/petbody/
  ├── pet_cat.dart                       # Suporte a cores customizadas
  ├── pet_dog.dart                       # Suporte a cores customizadas
  ├── pet_dragon.dart                    # Suporte a cores customizadas
  └── pet_capybara.dart                  # Suporte a cores customizadas

lib/features/pet/presentation/
  ├── screens/pet_screen.dart            # Botão de personalização
  ├── widgets/pet_avatar.dart            # Aplicar cores customizadas
  └── providers/pet_provider.dart        # Método updatePet

lib/features/onboarding/presentation/screens/
  └── onboarding_flow_screen.dart        # Integração da seleção de cores

lib/routing/
  └── app_router.dart                    # Nova rota de personalização
```

## 💾 Persistência de Dados

As cores personalizadas são salvas automaticamente no modelo `Pet` e persistidas através do `PetRepository`. O formato de serialização JSON inclui:

```json
{
  "customColors": {
    "primaryColor": 4294940672,
    "secondaryColor": 4294948249,
    "outlineColor": 4291559168
  }
}
```

## 🎯 Como Usar

### Para o Usuário

1. **Durante o Onboarding**:
   - Escolha a espécie do pet
   - Selecione um esquema de cores entre os presets disponíveis
   - Continue com o nome do pet

2. **Depois do Onboarding**:
   - Na tela principal do pet, toque no ícone de paleta (🎨)
   - Escolha um preset ou personalize manualmente
   - Toque em "Salvar Cores" para aplicar

### Para Desenvolvedores

```dart
// Criar cores customizadas
final customColors = PetColors(
  primaryColor: Color(0xFFFF9600),
  secondaryColor: Color(0xFFFFD579),
  outlineColor: Color(0xFFC77100),
);

// Aplicar ao pet
final pet = Pet(
  id: 'id',
  name: 'Nome',
  species: PetSpecies.cat,
  customColors: customColors,
);

// Usar cores padrão
final defaultCatColors = PetColors.defaultCat;
```

## 🌈 Paleta de Cores Disponível

A personalização manual oferece 25 cores cuidadosamente selecionadas:
- Tons de marrom (naturais para animais)
- Tons de laranja e amarelo
- Tons de cinza e preto
- Tons de verde
- Tons de vermelho/fogo
- Tons de azul
- Cores especiais (dourado, branco, bege)

## 🔄 Fluxo de Dados

```
OnboardingFlow -> PetColorSelectionScreen -> Pet (com customColors)
                                           ↓
                                    PetRepository
                                           ↓
                                    Shared Preferences

PetScreen -> PetColorCustomizationScreen -> updatePet()
                                         ↓
                                  PetRepository
                                         ↓
                                  Shared Preferences
```

## 🎨 Design System

- Seguindo Material Design 3
- Interface consistente com o resto do app
- Feedback visual imediato
- Cards de preset com preview de cores
- Preview em tempo real do pet animado

## 🔮 Futuras Melhorias

- [ ] Adicionar mais presets baseados em feedback dos usuários
- [ ] Permitir criar e salvar presets personalizados
- [ ] Compartilhar esquemas de cores com outros usuários
- [ ] Desbloquear cores especiais através de conquistas
- [ ] Adicionar gradientes e padrões
- [ ] Sistema de votação para presets da comunidade
