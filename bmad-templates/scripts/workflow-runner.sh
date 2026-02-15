#!/bin/bash

# ============================================================================
# BMAD + TEA Workflow Runner v2.0
# Script d'automatisation du workflow complet avec tracabilite
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
PROJECT_TYPE=""
# shellcheck disable=SC2034
CURRENT_PHASE=""
CURRENT_STORY=""
STATE_DIR=".bmad"
STATE_FILE="$STATE_DIR/workflow-state.yaml"
PROJECT_NAME=""
BUG_ID=""

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} ${BOLD}$1${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_subheader() {
    echo ""
    echo -e "${CYAN}┌──────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} $1"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────────────────────┘${NC}"
}

print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_checkpoint() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW} ✓ CHECKPOINT: $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ============================================================================
# STATE MANAGEMENT
# ============================================================================

init_state() {
    mkdir -p "$STATE_DIR"

    cat > "$STATE_FILE" << EOF
# BMAD Workflow State
metadata:
  version: "2.0"
  created_at: "$(date -Iseconds)"
  updated_at: "$(date -Iseconds)"
  project_name: "$PROJECT_NAME"

workflow:
  type: "$PROJECT_TYPE"
  started_at: "$(date -Iseconds)"
  state: "in_progress"

status:
  current_phase: ""
  current_step: ""
  overall_progress: "0%"
  last_action: "workflow_started"
  last_action_at: "$(date -Iseconds)"

history:
  - timestamp: "$(date -Iseconds)"
    action: "workflow_started"
    details: "Started $PROJECT_TYPE workflow"
EOF

    print_success "Etat initialise dans $STATE_FILE"
}

update_state() {
    local phase="$1"
    local step="$2"
    local action="$3"

    if [ -f "$STATE_FILE" ]; then
        # Update using sed (simple approach for bash)
        sed -i.bak "s/current_phase:.*/current_phase: \"$phase\"/" "$STATE_FILE"
        sed -i.bak "s/current_step:.*/current_step: \"$step\"/" "$STATE_FILE"
        sed -i.bak "s/last_action:.*/last_action: \"$action\"/" "$STATE_FILE"
        sed -i.bak "s/updated_at:.*/updated_at: \"$(date -Iseconds)\"/" "$STATE_FILE"
        sed -i.bak "s/last_action_at:.*/last_action_at: \"$(date -Iseconds)\"/" "$STATE_FILE"
        rm -f "$STATE_FILE.bak"
    fi
}

check_existing_state() {
    if [ -f "$STATE_FILE" ]; then
        echo ""
        echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${MAGENTA}║${NC} ${BOLD}WORKFLOW EN COURS DETECTE${NC}"
        echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""

        # Extract info from state
        local wf_type
        wf_type=$(grep "type:" "$STATE_FILE" | head -1 | cut -d'"' -f2)
        local current_phase
        current_phase=$(grep "current_phase:" "$STATE_FILE" | cut -d'"' -f2)
        local current_step
        current_step=$(grep "current_step:" "$STATE_FILE" | cut -d'"' -f2)
        local last_action
        last_action=$(grep "last_action:" "$STATE_FILE" | head -1 | cut -d'"' -f2)

        echo "  Type de workflow: $wf_type"
        echo "  Phase actuelle:   $current_phase"
        echo "  Etape actuelle:   $current_step"
        echo "  Derniere action:  $last_action"
        echo ""

        echo "Options:"
        echo "  1) Reprendre le workflow en cours"
        echo "  2) Recommencer un nouveau workflow (efface l'etat)"
        echo "  3) Afficher le status detaille"
        echo "  4) Quitter"
        echo ""

        read -p "Votre choix [1-4]: " choice

        case $choice in
            1)
                PROJECT_TYPE="$wf_type"
                return 0  # Resume
                ;;
            2)
                rm -f "$STATE_FILE"
                return 1  # New workflow
                ;;
            3)
                show_status
                exit 0
                ;;
            4)
                exit 0
                ;;
            *)
                print_error "Choix invalide"
                exit 1
                ;;
        esac
    fi
    return 1  # No existing state
}

