/// Espécies de pet disponíveis para seleção no onboarding.
enum PetSpecies {
  dog('Cachorro'),
  cat('Gato'),
  dragon('Dragão'),
  capybara('Capivara');

  const PetSpecies(this.label);
  final String label;
}
