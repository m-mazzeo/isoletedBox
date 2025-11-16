#!/bin/bash

## ========================= INSTALL APPS FUNCTIONS ======================= ##

function install_stegosolve_app()
{
    wget http://www.caesum.com/handbook/Stegsolve.jar -O /opt/tools/stego/stegsolve.jar
    sudo chmod +x /opt/tools/stego/stegsolve.jar

    sudo tee << EOF_SCRIPT > /opt/homebrew/bin/stegsolve
#!/bin/bash
java -jar /opt/tools/stego/stegsolve.jar "$@"
EOF_SCRIPT

    sudo chmod +x /opt/homebrew/bin/stegsolve
}

function install_vscode_app()
{
    firefox "https://code.visualstudio.com/download#"

    printf "Inserisci il percorso dello zip: "
    read -r code_path

    unzip "$code_path"
    mv "Visual Studio Code.app" /Applications
    ln -s /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code* /opt/homebrew/bin/ 2>/dev/null || true
}

## ========================= ENSURE FUNCTIONS ========================= ##

function ensure() {

    case "$1" in
        brew)
            if ! command -v brew &> /dev/null
            then
                echo "Homebrew non trovato, installazione in corso..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            ;;
        python)
            if ! command -v python3 &> /dev/null
            then
                echo "Python3 non trovato, installazione in corso..."
                brew install python
            fi

            ## uv package manager
            if ! command -v uv &> /dev/null
            then
                echo "uv package manager non trovato, installazione in corso..."
                curl -LsSf https://astral.sh/uv/install.sh | sh
            fi
            ;;
        pwnbox|pwnbox_env)
            export PWNBOX_PATH="$HOME/Downloads/pwnbox/"
            if [ ! -d "$PWNBOX_PATH" ]; then
                mkdir -p "$PWNBOX_PATH/.venv"
                uv venv --prompt pwnbox "$PWNBOX_PATH/.venv"

                mkdir -p "$PWNBOX_PATH/.devcontainer"
                [ -f Dockerfile ] && mv Dockerfile "$PWNBOX_PATH/.devcontainer/Dockerfile"
                [ -f devcontainer.json ] && mv devcontainer.json "$PWNBOX_PATH/.devcontainer/devcontainer.json"
            else
                echo "Pwnbox già presente in $PWNBOX_PATH"
            fi
            ;;
        openjdk_21)
            if ! brew list openjdk@21 &> /dev/null
            then
                echo "OpenJDK 21 non trovato, installazione in corso..."
                brew install openjdk@21
                echo 'export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc
                export CPPFLAGS="-I/opt/homebrew/opt/openjdk@21/include"
                source ~/.zshrc
            fi
            ;;
        firefox)
            if ! command -v firefox &> /dev/null
            then
                echo "Firefox non trovato, installazione in corso..."
                brew install --cask firefox
            fi
            ;;
        vscode)
            if command -v code &> /dev/null
            then
                echo "Visual Studio Code gia' installato"
                return 0
            fi

            install_vscode_app

            code --install-extension ms-vscode-remote.remote-containers
            echo "Visual Studio Code installato correttamente con l'estensione Remote - Containers"
            echo "Ricorda che per funzionare serve Docker Desktop attivo in background"
            ;;
        all)
            ensure python
            ensure openjdk_21
            ensure firefox
            ensure vscode
            ensure pwnbox
            ;;
        *)
            echo "Uso: ensure {python|pwnbox|openjdk_21|firefox|vscode|all}"
            return 1
            ;;
    esac
}

## ========================= INSTALLATION SCRIPTS ========================= ##

function install_misc_tools ()
{
    # Programming stuffs
    for ensure_item in python firefox vscode
    do
        ensure "$ensure_item"
    done

    brew install wget php git ngrok
    
    ## ngrok
    printf "Inserisci il token di ngrok: "
    token="$(read -p)"
    ngrok config add-authtoken "$token"
    
    ## docker
    firefox "https://desktop.docker.com/mac/main/arm64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-mac-arm64"
    echo "adesso apri il dmg e trascina docker nella cartella applicazioni, poi premi invio"
    read -r _
}

function install_stego_tools ()
{   
    ensure openjdk_21
    sudo mkdir -p /opt/tools/stego

    brew install binwalk

    brew install gimp --cask
    install_stegosolve_app
    # john the ripper non so se installarlo
}

function install_network_tools()
{
    brew install nmap wireshark
    brew install wireshark --cask
    brew install --cask wireshark-chmodbpf

    # pyshark
    ensure python
    ensure pwnbox_env

    cd "$PWNBOX_PATH" || exit 1
    uv pip install pyshark
}

function install_web_tools()
{
    firefox "https://portswigger.net/burp/community-download-thank-you"
    echo "Adesso installa burp suite community manualmente, poi premi invio"
    read -r _
    
    cd "$PWNBOX_PATH" || exit 1
    uv pip install requests beautifulsoup4
}

# function install_software_sec_toos()
# {
#     ensure vscode
# 
#     # reverse engineering tools
#     brew install ghidra radare2
# 
#     # binary analysis tools
#     brew install ht qemu
#     
#     ensure python
#     ensure pwnbox_env 
#     cd "$PWNBOX_PATH" || exit 1
# 
#     uv pip install pwntools ropper    
#     # TODO: fare il devcontainer per questo
# }