show_status() {
    if [ ! -f "$STATE_FILE" ]; then
        print_warning "Aucun workflow en cours"
        return
    fi

    print_header "STATUS DU WORKFLOW"

    local wf_type
    wf_type=$(grep "type:" "$STATE_FILE" | head -1 | cut -d'"' -f2)
    local current_phase
    current_phase=$(grep "current_phase:" "$STATE_FILE" | cut -d'"' -f2)
    local current_step
    current_step=$(grep "current_step:" "$STATE_FILE" | cut -d'"' -f2)
    local progress
    progress=$(grep "overall_progress:" "$STATE_FILE" | cut -d'"' -f2)
    local last_action
    last_action=$(grep "last_action:" "$STATE_FILE" | head -1 | cut -d'"' -f2)
    local started
    started=$(grep "started_at:" "$STATE_FILE" | head -1 | cut -d'"' -f2)

    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│  BMAD Workflow: $wf_type"
    echo "│  Demarre: $started"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  Phase actuelle:  $current_phase"
    echo "│  Etape actuelle:  $current_step"
    echo "│  Derniere action: $last_action"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  Progression: $progress"
    echo "└─────────────────────────────────────────────────────────────┘"
}

# ============================================================================
# QUESTIONNAIRE INTELLIGENT
# ============================================================================

run_questionnaire() {
    print_header "ASSISTANT DE CHOIX DU WORKFLOW"

    echo "Repondez a ces questions pour identifier le workflow adapte:"
    echo ""

    # Question 1
    echo -e "${BOLD}Question 1: Quel est l'etat de votre projet?${NC}"
    echo ""
    echo "  A - Je demarre un NOUVEAU projet (pas de code existant)"
    echo "  B - J'ai un projet EXISTANT sans documentation BMAD"
    echo "  C - J'ai un projet EXISTANT avec documentation BMAD"
    echo "  D - Je dois corriger un BUG dans un projet existant"
    echo ""

    read -p "Votre reponse [A/B/C/D]: " q1
    q1=$(echo "$q1" | tr '[:lower:]' '[:upper:]')

    case $q1 in
        A)
            PROJECT_TYPE="WORKFLOW_COMPLET"
            print_success "Workflow: WORKFLOW_COMPLET"
            return
            ;;
        D)
            PROJECT_TYPE="DEBUG"
            print_success "Workflow: DEBUG"
            return
            ;;
        B)
            PROJECT_TYPE="DOCUMENT_PROJECT"
            print_success "Workflow: DOCUMENT_PROJECT"
            return
            ;;
        C)
            # Question 2 - Feature size
            echo ""
            echo -e "${BOLD}Question 2: Quelle est l'ampleur du travail?${NC}"
            echo ""
            echo "  A - Petit ajout: 1 a 3 stories, pas de changement d'architecture"
            echo "  B - Gros ajout: 4+ stories, possible impact architectural"
            echo ""

            read -p "Votre reponse [A/B]: " q2
            q2=$(echo "$q2" | tr '[:lower:]' '[:upper:]')

            case $q2 in
                A)
                    # Verification QUICK_FLOW
                    echo ""
                    echo -e "${BOLD}Verification pour Quick Flow:${NC}"
                    echo "Cochez les criteres qui s'appliquent:"
                    echo ""

                    local checks=0

                    read -p "  Fonctionnalite simple et bien definie? [y/N]: " c1
                    [ "$c1" == "y" ] || [ "$c1" == "Y" ] && ((checks++))

                    read -p "  Pas de nouvelle integration externe? [y/N]: " c2
                    [ "$c2" == "y" ] || [ "$c2" == "Y" ] && ((checks++))

                    read -p "  Pas de changement du modele de donnees? [y/N]: " c3
                    [ "$c3" == "y" ] || [ "$c3" == "Y" ] && ((checks++))

                    read -p "  Maximum 3 stories? [y/N]: " c4
                    [ "$c4" == "y" ] || [ "$c4" == "Y" ] && ((checks++))

                    read -p "  Framework de test deja en place? [y/N]: " c5
                    [ "$c5" == "y" ] || [ "$c5" == "Y" ] && ((checks++))

                    if [ $checks -eq 5 ]; then
                        PROJECT_TYPE="QUICK_FLOW"
                        print_success "Workflow: QUICK_FLOW"
                    else
                        print_warning "Criteres non remplis ($checks/5)"
                        print_info "Recommandation: Utiliser WORKFLOW_COMPLET"
                        PROJECT_TYPE="WORKFLOW_COMPLET"
                    fi
                    ;;
                B)
                    PROJECT_TYPE="WORKFLOW_COMPLET"
                    print_success "Workflow: WORKFLOW_COMPLET"
                    ;;
                *)
                    print_error "Reponse invalide"
                    exit 1
                    ;;
            esac
            return
            ;;
        *)
            print_error "Reponse invalide"
            exit 1
            ;;
    esac
}

