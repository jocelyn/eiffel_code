note
	description: "Summary description for {FILE_SUGGESTION_MATCHER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STRING_STARTS_WITH_SUGGESTION_MATCHER

inherit
	SUGGESTION_MATCHER
		redefine
			is_ready
		end

feature -- Status report

	is_ready: BOOLEAN = True
			-- <Precursor>
			-- We can always perform a match.

	is_matching (a_string: READABLE_STRING_GENERAL): BOOLEAN
			-- <Precursor>
		do
			if attached pattern as l_pattern then
				Result := a_string.starts_with (l_pattern)
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

