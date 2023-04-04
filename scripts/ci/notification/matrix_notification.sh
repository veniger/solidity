#!/bin/bash

set -e
shopt -s inherit_errexit

SCRIPT_DIR="$(dirname "$0")"

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

notify() {
    # Prevent eval over unexpected environment variable values
    BRANCH="$(sanitize_variable "$BRANCH")"
    TAG="$(sanitize_variable "$TAG")"
    BUILD_URL="$(sanitize_variable "$BUILD_URL")"
    BUILD_NUM="$(sanitize_variable "$BUILD_NUM")"

    # FIXME: Checking $CIRCLE_PULL_REQUEST would be better than hard-coding branch names
    # but it's broken. CircleCI associates runs on develop/breaking with random old PRs.
    [[ "$BRANCH" == "develop" || "$BRANCH" == "breaking" ]] || { echo "Running on a PR or a feature branch - notification skipped."; exit 0; }

    [[ -z "$1" ]] && fail "Event type not provided."
    local event="$1"

    # The release notification only makes sense on tagged commits. If the commit is untagged, just bail out.
    [[ "$event" == "release" ]] && { [[ $TAG != "" ]] || { echo "Not a tagged commit - notification skipped."; exit 0; } }

    workflow_name="$(circleci_workflow_name)"
    job="$(circleci_job_name)"
    formatted_message="$(format_message "$event")"

    curl "https://${MATRIX_SERVER}/_matrix/client/v3/rooms/${MATRIX_NOTIFY_ROOM_ID}/send/m.room.message" \
        --request POST \
        --include \
        --header "Content-Type: application/json" \
        --header "Accept: application/json" \
        --header "Authorization: Bearer ${MATRIX_ACCESS_TOKEN}" \
        --data "$formatted_message"
}

circleci_workflow_name() {
    # Workflow name is not exposed as an env variable. Has to be queried from the API.
    # The name is not critical so if anything fails, use the raw workflow ID as a fallback.
    workflow_info=$(curl --silent "https://circleci.com/api/v2/workflow/${CIRCLE_WORKFLOW_ID}") || true
    workflow_name=$(echo "$workflow_info" | grep -E '"\s*name"\s*:\s*".*"' | cut -d \" -f 4 || echo "$CIRCLE_WORKFLOW_ID")
    printf '%s' "$(sanitize_variable "$workflow_name")"
}

circleci_job_name() {
    [[ $CIRCLE_NODE_TOTAL == 1 ]] && job="${CIRCLE_JOB}"
    [[ $CIRCLE_NODE_TOTAL != 1 ]] && job="${CIRCLE_JOB} (run $((CIRCLE_NODE_INDEX + 1))/${CIRCLE_NODE_TOTAL})"
    printf '%s' "$(sanitize_variable "$job")"
}

# Currently matrix only supports html formatted body,
# see: https://spec.matrix.org/v1.6/client-server-api/#mtext
#
# Eventually, the matrix api will have support for better format options and `formatted_body` may not be necessary anymore:
# https://github.com/matrix-org/matrix-spec-proposals/pull/1767
format_message() {
    [[ -z "$1" ]] && fail "Event type not provided."
    local event="$1"

    [[ "$event" == "failure" ]] && message="$(cat "${SCRIPT_DIR}/templates/build_fail.json")"
    [[ "$event" == "success" ]] && message="$(cat "${SCRIPT_DIR}/templates/build_success.json")"
    [[ "$event" == "release" ]] && message="$(cat "${SCRIPT_DIR}/templates/build_release.json")"

    [[ -z "$message" ]] && fail "Message for event [$event] not defined."

    # Escape \ and "
    formatted_msg="$(printf '%s' "$message" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')"
    # Evaluate environment variables
    # NOTE: The variables must be sanitized before call eval to avoid execution
    # of unexpected commands instead of valid input values.
    # shellcheck disable=SC2005
    echo "$(eval printf '%s' \""${formatted_msg}"\")"
}

sanitize_variable() {
    sanitized_value="$(printf '%s' "$1" | sed "s;[^[:blank:][:alnum:]_:/?=&.()-];;g")"
    echo "$sanitized_value"
}

# Set message environment variables based on CI backend
if [[ "$CIRCLECI" = true ]] ; then
    BRANCH="$CIRCLE_BRANCH"
    TAG="$CIRCLE_TAG"
    BUILD_URL="$CIRCLE_BUILD_URL"
    BUILD_NUM="$CIRCLE_BUILD_NUM"
fi

notify "$@"