# ============================================================================
# PHASE 0: DOCUMENT_PROJECT ONBOARDING
# ============================================================================

run_phase_0() {
    if [ "$PROJECT_TYPE" != "DOCUMENT_PROJECT" ]; then
        return
    fi

    print_header "PHASE 0: DOCUMENT_PROJECT - Analyse du projet existant"
    update_state "phase_0" "starting" "phase_0_started"

    print_step "0.1 - Analyse du code existant"
    echo "Commande: analyze-codebase"
    echo "Output: docs/codebase-analysis.md, docs/technical-debt-report.md"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_0" "0.1" "analyze_codebase_completed"

    print_step "0.2 - Avez-vous des documents projet existants?"
    read -p "Oui [y] / Non [N]: " has_docs

    if [ "$has_docs" == "y" ] || [ "$has_docs" == "Y" ]; then
        print_step "0.3 - Import des documents projet"
        echo "Action: Copier tous vos documents dans docs/imported/"
        echo ""
        echo "Documents acceptes:"
        echo "  - Cahier des charges"
        echo "  - Specifications fonctionnelles"
        echo "  - Maquettes/wireframes"
        echo "  - Documentation API"
        echo "  - Schemas de base de donnees"
        echo ""
        read -r -p "Documents importes? [y/N]: " _done
        update_state "phase_0" "0.3" "import_docs_completed"

        print_step "0.4 - Analyse des documents"
        echo "Commande: analyze-project-documentation"
        echo "Output: docs/project-synthesis.md"
        echo ""
        echo "Utilisez le prompt: prompt-document-project.md"
        read -p "Appuyez sur Entree apres execution..."
        update_state "phase_0" "0.4" "analyze_docs_completed"

        print_step "0.5 - Reconciliation documentation vs code"
        echo "Commande: reconcile-documentation"
        echo "Output: docs/doc-code-reconciliation.md"
        read -p "Appuyez sur Entree apres execution..."
        update_state "phase_0" "0.5" "reconciliation_completed"
    fi

    print_checkpoint "Phase 0 complete - Base documentaire creee"
}

# ============================================================================
# PHASE 1: ANALYSIS (WORKFLOW_COMPLET only)
# ============================================================================

run_phase_1() {
    if [ "$PROJECT_TYPE" != "WORKFLOW_COMPLET" ]; then
        return
    fi

    print_header "PHASE 1: ANALYSIS"
    update_state "phase_1" "starting" "phase_1_started"

    print_step "1.1 - Brainstorming"
    echo "Commande: brainstorm"
    echo "Output: docs/brainstorm-report.md"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_1" "1.1" "brainstorm_completed"

    print_step "1.2 - Research"
    echo "Commande: research"
    echo "Output: docs/research-findings.md"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_1" "1.2" "research_completed"

    print_step "1.3 - Product Brief"
    echo "Commande: create-product-brief"
    echo "Output: docs/product-brief.md"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_1" "1.3" "product_brief_completed"

    print_checkpoint "Phase 1 complete"
}

# ============================================================================
# QUICK FLOW (Feature Small)
# ============================================================================

