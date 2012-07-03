note
	description: "Summary description for {CASE_INSENSITIVE_SUBSTRING_SUGGESTION_MATCHER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CASE_INSENSITIVE_SUBSTRING_SUGGESTION_MATCHER

inherit
	SUBSTRING_SUGGESTION_MATCHER
		redefine
			is_matching
		end

feature -- Status report

	is_matching (a_string: READABLE_STRING_GENERAL): BOOLEAN
			-- <Precursor>
		do
			if attached pattern as l_pattern then
				Result := a_string.as_lower.has_substring (l_pattern.as_lower)
			end
		end

end
