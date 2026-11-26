"""Launch the verified Flutter Web build on loopback for the classroom demo."""
import hashlib
import os
import tempfile
import webbrowser
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from zipfile import ZipFile

import json
from urllib.request import urlopen

def latest_build():
    api = "https://api.github.com/repos/chaimae-sda/LocalDrop"
    with urlopen(api + "/actions/artifacts?name=localdrop-web&per_page=100", timeout=20) as response:
        artifacts = json.load(response)["artifacts"]
    artifact = next(item for item in artifacts if not item["expired"] and item["workflow_run"]["head_branch"] == "main")
    run = artifact["workflow_run"]["id"]
    return (f"https://github.com/chaimae-sda/LocalDrop/actions/runs/{run}/artifacts/{artifact['id']}",
            artifact["digest"].removeprefix("sha256:"))

ROOT = Path(__file__).resolve().parents[1]


def select_build(cache):
    local = ROOT / "build" / "web"
    if (local / "main.dart.js").is_file():
        return local
    artifact_url, digest = latest_build()
    downloads = Path.home() / "Downloads"
    files = sorted(downloads.glob("localdrop-web*.zip"), key=os.path.getmtime, reverse=True)
    for archive in files:
        if hashlib.sha256(archive.read_bytes()).hexdigest() == digest:
            with ZipFile(archive) as bundle:
                bundle.extractall(cache)
            return cache
    print("Télécharge localdrop-web.zip depuis GitHub et garde-le dans Téléchargements.")
    webbrowser.open(artifact_url)
    input("Quand le téléchargement est terminé, appuie sur Entrée. ")
    for archive in downloads.glob("localdrop-web*.zip"):
        if hashlib.sha256(archive.read_bytes()).hexdigest() == digest:
            with ZipFile(archive) as bundle:
                bundle.extractall(cache)
            return cache
    raise SystemExit("Archive introuvable. Vérifie le téléchargement puis relance la démo.")


if __name__ == "__main__":
    with tempfile.TemporaryDirectory() as temp:
        folder = select_build(Path(temp))
        handler = partial(SimpleHTTPRequestHandler, directory=str(folder))
        with ThreadingHTTPServer(("127.0.0.1", 0), handler) as server:
            url = f"http://127.0.0.1:{server.server_port}/"
            print("Démo Flutter :", url, "\nGarde cette fenêtre ouverte pendant la présentation.")
            webbrowser.open(url)
            server.serve_forever()