run_quick_flow() {
    print_header "QUICK FLOW"
    update_state "quick_flow" "starting" "quick_flow_started"

    print_step "QF.1 - Quick Spec"
    echo "Commande: quick-spec"
    echo "Output: specs/quick-spec-{feature}.md"
    echo ""
    echo "Utilisez le prompt: prompt-quick-spec.md"
    read -r -p "Quick spec creee? [y/N]: " _done
    update_state "quick_flow" "QF.1" "quick_spec_completed"

    print_step "QF.2 - Analyse des tests de regression"
    echo "Commande: tea → analyze-regression"
    echo "Output: specs/regression-analysis-{feature}.md"
    echo ""
    echo -e "${YELLOW}IMPORTANT: Cette etape identifie les tests existants${NC}"
    echo -e "${YELLOW}qui doivent etre executes pour verifier la non-regression.${NC}"
    echo ""
    echo "Utilisez le prompt: prompt-analyze-regression.md"
    read -r -p "Analyse de regression faite? [y/N]: " _done
    update_state "quick_flow" "QF.2" "regression_analysis_completed"

    print_step "QF.3 - Creation des stories (1-3 max)"
    echo "Commande: create-story"
    echo "Output: stories/story-{X.Y.Z}.md"
    echo ""
    # shellcheck disable=SC2034
    read -p "Nombre de stories creees [1-3]: " num_stories
    update_state "quick_flow" "QF.3" "stories_created"

    print_checkpoint "Quick Flow complete - Pret pour Story Loop"
}

# ============================================================================
# STORY LOOP WITH REGRESSION
# ============================================================================

run_story_loop() {
    print_header "STORY LOOP: $CURRENT_STORY"
    update_state "phase_4" "ST.1_$CURRENT_STORY" "story_started"

    print_step "ST.1 - Create Story (si pas deja fait)"
    echo "Commande: create-story"
    read -p "Appuyez sur Entree..."

    print_step "ST.2 - ATDD (Tests avant code)"
    echo "Commandes: tea → atdd"
    echo ""
    echo -e "${RED}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${RED}│ VALIDATION: npm test → TOUS LES TESTS DOIVENT ECHOUER  │${NC}"
    echo -e "${RED}│             (Phase RED du TDD)                         │${NC}"
    echo -e "${RED}└─────────────────────────────────────────────────────────┘${NC}"
    read -p "Tests echouent (RED)? [y/N]: " tests_fail
    if [ "$tests_fail" != "y" ] && [ "$tests_fail" != "Y" ]; then
        print_error "Les tests doivent echouer avant implementation!"
        return 1
    fi
    update_state "phase_4" "ST.2_$CURRENT_STORY" "atdd_completed"

    print_step "ST.3 - Development (Implementation)"
    echo "Commande: dev-story"
    echo ""
    echo -e "${GREEN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│ VALIDATION: npm test → TOUS LES TESTS DOIVENT PASSER   │${NC}"
    echo -e "${GREEN}│             (Phase GREEN du TDD)                       │${NC}"
    echo -e "${GREEN}└─────────────────────────────────────────────────────────┘${NC}"
    read -p "Tests passent (GREEN)? [y/N]: " tests_pass
    if [ "$tests_pass" != "y" ] && [ "$tests_pass" != "Y" ]; then
        print_error "Les tests doivent passer!"
        return 1
    fi
    update_state "phase_4" "ST.3_$CURRENT_STORY" "dev_completed"

    print_step "ST.4 - Test Review"
    echo "Commandes: tea → test-review"
    echo "VALIDATION: Score >= 80/100"
    read -p "Score obtenu: " score
    if [ "$score" -lt 80 ]; then
        print_warning "Score < 80 - Corriger les issues"
        read -p "Score apres correction: " score
    fi
    update_state "phase_4" "ST.4_$CURRENT_STORY" "test_review_completed"

    print_step "ST.5 - Code Review"
    echo "Commande: code-review"
    read -p "Code review approuvee? [y/N]: " approved
    if [ "$approved" != "y" ] && [ "$approved" != "Y" ]; then
        print_warning "Corriger les issues"
        return 1
    fi
    update_state "phase_4" "ST.5_$CURRENT_STORY" "code_review_completed"

    print_step "ST.6 - Trace (Traceability)"
    echo "Commandes: tea → trace (Phase 1)"
    # shellcheck disable=SC2034
    read -p "Tracabilite mise a jour? [y/N]: " trace_ok
    update_state "phase_4" "ST.6_$CURRENT_STORY" "trace_completed"

    print_step "ST.7 - Tests de Non-Regression"
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ ETAPE OBLIGATOIRE: Execution des tests de non-regression                ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Basé sur: specs/regression-analysis-{feature}.md"
    echo ""
    echo "Commande: npm test:regression -- --scope=related"
    echo ""
    read -p "Tests de regression passent? [y/N]: " regression_ok
    if [ "$regression_ok" != "y" ] && [ "$regression_ok" != "Y" ]; then
        print_error "REGRESSION DETECTEE!"
        print_warning "1. Identifier la cause"
        print_warning "2. Corriger le code"
        print_warning "3. Re-executer depuis ST.3"
        return 1
    fi
    update_state "phase_4" "ST.7_$CURRENT_STORY" "regression_completed"

    print_checkpoint "Story $CURRENT_STORY complete!"
}

