# Dotfiles

Fork de [omerxx/dotfiles](https://github.com/omerxx/dotfiles), adapté pour Ubuntu (WSL2 et Linux natif).

## Installation sur une machine neuve

### 1. Cloner

```bash
sudo apt install zsh git stow
git clone https://github.com/soleromel/dotfiles ~/apps/dotfiles
cd ~/apps/dotfiles
```

Garde le chemin `~/apps/dotfiles` : la config tmux y fait référence.

### 2. Vérifier les prérequis

```bash
./check-requirements.sh
```

Le script liste tous les outils dont les configs ont besoin, puis affiche la commande `apt` et les étapes d'installation manuelle pour ce qui manque. Il n'installe rien. Relance-le jusqu'à ce que tout soit vert.

Sous Debian/Ubuntu, `bat` et `fd` s'installent sous les noms `batcat` et `fdfind` : le script affiche le `ln -s` à lancer pour que les noms habituels fonctionnent.

### 3. Sauvegarder ta config actuelle

`stow` refuse d'écraser un fichier existant, mais fais quand même un backup :

```bash
tar czf ~/dotfiles-backup-$(date +%F).tgz -C ~ .zshrc .zshenv .tmux.conf .config 2>/dev/null
```

### 4. Lier les configs

`stow` crée un symlink de chaque dossier de premier niveau vers `~/.config` (voir `.stowrc`). Les dossiers dont tu veux garder ta propre version, comme `nvim`, y sont listés en `--ignore`.

```bash
stow -n -v .   # simulation : montre ce qui sera lié et les conflits éventuels
stow -v .
```

En cas de conflit, déplace d'abord ton fichier ou ajoute le dossier dans `.stowrc`.

### 5. Zsh

La config zsh n'est pas gérée par stow : crée le lien à la main et fais de zsh le shell par défaut :

```bash
ln -s ~/apps/dotfiles/zshrc/.zshrc ~/.zshrc
chsh -s "$(command -v zsh)"
```

Les réglages propres à une machine (tokens, chemins de projets…) vont dans `~/.zshrc.local`. Il est chargé en dernier et n'est jamais versionné.

### 6. Plugins tmux

Lance tmux et appuie sur `prefix` + `I` pour installer les plugins (le prefix est `Ctrl-s`).

## Organisation

| Chemin | Contenu |
| --- | --- |
| `zshrc/.zshrc` | Config zsh principale, fonctionne sur tout Linux |
| `zshrc/wsl.zsh` | Spécifique à WSL (presse-papier Windows, `open`), chargé quand `$WSL_DISTRO_NAME` est défini |
| `zshrc/predict.zsh` | Suggestion grisée sur un prompt vide |
| `check-requirements.sh` | Vérifie les outils installés |
| `.stowrc` | Cible de stow (`~/.config`) et dossiers ignorés |

## Fonctions du shell

- **Suggestion grisée** : après une commande réussie, la commande que tu lances habituellement ensuite apparaît en grisé ; après une erreur, la correction proposée. `Ctrl-e` pour l'accepter, tape autre chose pour l'ignorer.
- `f` : choisir une correction pour la dernière commande ratée ([pay-respects](https://github.com/iffse/pay-respects)).
- `Ctrl-x Ctrl-x` : corriger la ligne en cours de saisie.
- `help` : parcourir les pages [tldr](https://tldr.sh) avec fzf (en français si disponible, sinon en anglais).
- `z` / `zi` : aller dans un dossier ([zoxide](https://github.com/ajeetdsouza/zoxide)).
- `Ctrl-r` : chercher dans l'historique ([atuin](https://atuin.sh)).
- `fcp` : choisir un fichier avec fzf et copier son chemin dans le presse-papier.
- `v` : choisir un fichier avec fzf et l'ouvrir dans nvim.

## Récupérer les mises à jour d'omerxx

```bash
git fetch upstream
git log --oneline master..upstream/master   # voir ce qui a changé
```

Le push vers `upstream` est désactivé : les modifications ne partent que vers ce fork.
