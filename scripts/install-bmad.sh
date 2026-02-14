#!/usr/bin/env bash
# Script d'installation automatique du framework BMAD
# Automatise les interactions utilisateur pour npx bmad-method@alpha install

set -e

echo "=== Installation automatique de BMAD Framework ==="
echo ""

# Vérifier si expect est disponible
if ! command -v expect &> /dev/null; then
    echo "❌ 'expect' n'est pas installé."
    echo "   Installez-le avec: brew install expect"
    exit 1
fi

# Créer un script expect temporaire
EXPECT_SCRIPT=$(mktemp)

cat > "$EXPECT_SCRIPT" << 'EOF'
#!/usr/bin/expect -f

set timeout 300

spawn npx bmad-method@alpha install

# Attendre le banner BMAD et le premier prompt "continue"
expect {
    "Press Enter to continue" { send "\r" }
    "continue" { send "\r" }
    timeout { puts "Timeout waiting for first prompt"; exit 1 }
}

# Prompt: Installation directory
expect {
    "Installation directory" { send "\r" }
    timeout { puts "Timeout waiting for directory prompt"; exit 1 }
}

# Prompt: Install to this directory? (Y/n)
expect {
    "Install to this directory" { send "\r" }
    "(Y/n)" { send "\r" }
    timeout { puts "Timeout waiting for confirm directory"; exit 1 }
}

# Prompt: Select agent pack (avec espace pour toggle puis enter)
expect {
    "agent pack" { send " \r" }
    "Select" { send " \r" }
    timeout { puts "Timeout waiting for agent pack"; exit 1 }
}

# Prompt suivant (entrée simple)
expect {
    "?" { send "\r" }
    timeout { puts "Timeout"; exit 1 }
}

# Prompt: quelque chose avec No
expect {
    "?" { send "No\r" }
    timeout { puts "Timeout"; exit 1 }
}

# Prompts restants (4 entrées)
expect {
    "?" { send "\r" }
    timeout { puts "Timeout"; exit 1 }
}

expect {
    "?" { send "\r" }
    timeout { puts "Timeout"; exit 1 }
}

expect {
    "?" { send "\r" }
    timeout { puts "Timeout"; exit 1 }
}

expect {
    "?" { send "\r" }
    timeout { puts "Timeout"; exit 1 }
}

# Attendre la fin
expect {
    eof { puts "\nInstallation complete" }
    "complete" { }
    "success" { }
    timeout { puts "Process finished or timed out" }
}
EOF

chmod +x "$EXPECT_SCRIPT"

echo "🚀 Lancement de l'installation..."
echo ""

# Exécuter le script expect
expect "$EXPECT_SCRIPT"

# Nettoyer
rm -f "$EXPECT_SCRIPT"

echo ""
echo "✅ Installation BMAD terminée!"