# ============================================================================
# DEBUG WORKFLOW
# ============================================================================

run_debug_workflow() {
    print_header "WORKFLOW DEBUG - Correction de Bug"

    BUG_ID="BUG-$(date +%Y%m%d%H%M%S)"
    update_state "debug" "starting" "debug_started"

    echo -e "Bug ID: ${CYAN}$BUG_ID${NC}"
    echo ""

    # PHASE 1: DIAGNOSTIC
    print_subheader "PHASE 1: DIAGNOSTIC"

    print_step "D.1 - Collecte des informations"
    echo "Commande: debug-start"
    echo "Output: debug/bug-report-$BUG_ID.md"
    echo ""
    echo "Utilisez le prompt: prompt-debug-workflow.md (section D.1)"
    echo ""
    echo "Questions a poser a l'utilisateur:"
    echo "  - Description du bug"
    echo "  - Etapes de reproduction"
    echo "  - Comportement attendu"
    echo "  - Logs/erreurs"
    read -r -p "Bug report cree? [y/N]: " _done
    update_state "debug" "D.1" "bug_report_completed"

    print_step "D.2 - Analyse du code impacte"
    echo "Commande: debug-analyze"
    echo "Output: debug/analysis-$BUG_ID.md"
    read -r -p "Analyse faite? [y/N]: " _done
    update_state "debug" "D.2" "analysis_completed"

    print_step "D.3 - Identification des tests existants"
    echo "Commande: tea → analyze-regression --debug-mode"
    echo "Output: debug/related-tests-$BUG_ID.md"
    echo ""
    echo "Utilisez le prompt: prompt-analyze-regression.md"
    read -r -p "Tests identifies? [y/N]: " _done
    update_state "debug" "D.3" "tests_identified"

    # PHASE 2: CORRECTION
    print_subheader "PHASE 2: CORRECTION"

    print_step "F.1 - Ecriture du test du bug"
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║ CRUCIAL: Ce test DOIT ECHOUER avant la correction!                       ║${NC}"
    echo -e "${RED}║ C'est la preuve que le bug existe.                                       ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Commande: tea → write-bug-test"
    echo "Output: tests/bugs/bug-$BUG_ID.spec.ts"
    echo ""
    echo "Utilisez le prompt: prompt-write-bug-test.md"
    read -p "Test ecrit et ECHOUE (RED)? [y/N]: " test_fails
    if [ "$test_fails" != "y" ] && [ "$test_fails" != "Y" ]; then
        print_error "Le test du bug doit echouer!"
        return 1
    fi
    update_state "debug" "F.1" "bug_test_written"

    print_step "F.2 - Correction du bug"
    echo "Commande: dev-fix"
    echo ""
    echo -e "${GREEN}VALIDATION: Le test du bug doit maintenant PASSER${NC}"
    read -p "Bug corrige et test PASSE (GREEN)? [y/N]: " fixed
    if [ "$fixed" != "y" ] && [ "$fixed" != "Y" ]; then
        print_warning "Continuer la correction..."
        return 1
    fi
    update_state "debug" "F.2" "bug_fixed"

    print_step "F.3 - Verification avec l'utilisateur"
    echo "Commande: debug-verify"
    echo ""
    echo "Questions:"
    echo "  - Le bug est-il resolu?"
    echo "  - Le comportement est-il conforme aux attentes?"
    echo ""
    read -p "Correction confirmee par l'utilisateur? [y/N]: " confirmed
    if [ "$confirmed" != "y" ] && [ "$confirmed" != "Y" ]; then
        print_warning "Retour a F.2 pour ajustement"
        return 1
    fi
    update_state "debug" "F.3" "fix_confirmed"

    # PHASE 3: NON-REGRESSION
    print_subheader "PHASE 3: NON-REGRESSION (OBLIGATOIRE!)"

    echo -e "${YELLOW}⚠️  CETTE PHASE NE PEUT PAS ETRE SAUTEE!${NC}"
    echo ""

    print_step "R.1 - Tests lies au code modifie"
    echo "Commande: npm test -- --scope=related"
    read -p "Tests lies PASSENT? [y/N]: " r1
    if [ "$r1" != "y" ] && [ "$r1" != "Y" ]; then
        print_error "REGRESSION DETECTEE! Corriger avant de continuer."
        return 1
    fi
    update_state "debug" "R.1" "related_tests_passed"

    print_step "R.2 - Tests du module"
    echo "Commande: npm test -- --scope=module"
    read -p "Tests module PASSENT? [y/N]: " r2
    if [ "$r2" != "y" ] && [ "$r2" != "Y" ]; then
        print_error "REGRESSION DETECTEE! Corriger avant de continuer."
        return 1
    fi
    update_state "debug" "R.2" "module_tests_passed"

    print_step "R.3 - Tests d'integration"
    echo "Commande: npm test:integration"
    read -p "Tests integration PASSENT? [y/N]: " r3
    if [ "$r3" != "y" ] && [ "$r3" != "Y" ]; then
        print_error "REGRESSION DETECTEE! Corriger avant de continuer."
        return 1
    fi
    update_state "debug" "R.3" "integration_tests_passed"

    print_step "R.5 - Rapport de regression"
    echo "Commande: tea → regression-report"
    echo "Output: reports/regression-debug-$BUG_ID.md"
    echo ""
    echo "Utilisez le prompt: prompt-regression-report.md"
    read -r -p "Rapport genere? [y/N]: " _done
    update_state "debug" "R.5" "regression_report_generated"

    # PHASE 4: FINALISATION
    print_subheader "PHASE 4: FINALISATION"

    print_step "C.1 - Integration du test dans la suite permanente"
    echo "Deplacer: tests/bugs/bug-$BUG_ID.spec.ts"
    echo "Vers:     tests/regression/{module}/{feature}-fix.spec.ts"
    read -r -p "Test integre? [y/N]: " _done
    update_state "debug" "C.1" "test_integrated"

    print_step "C.2 - Documentation de la correction"
    echo "Output: debug/fix-documentation-$BUG_ID.md"
    read -r -p "Documentation faite? [y/N]: " _done
    update_state "debug" "C.2" "fix_documented"

    print_step "C.3 - Code review rapide"
    echo "Commande: code-review --quick"
    read -p "Review approuvee? [y/N]: " approved
    update_state "debug" "C.3" "review_completed"

    print_step "C.4 - Merge"
    echo "Commande: git merge"
    # shellcheck disable=SC2034
    read -p "Merge effectue? [y/N]: " merged
    update_state "debug" "C.4" "merged"

    print_checkpoint "DEBUG WORKFLOW COMPLETE - Bug $BUG_ID corrige!"
}

