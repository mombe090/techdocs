# Bienvenue sur Ma Documentation & Astuces

Ceci est votre site de documentation personnel construit avec **Material for MkDocs**, inspiré du style de documentation officiel de mkdocs-material.

## Fonctionnalités

Material for MkDocs offre de nombreuses fonctionnalités intéressantes :

!!! tip "Design Magnifique"
    Un design moderne et réactif qui fonctionne sur tous les appareils avec un changement automatique entre les modes clair et sombre.

!!! example "Support de Contenu Riche"
    Support pour les avertissements, blocs de code, onglets, diagrammes, équations mathématiques et bien plus encore.

!!! note "Recherche Rapide"
    Fonctionnalité de recherche intégrée avec surbrillance et suggestions.

## Démarrage

### Écrire de la Documentation

Créez de nouveaux fichiers markdown dans le répertoire `docs/` :

```bash
# Créer une nouvelle page
echo "# Ma Nouvelle Page" > docs/ma-page.md
```

### Blocs de Code

Les blocs de code supportent la coloration syntaxique :

```python
def bonjour_monde():
    """Une simple fonction bonjour monde."""
    print("Bonjour le Monde!")
    return True
```

### Avertissements

Vous pouvez utiliser différents types d'avertissements :

!!! warning "Important"
    N'oubliez pas de mettre à jour votre configuration dans `mkdocs.yml` !

!!! success "Astuce Pro"
    Utilisez `mkdocs serve` pour prévisualiser les changements en temps réel.

### Listes de Tâches

- [x] Installer mkdocs-material
- [x] Configurer mkdocs.yml
- [ ] Ajouter plus de contenu
- [ ] Déployer votre site

### Tableaux

| Fonctionnalité | Description |
|----------------|-------------|
| Onglets | Organiser le contenu en onglets |
| Mermaid | Créer des diagrammes |
| Math | Support mathématique LaTeX |
| Icônes | Plus de 10 000 icônes disponibles |

## Prochaines Étapes

1. Personnaliser la configuration `mkdocs.yml`
2. Ajouter votre propre contenu dans le répertoire `docs/`
3. Explorer la [documentation Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
4. Déployer votre site sur GitHub Pages, GitLab Pages ou tout hébergement statique

---

Créé avec [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
