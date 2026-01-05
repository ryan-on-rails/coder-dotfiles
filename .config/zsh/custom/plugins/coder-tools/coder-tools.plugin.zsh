# Function to create and configure a Coder workspace from a Jira branch name
qa-coder() {
  if [ -z "$1" ]; then
    echo "Usage: qa-coder <jira-branch-name> <template>"
    echo "Example: qa-coder PT-840-Incorrect-floor-cap-showing..."
    return 1
  fi

  local FULL_BRANCH_NAME="$1"
  local SCRIPT_FILE="${HOME}/qa-setup.sh"
  local TEMPLATE_NAME="${2:-csdev}"

  # Parse Ticket ID from the branch name
  if [[ "${FULL_BRANCH_NAME}" =~ ^([A-Z]+-[0-9]+) ]]; then
    local TICKET_ID="${match[1]}"
  else
    echo "Error: Could not parse ticket ID from branch name: ${FULL_BRANCH_NAME}" >&2
    return 1
  fi

  local WORKSPACE_NAME="${TICKET_ID}-qa-review"
  local FULL_WORKSPACE_NAME="${$(coder whoami | awk '{print $NF}')}/${WORKSPACE_NAME}"
  local CODER_HOST="coder.${WORKSPACE_NAME}"
  
  echo "--- 🛠️  Starting Idempotent Coder QA Setup ---"
  echo "Workspace Name: ${FULL_WORKSPACE_NAME}"
  echo "Target Branch:  ${FULL_BRANCH_NAME}"

  local WORKSPACE_LINE
  local WORKSPACE_STATUS
  
  WORKSPACE_LINE=$(coder list 2>/dev/null | grep "${FULL_WORKSPACE_NAME}")
  
  if [ -n "${WORKSPACE_LINE}" ]; then
    WORKSPACE_STATUS=$(echo "${WORKSPACE_LINE}" | awk '{print $3}')

    case "${WORKSPACE_STATUS}" in
      Started)
        echo "✅ Workspace '${WORKSPACE_NAME}' already RUNNING. Proceeding to config."
        ;;
      Stopped)
        echo "🟡 Workspace '${WORKSPACE_NAME}' exists but is STOPPED. Starting now..."
        coder start "${WORKSPACE_NAME}" -y
        ;;
      Failed)
        echo "❌ Workspace '${WORKSPACE_NAME}' is in a FAILED state. Restarting..."
        coder restart "${WORKSPACE_NAME}" -y
        ;;
      *)
        echo "🟡 Workspace '${WORKSPACE_NAME}' exists with status: ${WORKSPACE_STATUS}. Proceeding to config."
        ;;
    esac
  else
    echo "➕ Workspace '${WORKSPACE_NAME}' does not exist. Creating now..."

    local AMI_PARAM_NAME="ami_name_prefix"
    local AMI_DEFAULT_VALUE="csdev-main-ubuntu-jammy-amd64-"

    echo "Creating workspace from template ${TEMPLATE_NAME}..."
    if [ "${TEMPLATE_NAME}" = "csdev" ]; then
      coder create "${WORKSPACE_NAME}" -t "${TEMPLATE_NAME}" -y \
        --parameter "${AMI_PARAM_NAME}=${AMI_DEFAULT_VALUE}" \
        --parameter "csdev_branch=main" \
        --parameter "instance_type=t3.2xlarge" \
        --parameter "region=us-east-1"
    else
      coder create "${WORKSPACE_NAME}" -t "${TEMPLATE_NAME}" -y \
        --parameter "csdev_branch=main"
    fi
  fi

  echo "Waiting for workspace connection..."

  echo "Copying setup script (${SCRIPT_FILE}) to workspace..."
  scp "${SCRIPT_FILE}" "${CODER_HOST}":~/

  echo "Executing branch checkout commands remotely..."
  ssh -t "${CODER_HOST}" -- env BRANCH_NAME="${FULL_BRANCH_NAME}" bash /home/coder/qa-setup.sh

  echo "--- ✅ Workspace Setup Complete ---"
}