# ============================================================================
# PHASE 2: PLANNING
# ============================================================================

run_phase_2() {
    print_header "PHASE 2: PLANNING"
    update_state "phase_2" "starting" "phase_2_started"

    print_step "2.1 - PRD Creation"
    echo "Commande: create-prd"
    echo "Output: docs/prd.md"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_2" "2.1" "prd_completed"

    print_step "2.2 - UX Design"
    echo "Commande: create-ux-design"
    echo "Output: docs/ux-specification.md"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_2" "2.2" "ux_completed"

    print_checkpoint "Phase 2 complete"
}

# ============================================================================
# PHASE 3: SOLUTIONING
# ============================================================================

run_phase_3() {
    print_header "PHASE 3: SOLUTIONING"
    update_state "phase_3" "starting" "phase_3_started"

    print_step "3.1 - Architecture"
    echo "Commande: create-architecture"
    echo "Output: docs/architecture.md"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_3" "3.1" "architecture_completed"

    print_step "3.2 - TEA Test Design"
    echo "Commandes: tea → test-design"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_3" "3.2" "test_design_completed"


    print_step "3.3 - NFR Assessment"
    echo "Commandes: tea → nfr-assess"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_3" "3.3" "nfr_completed"

    print_step "3.4 - Epics & Stories"
    echo "Commande: create-epics-and-stories"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_3" "3.4" "epics_stories_completed"

    print_step "3.5 - Implementation Readiness"
    echo "Commande: check-implementation-readiness"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_3" "3.5" "readiness_checked"

    print_checkpoint "Phase 3 complete"
}

