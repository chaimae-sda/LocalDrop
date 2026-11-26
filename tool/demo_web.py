"""Launch the verified Flutter Web build on loopback for the classroom demo."""
import hashlib
import os
import tempfile
import webbrowser
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from zipfile import ZipFile

ARTIFACT = "https://github.com/chaimae-sda/LocalDrop/actions/runs/45508720288/artifacts/14974497597"
DIGEST = "254bf1462909bdd3cf97e1342f4bd1f63481e6784d7d751586577226da51320f"
ROOT = Path(__file__).resolve().parents[1]


def select_build(cache):
    local = ROOT / "build" / "web"
    if (local / "main.dart.js").is_file():
        return local
    downloads = Path.home() / "Downloads"
    files = sorted(downloads.glob("localdrop-web*.zip"), key=os.path.getmtime, reverse=True)
    for archive in files:
        if hashlib.sha256(archive.read_bytes()).hexdigest() == DIGEST:
            with ZipFile(archive) as bundle:
                bundle.extractall(cache)
            return cache
    print("Télécharge localdrop-web.zip depuis GitHub et garde-le dans Téléchargements.")
    webbrowser.open(ARTIFACT)
    input("Quand le téléchargement est terminé, appuie sur Entrée. ")
    for archive in downloads.glob("localdrop-web*.zip"):
        if hashlib.sha256(archive.read_bytes()).hexdigest() == DIGEST:
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
