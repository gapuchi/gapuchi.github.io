default:
    @just --list

# Serve the site with live reload
serve:
    mkdocs serve

# Build the static site into site/
build:
    mkdocs build