# ============================================================================
# SPRINT 0
# ============================================================================

run_sprint_0() {
    print_header "SPRINT 0: SETUP"
    update_state "sprint_0" "starting" "sprint_0_started"

    read -p "Framework de test existe deja? [y/N]: " has_framework

    if [ "$has_framework" != "y" ] && [ "$has_framework" != "Y" ]; then
        print_step "S0.1 - Framework Setup"
        echo "Commandes: tea → framework"
        read -p "Appuyez sur Entree apres execution..."
        update_state "sprint_0" "S0.1" "framework_completed"
    fi

    read -p "Pipeline CI existe deja? [y/N]: " has_ci

    if [ "$has_ci" != "y" ] && [ "$has_ci" != "Y" ]; then
        print_step "S0.2 - CI Pipeline Setup"
        echo "Commandes: tea → setup-ci"
        read -p "Appuyez sur Entree apres execution..."
        update_state "sprint_0" "S0.2" "ci_completed"
    fi

    print_checkpoint "Sprint 0 complete"
}

# ============================================================================
# PHASE 4: IMPLEMENTATION
# ============================================================================

run_phase_4() {
    print_header "PHASE 4: IMPLEMENTATION"
    update_state "phase_4" "starting" "phase_4_started"

    if [ "$PROJECT_TYPE" != "QUICK_FLOW" ]; then
        print_step "Epic Start - Test Design"
        echo "Commandes: tea → test-design (epic-level)"
        read -p "Appuyez sur Entree apres execution..."

        print_step "Sprint Planning"
        echo "Commande: sprint-planning"
        read -p "Appuyez sur Entree apres execution..."
    fi

    # Story loop
    while true; do
        echo ""
        read -p "Story a traiter (ou 'done' pour finir): " CURRENT_STORY
        if [ "$CURRENT_STORY" == "done" ]; then
            break
        fi
        run_story_loop
    done

    # Full regression test at epic end for full workflows
    if [ "$PROJECT_TYPE" == "WORKFLOW_COMPLET" ] || [ "$PROJECT_TYPE" == "DOCUMENT_PROJECT" ]; then
        print_step "Epic End - Tests de regression complets"
        echo "Commande: npm test:regression -- --scope=epic"
        echo ""
        echo -e "${YELLOW}Executer la suite COMPLETE de tests de regression${NC}"
        read -p "Tous les tests de regression passent? [y/N]: " all_pass
        if [ "$all_pass" != "y" ] && [ "$all_pass" != "Y" ]; then
            print_error "REGRESSION DETECTEE - Corriger avant release"
            return 1
        fi
        update_state "phase_4" "EE.4" "full_regression_completed"
    fi

    print_step "Epic End - Automate"
    echo "Commandes: tea → automate"
    read -p "Appuyez sur Entree apres execution..."

    print_step "Epic End - NFR Assessment"
    echo "Commandes: tea → nfr-assess"
    read -p "Appuyez sur Entree apres execution..."

    print_checkpoint "Phase 4 complete"
}

# ============================================================================
# PHASE 5: RELEASE
# ============================================================================

