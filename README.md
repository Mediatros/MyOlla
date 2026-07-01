# MyOlla

Mirroir non officiel des releases macOS d'[Ollama](https://github.com/ollama/ollama).

Ce dépôt ne contient aucun code source d'Ollama. Il republie uniquement, sous forme de releases GitHub, le binaire macOS officiel d'Ollama après une seule modification : l'application `Ollama.app` est renommée en `Olla_<version>.app` puis remise dans un `.dmg`. Aucune autre modification n'est apportée au logiciel.

## Pourquoi

Permettre de récupérer une version renommée de l'application, à partir d'un dépôt personnel, sans confusion avec le nom ou la marque « Ollama ».

## Provenance et licence

- Projet original : https://github.com/ollama/ollama
- Licence : MIT (voir [LICENSE](LICENSE)), recopiée telle quelle depuis le dépôt original.
- Chaque release de ce dépôt correspond à une release officielle d'Ollama (même numéro de version), et ne modifie que le nom de l'application.

## Fonctionnement

Le script [`scripts/mirror.sh`](scripts/mirror.sh) :

1. détecte la dernière release d'Ollama,
2. télécharge l'asset `Ollama.dmg`,
3. renomme `Ollama.app` en `Olla_<version>.app`,
4. reconstruit un `.dmg`,
5. publie ce `.dmg` comme release sur ce dépôt.

Un [workflow GitHub Actions](.github/workflows/mirror-ollama.yml) exécute ce script automatiquement (déclenchement manuel ou planifié) sur un runner macOS.

### Exécution manuelle

```bash
gh auth login   # si nécessaire
./scripts/mirror.sh
```
