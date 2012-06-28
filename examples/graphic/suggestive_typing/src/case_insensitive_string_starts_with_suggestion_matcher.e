note
	description: "Summary description for {FILE_SUGGESTION_MATCHER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CASE_INSENSITIVE_STRING_STARTS_WITH_SUGGESTION_MATCHER

inherit
	STRING_STARTS_WITH_SUGGESTION_MATCHER
		redefine
			is_matching
		end

feature -- Status report

	is_matching (a_string: READABLE_STRING_GENERAL): BOOLEAN
			-- <Precursor>
		do
			if attached pattern as l_pattern then
				Result := a_string.as_lower.starts_with (l_pattern.as_lower)
			end
		end

note
	copyright: "Copyright (c) 1984-2012, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end