run_phase_5() {
    print_header "PHASE 5: RELEASE"
    update_state "phase_5" "starting" "phase_5_started"

    print_step "R.1 - Trace Gate Decision"
    echo "Commandes: tea → trace (Phase 2)"
    read -p "Verdict (PASS/WAIVED/FAIL): " verdict

    if [ "$verdict" != "PASS" ] && [ "$verdict" != "WAIVED" ]; then
        print_error "Release blocked"
        return 1
    fi
    update_state "phase_5" "R.1" "trace_gate_passed"

    print_step "R.2 - Deploy"
    echo "Commande: deploy"
    read -p "Appuyez sur Entree apres execution..."
    update_state "phase_5" "R.2" "deployed"

    print_checkpoint "RELEASE COMPLETE!"
}

# ============================================================================
# VIBE KANBAN INTEGRATION
# ============================================================================

export_to_vibe_kanban() {
    print_header "EXPORT VERS VIBE KANBAN"

    local SCRIPT_DIR
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    local IMPORT_SCRIPT="$SCRIPT_DIR/import-to-vibe-kanban.sh"

    if [ ! -f "$IMPORT_SCRIPT" ]; then
        print_error "Script d'import non trouve: $IMPORT_SCRIPT"
        exit 1
    fi

    shift # Remove --export-kanban from args

    # Forward remaining args to import script
    "$IMPORT_SCRIPT" "$@"
}

show_help() {
    echo ""
    echo "BMAD + TEA Workflow Runner v2.0"
    echo ""
    echo "USAGE:"
    echo "  ./workflow-runner.sh [OPTION]"
    echo ""
    echo "OPTIONS:"
    echo "  --status          Afficher l'etat du workflow en cours"
    echo "  --resume          Reprendre un workflow interrompu"
    echo "  --export-kanban   Exporter les stories vers Vibe Kanban"
    echo "  --help            Afficher cette aide"
    echo ""
    echo "EXPORT VIBE KANBAN:"
    echo "  ./workflow-runner.sh --export-kanban [OPTIONS]"
    echo ""
    echo "  Options d'export:"
    echo "    --project-id ID     Specifier l'ID du projet cible"
    echo "    --stories-dir DIR   Repertoire des stories (defaut: stories/)"
    echo "    --dry-run           Simuler sans creer les taches"
    echo "    --port PORT         Port du backend (defaut: 3001)"
    echo ""
    echo "EXEMPLES:"
    echo "  ./workflow-runner.sh                    # Demarrer un nouveau workflow"
    echo "  ./workflow-runner.sh --status           # Voir le status"
    echo "  ./workflow-runner.sh --export-kanban    # Exporter vers Vibe Kanban"
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    print_header "BMAD + TEA WORKFLOW RUNNER v2.0"

    # Check for --help flag
    if [ "$1" == "--help" ]; then
        show_help
        exit 0
    fi

    # Check for --status flag
    if [ "$1" == "--status" ]; then
        show_status
        exit 0
    fi

    # Check for --export-kanban flag
    if [ "$1" == "--export-kanban" ]; then
        export_to_vibe_kanban "$@"
        exit 0
    fi

    # Check for --resume flag
    if [ "$1" == "--resume" ]; then
        if check_existing_state; then
            print_info "Reprise du workflow..."
        else
            print_warning "Aucun workflow a reprendre"
            exit 1
        fi
    else
        # Check for existing state
        if check_existing_state; then
            print_info "Reprise du workflow en cours..."
        else
            # New workflow - run questionnaire
            run_questionnaire

            # Get project name
            echo ""
            read -p "Nom du projet: " PROJECT_NAME

            # Initialize state
            init_state
        fi
    fi

    echo ""
    echo -e "Workflow: ${GREEN}$PROJECT_TYPE${NC}"
    echo ""

    case $PROJECT_TYPE in
        "WORKFLOW_COMPLET")
            run_phase_1
            run_phase_2
            run_phase_3
            run_sprint_0
            run_phase_4
            run_phase_5
            ;;
        "DOCUMENT_PROJECT")
            run_phase_0
            run_phase_2
            run_phase_3
            run_sprint_0
            run_phase_4
            run_phase_5
            ;;
        "QUICK_FLOW")
            run_quick_flow
            run_phase_4
            ;;
        "DEBUG")
            run_debug_workflow
            ;;
    esac

    # Mark workflow complete
    update_state "complete" "done" "workflow_completed"

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                       WORKFLOW COMPLETE!                                 ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Run
main "$@"
