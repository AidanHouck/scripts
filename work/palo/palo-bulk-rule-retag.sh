#!/usr/bin/env bash

# Auto-retag Palo Alto "set" config with "ALLOW"/"DENY" tags

# input palo alto "set" config action + tag
# output palo alto "set" config new tag modifications

# This requires the lines to be alphabetically sorted, with blank lines removed
#FILE='palo-bulk-rule-retag.sh.real.txt'
FILE='palo-bulk-rule-retag.sh.test.txt'

SEARCH1='action'
SEARCH2='tag'

prevRuleName=''
prevValue=''
prevParam=''

while IFS= read -r line; do
	# Extract rule name, action/tag, and action/tag value
	lineTrim=$(echo "$line" | cut -d" " -f7-)
	lineBase=$(echo "$line" | cut -d" " -f-6)

	# Extract just rule name before SEARCH1/SEARCH2
	currRuleName=${lineTrim%$SEARCH1*}
	if [ "$lineTrim" == "$currRuleName" ]; then
		currRuleName=${lineTrim%$SEARCH2*}
	fi

	# Extract just action/tag and their value
	currParam=${lineTrim#*$SEARCH1}
	if [ "$lineTrim" == "$currParam" ]; then
		currParam=${lineTrim#*$SEARCH2}
		currValue=$SEARCH2
	else
		currValue=$SEARCH1
	fi

	# We are comparing the correct rule
	if [ "$prevRuleName" == "$currRuleName" ]; then
		# Set ACTION and TAG params
		if [ "$currValue" == "$SEARCH1" ]; then
			action=${currParam// /} # ${var// /} removes spaces from $var
			tags=${prevParam// /}
		elif [ "$prevValue" == "$SEARCH1" ]; then
			action=${prevParam// /}
			tags=${currParam// /}
		fi

		# Determine the needed tag for the given action
		if [ "$action" == 'drop' ] || [ "$action" == 'deny' ]; then
			newTag="DENY"
			otherTag="ALLOW"
		elif [ "$action" == 'allow' ]; then
			newTag="ALLOW"
			otherTag="DENY"
		else
			echo "ERROR: COUNT NOT MATCH ACTION [$action] FOR: $currRuleName!"
		fi

		# Verify we don't already have the needed tag on the rule
		if [[ $tags != *"$newTag"* ]]; then
			# Print action statement
			echo "$lineBase $currRuleName""tag $newTag"
		fi

		# Remove any incorrect tags
		if [[ $tags == *"$otherTag"* ]]; then
			# Print action statement
			echo "delete${lineBase#set} $currRuleName""tag $otherTag"
		fi
	fi

	# Assign values for previous lines
	prevRuleName=$currRuleName
	prevValue=$currValue
	prevParam=$currParam
done < "$FILE"

